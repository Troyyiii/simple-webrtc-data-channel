class MessageModel {
  final String sender;
  final String message;
  DateTime? time;

  MessageModel({
    required this.sender,
    required this.message,
    this.time,
  });
}
