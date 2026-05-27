// 1. Target Interface
abstract class IHashtagProcessor {
  List<String> getFormattedTags();
}

// 2. Adaptee
// Existing class with incompatible interface
class RawUserInput {
  final String text;
  RawUserInput(this.text);

  String getRawText() => text;
}

// SINGLE RESPONSIBILITY PRINCIPLE (SRP)
// This class has one, single job: parsing raw text strings into clean arrays.
class TextTagParser {
  List<String> parseAndClean(String rawText) {
    return rawText
        .split(' ')
        .where((tag) => tag.isNotEmpty)
        .map((tag) => tag.replaceAll('#', '').trim())
        .toList();
  }
}

// 3. Adapter
// It implements the Target interface and wraps the Adaptee.
class HashtagAdapter implements IHashtagProcessor {
  final RawUserInput _rawInput;

  // Calling parser
  final TextTagParser _parser = TextTagParser();

  HashtagAdapter(RawUserInput rawInput) : _rawInput = rawInput;

  @override
  List<String> getFormattedTags() {

    final rawText = _rawInput.getRawText();
    return _parser.parseAndClean(rawText);

  }

  // HashtagAdapter used to be a target interface and it also
  // implemented raw text parsing
  // I refactored this code so that raw text parsing is it's own
  // separate class, so HashtagAdapter can just act as the interface

  // @override
  // List<String> getFormattedTags() {
  //   // Logic to convert raw String to clean List<String>
  //   final rawText = _rawInput.getRawText();
  //   return rawText
  //       .split(' ')
  //       .where((tag) => tag.isNotEmpty)
  //       .map((tag) => tag.replaceAll('#', '').trim())
  //       .toList();
  // }
}

