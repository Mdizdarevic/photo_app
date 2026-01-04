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

// 3. Adapter
// It implements the Target interface and wraps the Adaptee.
class HashtagAdapter implements IHashtagProcessor {
  final RawUserInput _rawInput;

  HashtagAdapter(RawUserInput rawInput) : _rawInput = rawInput;

  @override
  List<String> getFormattedTags() {
    // Logic to convert raw String to clean List<String>
    final rawText = _rawInput.getRawText();
    return rawText
        .split(' ')
        .where((tag) => tag.isNotEmpty)
        .map((tag) => tag.replaceAll('#', '').trim())
        .toList();
  }
}