import 'dart:async';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/model/chat_message_model.dart';
import '../../data/service/api/google_generative_ai.dart';
part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  Box<ChatMessageModel>? _messagesBox;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ChatCubit() : super(ChatInitial());

  // HELPER

  bool isSymptomCheck(String message) {
    final symptomKeywords = [
      "headache",
      "fever",
      "cough",
      "pain",
      "nausea",
      "flu" // Add "flu" to the list
    ];
    return symptomKeywords
        .any((keyword) => message.toLowerCase().contains(keyword));
  }

  List<String> extractSymptoms(String message) {
    // Extract symptoms from the message (basic implementation)
    final symptomKeywords = ["headache", "fever", "cough", "pain", "nausea"];
    return symptomKeywords
        .where((keyword) => message.toLowerCase().contains(keyword))
        .toList();
  }

  List<String> analyzeSymptoms(List<String> symptoms) {
    // Analyze symptoms and return possible conditions (basic implementation)
    if (symptoms.contains("fever") && symptoms.contains("cough")) {
      return ["flu", "common cold"];
    } else if (symptoms.contains("headache")) {
      return ["migraine", "tension headache"];
    }
    return ["unknown"];
  }

  List<String> provideRecommendations(List<String> conditions) {
    // Provide recommendations based on conditions (basic implementation)
    if (conditions.contains("flu")) {
      return ["Drink plenty of fluids.", "Take paracetamol for fever."];
    } else if (conditions.contains("migraine")) {
      return ["Rest in a dark room.", "Take prescribed medication."];
    }
    return ["Consult a doctor for further advice."];
  }

  // Open Hive box for local storage
  Future<void> openMessagesBox() async {
    try {
      _messagesBox = await Hive.openBox<ChatMessageModel>(
          'chat_history_${FirebaseAuth.instance.currentUser?.uid}');
    } on HiveError catch (err) {
      log(err.message.toString());
    }
  }

  // Initialize Hive and Firestore
  Future<void> initHive() async {
    try {
      final appDocumentDir = await getApplicationDocumentsDirectory();
      Hive.init(appDocumentDir.path);
      await openMessagesBox();
      startListeningToMessages();
    } on HiveError catch (err) {
      log(err.message.toString());
    }
  }

  // Listen to messages from Firestore
  void startListeningToMessages() {
    try {
      // Listen to Firestore collection
      _firestore
          .collection('chats')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .collection('messages')
          .orderBy('timeTamp', descending: true)
          .snapshots()
          .listen((snapshot) {
        List<ChatMessageModel> messages = snapshot.docs
            .map((doc) => ChatMessageModel.fromJson(doc.data()))
            .toList();
        emit(ChatReceiveSuccess(response: messages));
      });
    } catch (err) {
      log(err.toString());
    }
  }

  // Send a message and store it in Firestore
  Future<void> sendMessage({required String message}) async {
    emit(ChatSenderLoading());
    try {
      // Save user's message to Firestore
      final userMessage = ChatMessageModel(
        isUser: true,
        message: message.trim(),
        timeTamp: dateTimeFormatter(),
      );
      await _firestore
          .collection('chats')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .collection('messages')
          .add(userMessage.toJson());

      emit(ChatSendSuccess());
      await Future.delayed(const Duration(milliseconds: 350));

      emit(ChatReceiverLoading());

      // Check if the message is related to symptoms
      if (isSymptomCheck(message)) {
        print("Symptom check detected in message: $message");

        final symptoms = extractSymptoms(message); // Extract symptoms
        print("Extracted symptoms: $symptoms");

        final possibleConditions =
            analyzeSymptoms(symptoms); // Analyze symptoms
        print("Possible conditions: $possibleConditions");

        final recommendedActions = provideRecommendations(
            possibleConditions); // Provide recommendations
        print("Recommended actions: $recommendedActions");

        // Save symptom checker print to Firestore
        try {
          await _firestore.collection('symptom_prints').add({
            'userId': FirebaseAuth.instance.currentUser?.uid,
            'symptoms': symptoms,
            'possibleConditions': possibleConditions,
            'recommendedActions': recommendedActions,
            'timestamp': DateTime.now().toIso8601String(),
          });
          print("Symptom print saved to Firestore.");
        } catch (err) {
          print("Failed to save symptom log: $err");
        }

        // Construct the bot's response
        final response =
            "Based on your symptoms, you might have: ${possibleConditions.join(", ")}. "
            "Here's what you can do: ${recommendedActions.join(" ")}";
        final botMessage = ChatMessageModel(
          isUser: false,
          message: response,
          timeTamp: dateTimeFormatter(),
        );
        await _firestore
            .collection('chats')
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .collection('messages')
            .add(botMessage.toJson());

        emit(ChatSendSuccess());
      } else {
        print("No symptoms detected in message: $message");

        // Handle non-symptom-related messages
        final response = await GenerativeAiWebService.postData(text: message);
        final botMessage = ChatMessageModel(
          isUser: false,
          message: response ?? "ERROR",
          timeTamp: dateTimeFormatter(),
        );
        await _firestore
            .collection('chats')
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .collection('messages')
            .add(botMessage.toJson());

        emit(ChatSendSuccess());
      }
    } catch (err, stackTrace) {
      print("Error in sendMessage: ${err.toString()}");
      print("StackTrace: ${stackTrace.toString()}");
      emit(ChatFailure(message: err.toString()));
    }
  }

  // Delete all messages from Firestore
  Future<void> deleteAllMessages() async {
    emit(ChatDeletingLoading());
    try {
      // Delete all messages from Firestore
      final messages = await _firestore
          .collection('chats')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .collection('messages')
          .get();
      for (var doc in messages.docs) {
        await doc.reference.delete();
      }
      emit(ChatDeleteSuccess());
    } catch (err) {
      log(err.toString());
      emit(ChatDeleteFailure(message: "Failed to delete chat history: $err"));
    }
  }

  // Format timestamp
  String dateTimeFormatter() {
    DateTime now = DateTime.now();
    DateFormat formatter = DateFormat('yyyy-MM-dd hh:mm a');
    String formattedDate = formatter.format(now);
    log(formattedDate);
    return formattedDate;
  }
}
