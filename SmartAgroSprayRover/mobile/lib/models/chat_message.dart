class ChatMessage {
  final String text;
  final bool isUser;
  final String language;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.language = 'en',
  });
}
