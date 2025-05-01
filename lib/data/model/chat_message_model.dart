import 'package:hive/hive.dart';
part 'chat_message_model.g.dart'; // Generated file

@HiveType(typeId: 0)
class ChatMessageModel {
  @HiveField(0)
  final bool isUser;

  @HiveField(1)
  final String message;

  @HiveField(2)
  final String timeTamp;

  ChatMessageModel({
    required this.isUser,
    required this.message,
    required this.timeTamp,
  });

  // Factory constructor to create a ChatMessageModel from a Map (Firestore document)
  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      isUser: json['isUser'] as bool,
      message: json['message'] as String,
      timeTamp: json['timeTamp'] as String,
    );
  }

  // Convert a ChatMessageModel into a Map (for saving to Firestore)
  Map<String, dynamic> toJson() {
    return {
      'isUser': isUser,
      'message': message,
      'timeTamp': timeTamp,
    };
  }
}
