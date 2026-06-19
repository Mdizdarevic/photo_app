import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_app/domain/models/user_entity.dart';
import 'package:photo_app/domain/models/package_config.dart';
import 'package:photo_app/domain/patterns/upload_validation_chain.dart';
import 'package:photo_app/presentation/core/app_constants.dart';
import 'package:photo_app/presentation/pages/auth/login_page.dart';
import 'package:photo_app/presentation/pages/main_wrapper.dart';
import 'package:photo_app/presentation/pages/profile/consumption_tracker.dart';
import 'package:photo_app/presentation/pages/upload/upload_page.dart';
import 'package:photo_app/di.dart';

void main() {

  // CATEGORY 1: UNIT TESTS (3 Tests)

  group('CATEGORY 1: UNIT TESTS', () {

    test('1. FreePackageStrategy maps correctly to the daily upload limit found in AppConstants', () {
      final strategy = FreePackageStrategy();
      final config = PackageConfig.fromStrategy(strategy);

      expect(config.dailyUploadLimit, equals(AppConstants.freeDailyLimit),
          reason: 'Free tier quota mapping must match AppConstants configuration.');
    });

    test('2. ProPackageStrategy maps correctly to the daily upload limit found in AppConstants', () {
      final strategy = ProPackageStrategy();
      final config = PackageConfig.fromStrategy(strategy);

      expect(config.dailyUploadLimit, equals(AppConstants.proDailyLimit),
          reason: 'Pro tier quota mapping must match AppConstants configuration.');
    });

    test('3. Testing if CopyWith correctly guarantees that UserEntity keeps its immutability', () {

      final baseUser = UserEntity(
        id: 'user_123',
        email: 'moreno@algebra.hr',
        role: UserRole.registered,
        package: PackageTier.free,
        photosUploadedToday: 1,
      );

      final updatedUser = baseUser.copyWith(package: PackageTier.gold, photosUploadedToday: 15);

      expect(updatedUser.package, equals(PackageTier.gold));
      expect(baseUser.package, equals(PackageTier.free));
    });

  });

  // CATEGORY 2: INTEGRATION TESTS (1 Test)

  group('CATEGORY 2: INTEGRATION TESTS', () {

    test('4. Testing if Chain of Responsibility Validation Chain correctly stops if there is no image', () {

      final brokenRequest = UploadRequest(
        imageFile: null, // Null file shoudl violate the first link in the validation chain
        user: UserEntity(
            id: 'u1',
            email: 'user@app.com',
            role: UserRole.registered,
            package: PackageTier.free
        ),
        description: 'Testing Pothole',
      );

      final validatorChain = ImageValidator()
        ..setNext(UserValidator())
        ..setNext(TextValidator());

      expect(() => validatorChain.handle(brokenRequest), throwsA(isA<Exception>()));
    });
  });

// CATEGORY 3: UI WIDGET TESTS (6 Tests)

  group('CATEGORY 3: UI WIDGET TESTS', () {

    testWidgets('5. Testing if ConsumptionTracker correctly tracks/displays the number of posts', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          // example user with their user entity info and # of posts
          overrides: [
            userPostCountProvider.overrideWith((ref) => 2),
            userStreamProvider.overrideWith((ref) => Stream.value(
                UserEntity(id: '1', email: 'test@app.com', role: UserRole.registered, package: PackageTier.free)
            )),
          ],
          child: const MaterialApp(
            home: Scaffold(body: ConsumptionTracker()),
          ),
        ),
      );

      // tells the testing framework to wait until everything loaded on the screen before checking
      await tester.pumpAndSettle();

      expect(find.text('FREE PLAN'), findsOneWidget);
      expect(find.text('2 / 5'), findsOneWidget);
    });

    testWidgets('6. Testing if ConsumptionTracker correctly displays posts + progress bar color', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userPostCountProvider.overrideWith((ref) => 45),
            userStreamProvider.overrideWith((ref) => Stream.value(
                UserEntity(id: '1', email: 'gold@app.com', role: UserRole.registered, package: PackageTier.gold)
            )),
          ],
          child: const MaterialApp(
            home: Scaffold(body: ConsumptionTracker()),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('GOLD PLAN'), findsOneWidget);
      expect(find.text('45 / ∞'), findsOneWidget);

      final LinearProgressIndicator barWidget = tester.widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator));
      expect(barWidget.color, equals(Colors.amber));
    });

    testWidgets('7. Testing if ConsumptionTracker correctly tracks when limit is reached', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userPostCountProvider.overrideWith((ref) => AppConstants.freeDailyLimit), // Limit is reached
            userStreamProvider.overrideWith((ref) => Stream.value(
                UserEntity(id: '1', email: 'max@app.com', role: UserRole.registered, package: PackageTier.free)
            )),
          ],
          child: const MaterialApp(
            home: Scaffold(body: ConsumptionTracker()),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final LinearProgressIndicator barWidget = tester.widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator));
      expect(barWidget.color, equals(Colors.red));
      expect(find.text('5 / 5'), findsOneWidget);
    });

    testWidgets('8. Testing that UploadPage doesnt allow you to post when an image asset is absent', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWith((ref) =>
                UserEntity(id: '1',
                    email: 'uploader@app.com',
                    role: UserRole.registered)
            ),
          ],
          child: const MaterialApp(
            home: UploadPage(),
          ),
        ),
      );

      final ElevatedButton postButton = tester.widget<ElevatedButton>(find.byType(ElevatedButton));

      // Image is default null, so it should be true that post button is NOT enabled
      expect(postButton.enabled, isFalse,
          reason: 'Security Breach Error: Post Button shouldnt be enabled when theres no image.');
    });

    testWidgets('9. Testing that UploadPage description is max 3 lines', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWith((ref) =>
                UserEntity(
                    id: '1',
                    email: 'uploader@app.com',
                    role: UserRole.registered)
            ),
          ],
          child: const MaterialApp(
            home: UploadPage(),
          ),
        ),
      );

      final TextField descriptionField = tester.widget<TextField>(find.byType(TextField).first);
      expect(descriptionField.maxLines, equals(3));
    });

    testWidgets('10. Testing if LoginPage correctly switches from Log in to Sign Up when "Sign Up" is tapped', (WidgetTester tester) async {
          await tester.pumpWidget(
            const ProviderScope(
              child: MaterialApp(
                  home: LoginPage()
              ),
            ),
          );

          // Starting with Sign In mode
          expect(find.text('Please Sign In.'), findsOneWidget);

          // Tap "Sign Up" instead
          await tester.tap(find.text('Sign Up'));
          await tester.pumpAndSettle();

          expect(find.text('Create Account.'), findsOneWidget);
          expect(find.text('Please Sign In.'), findsNothing);

          expect(find.text('SELECT YOUR TIER'), findsOneWidget);
          expect(find.text('FREE'), findsOneWidget);
          expect(find.text('PRO'), findsOneWidget);
          expect(find.text('GOLD'), findsOneWidget);

     });
  });
}