class Message {
  final String senderId;
  final String senderName;
  final String reciverId;
  final String message;
  final dynamic timestamp; // Changed from Timestamp to dynamic

  Message(
      {required this.senderId,
      required this.senderName,
      required this.reciverId,
      required this.message,
      required this.timestamp});

  Map<String, dynamic> toMap() {
    return {
      'senderid': senderId,
      'senderName': senderName,
      'reciverId': reciverId,
      'message': message,
      'timestamp': timestamp,
    };
  }
}
