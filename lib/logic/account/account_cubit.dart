import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dr_ai/cache/cache.dart';
import 'package:dr_ai/data/model/user_data_model.dart';
import 'package:dr_ai/logic/auth/social_auth/social_auth_cubit.dart';
import 'package:dr_ai/utils/constant/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
part 'account_state.dart';

class AccountCubit extends Cubit<AccountState> {
  AccountCubit() : super(AccountInitial());
  final _firestore = FirebaseFirestore.instance;
  Future<void> getprofileData() async {
    emit(AccountLoading());
    try {
      UserDataModel? userDataModel;
      _firestore
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .snapshots()
          .listen((event) {
        userDataModel = UserDataModel.fromJson(event.data()!);
        CacheData.setData(key: "name", value: userDataModel!.name);
        CacheData.setMapData(key: "userData", value: userDataModel!.toJson());
        emit(AccountSuccess(userDataModel: userDataModel!));
      });
    } on FirebaseException catch (err) {
      emit(AccountFailure(message: err.toString()));
    }
  }

  Future<void> logout(BuildContext context) async {
    emit(AccountLogoutLoading());
    try {
      print("Starting logout process...");
      await Future.delayed(const Duration(seconds: 1));

      print("Clearing cache data...");
      await CacheData.clearData(clearData: true);

      print("Signing out from Firebase...");
      await FirebaseAuth.instance.signOut();

      // Check the authentication provider(s) used by the user
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final providerData = user.providerData;
        for (final provider in providerData) {
          if (provider.providerId == 'google.com') {
            print("Disconnecting Google Sign-In...");
            await GoogleSignIn().disconnect();
          } else if (provider.providerId == 'facebook.com') {
            print("Logging out from Facebook...");
            await FacebookAuth.instance.logOut();
          }
        }
      }

      print("Resetting SocialAuthCubit state...");
      context.read<SocialAuthCubit>().resetState();

      // Verify that the user is signed out
      if (FirebaseAuth.instance.currentUser == null) {
        print("User successfully signed out");
      } else {
        print("User is still signed in");
      }

      print("Navigating to login screen...");
      Navigator.pushNamedAndRemoveUntil(
          context, RouteManager.login, (route) => false);

      emit(AccountLogoutSuccess(message: "Logout successfully"));
    } on FirebaseException catch (err) {
      print("Logout failed: ${err.toString()}");
      emit(AccountFailure(message: err.toString()));
    } catch (e) {
      print("Unexpected error during logout: $e");
      emit(AccountFailure(message: "Unexpected error occurred"));
    }
  }

  Future<void> deleteAccount() async {
    emit(AccountDeleteLoading());
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      await _deleteChatHistory();
      await _firestore
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update(
        {'isActive': false},
      );
      // await _deleteUserData();
      log("DELETED CHAT HISTORY");
      await FirebaseAuth.instance.currentUser?.delete();
      log("DELETED USER ACCOUNT");
      await CacheData.clearData(clearData: true);
      log("DELETED CACHE DATA");
      await FirebaseAuth.instance.signOut();
      log("LOGGED OUT");
      emit(AccountDeleteSuccess(message: "Account deleted successfully"));
      log("ACCOUNT DELETED SUCCESSFULLY");
    } on FirebaseException catch (err) {
      log("DELETE ACCOUNT ERROR: ${err.toString()}");
      emit(AccountDeleteFailure(message: err.message.toString()));
    }
  }

  //! DELETE USER DATA
  Future<void> _deleteUserData() async {
    emit(UserDataDeletingLoading());
    try {
      await _firestore
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .get();
      log("DELETED USER DATA");
      await CacheData.clearData(clearData: true);
      log("DELETED CACHE DATA");
      emit(UserDataDeleteSuccess());
      log("ACCOUNT DELETED SUCCESSFULLY");
    } on FirebaseException catch (err) {
      log("${err.message} \n ${err.stackTrace} \n ${err.code.toString()} \n ${err.plugin}");
      emit(UserDataDeleteFailure(message: "Failed to delete user data"));
    }
  }

//! DELETE Chat History

  Future<void> _deleteChatHistory() async {
    CollectionReference messagesCollection = FirebaseFirestore.instance
        .collection('chat_history')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .collection('messages');
    emit(ChatDeletingLoading());
    try {
      final messagesQuerySnapshot = await messagesCollection.get();

      for (var doc in messagesQuerySnapshot.docs) {
        await messagesCollection.doc(doc.id).delete();
      }
      emit(ChatDeleteSuccess());
      log("CHAT HISTORY DELETED SUCCESSFULLY");
    } on FirebaseException catch (_) {
      emit(ChatDeleteFailure(message: "Failed to delete chat history"));
    }
  }

  //   Future<void> deleteAccount() async {
  //   emit(AccountDeleteLoading());
  //   try {
  //     final user = FirebaseAuth.instance.currentUser;
  //     if (user != null) {
  //       final uid = user.uid;
  //       final batch = FirebaseFirestore.instance.batch();
  //       batch.delete(
  //           FirebaseFirestore.instance.collection('chat_history').doc(uid));
  //       batch.delete(FirebaseFirestore.instance.collection('users').doc(uid));
  //       await batch
  //           .commit()
  //           .then((_) => log("DELETED CHAT HISTORY AND USER DATA"));

  //       await CacheData.clearData(clearData: true);
  //       log("DELETED CACHE DATA");

  //       await user.delete();
  //       log("DELETED USER ACCOUNT");

  //       await FirebaseAuth.instance.signOut();
  //       log("LOGGED OUT");

  //       emit(AccountDeleteSuccess(message: "Account deleted successfully"));
  //       log("ACCOUNT DELETED SUCCESSFULLY");
  //     }
  //   } catch (err) {
  //     emit(AccountFailure(message: err.toString()));
  //     log("ERROR: ${err.toString()}");
  //   }
  // }

  //? update user name

  Future<void> updateUserName({required String newName}) async {
    emit(ProfileUpdateLoading());
    try {
      await Future.delayed(const Duration(milliseconds: 400));
      await _firestore
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({'name': newName})
          .whenComplete(() => emit(ProfileUpdateSuccess()))
          .timeout(const Duration(seconds: 5),
              onTimeout: () => emit(ProfileUpdateFailure(
                  message: "There was an error, please try again")));
    } on FirebaseException catch (err) {
      emit(ProfileUpdateFailure(message: err.toString()));
    }
  }

  Future<void> updateProfile({
    String? name,
    String? email,
    String? phoneNumber,
    String? dob,
    String? height,
    String? weight,
    String? chronicDiseases,
    String? familyHistoryOfChronicDiseases,
  }) async {
    emit(ProfileUpdateLoading());
    try {
      await Future.delayed(const Duration(milliseconds: 400));
      await _firestore
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({
            'name': name,
            'email': email,
            'phoneNumber': phoneNumber,
            'dob': dob,
            'height': height,
            'weight': weight,
            'chronicDiseases': chronicDiseases,
            'familyHistoryOfChronicDiseases': familyHistoryOfChronicDiseases
          })
          .whenComplete(() => emit(ProfileUpdateSuccess()))
          .timeout(const Duration(seconds: 5),
              onTimeout: () => emit(ProfileUpdateFailure(
                  message: "There was an error, please try again")));
    } on FirebaseException catch (err) {
      emit(ProfileUpdateFailure(message: err.toString()));
    }
  }

  Future<void> reAuthenticateUser(String password) async {
    emit(AccountReAuthLoading());
    await Future.delayed(const Duration(milliseconds: 400));
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;

    if (user != null) {
      AuthCredential credential = EmailAuthProvider.credential(
          email: (user.email).toString(), password: password);
      try {
        await user.reauthenticateWithCredential(credential);
        emit(AccountReAuthSuccess());
        log('User re-authenticated successfully');
      } on FirebaseAuthException catch (err) {
        if (err.code == 'wrong-password' || err.code == 'invalid-credential') {
          emit(AccountReAuthFailure(message: 'Wrong password'));
        } else if (err.code == 'too-many-requests') {
          emit(AccountReAuthFailure(
              message: 'Too many requests, try again later'));
        } else {
          emit(AccountReAuthFailure(message: err.message.toString()));
        }
      }
    } else {
      log('No user found. Please sign in first.');
    }
  }

  Future<void> updatePassword(String newPassword) async {
    emit(AccountUpdatePasswordLoading());
    await Future.delayed(const Duration(milliseconds: 400));
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;

    if (user != null) {
      try {
        await user.updatePassword(newPassword).whenComplete(() {
          emit(AccountUpdatePasswordSuccess(
              message: 'Password updated successfully'));
          log('Password updated successfully');
        }).timeout(const Duration(seconds: 5),
            onTimeout: () => emit(AccountUpdatePasswordFailure(
                message: "There was an error, please try again")));
      } on FirebaseAuthException catch (err) {
        emit(AccountUpdatePasswordFailure(message: err.message.toString()));
        log('Password update failed: ${err.message}');
      }
    } else {
      log('No user found. Please sign in first.');
    }
  }

  Future<void> storeUserRating(int rating) async {
    emit(AccountRatingLoading());
    try {
      await Future.delayed(const Duration(milliseconds: 400));

      // Get the current user
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        emit(AccountRatingFailure(message: "User not logged in"));
        return;
      }

      // Store the rating in Firestore with a timeout
      final documentReference = await _firestore.collection('ratings').add({
        'userId': user.uid, // Store the user ID
        'rating': rating, // Store the rating value
        'timestamp': DateTime.now().toIso8601String(), // Store the timestamp
      }).timeout(const Duration(seconds: 5));

      // If successful, emit success state
      emit(AccountRatingSuccess());
      await CacheData.setData(key: "rating", value: rating);
      log('User rating stored successfully.');
    } on TimeoutException catch (_) {
      // Handle timeout
      emit(AccountRatingFailure(
          message: "There was an error, please try again"));
      log('Timeout: Rating storage failed.');
    } on FirebaseException catch (err) {
      // Handle Firebase errors
      emit(AccountRatingFailure(message: err.message.toString()));
      log('Error storing user rating: $err');
    } catch (err) {
      // Handle other errors
      emit(AccountRatingFailure(message: "An unexpected error occurred"));
      log('Unexpected error: $err');
    }
  }

  Future<void> getUserRating() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        log('User not logged in');
        return;
      }

      // Query ratings for the current user
      final querySnapshot = await _firestore
          .collection('ratings')
          .where('userId', isEqualTo: user.uid)
          .orderBy('timestamp', descending: true)
          .limit(1) // Get the most recent rating
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final ratingData = querySnapshot.docs.first.data();
        final int rating = ratingData['rating'];
        final String timestamp = ratingData['timestamp'];

        await CacheData.setData(key: "rating", value: rating);
        emit(AccountRatingResult(
            rating: rating, timestamp: timestamp)); // Pass timestamp here
        log('User rating: $rating, Timestamp: $timestamp');
      } else {
        log('User rating not found');
      }
    } on FirebaseException catch (err) {
      emit(AccountRatingFailure(message: err.toString()));
    }
  }

  // //? update email
  // Future<void> updateEmail({required String newEmail}) async {
  //   emit(ProfileUpdateLoading());
  //   try {
  //     await FirebaseService.updateEmailWithReauth(newEmail: newEmail, password: );

  //     await _firestore
  //         .collection('users')
  //         .doc(FirebaseAuth.instance.currentUser!.email)
  //         .update({'email': newEmail});

  //     emit(ProfileUpdateSuccess());
  //   } on Exception catch (err) {
  //     emit(ProfileUpdateFailure(message: err.toString()));
  //   }
  // }

  // //? update password
  // Future<void> updatePassword({required String newPassword}) async {
  //   emit(AccountLoading());
  //   try {
  //     await FirebaseAuth.instance.currentUser!.updatePassword(newPassword);
  //   } on Exception catch (err) {
  //     emit(AccountFailure(message: err.toString()));
  //   }
  // }

  // Future<void> loadPhoto() async {
  //   emit(AccountLoadingImage());
  //   try {
  //     String fileName = '${FirebaseAuth.instance.currentUser!.uid}.jpg';
  //     Reference storageRef = FirebaseStorage.instance.ref().child(fileName);

  //     final url = await storageRef.getDownloadURL();
  //     await CacheData.setData(key: "image", value: url);

  //     emit(AccountLoadedImage(urlImage: url));
  //   } catch (err) {
  //     emit(AccountLoadedFailure(message: err.toString()));
  //     log('Error occurred while loading the image: $err');
  //     log(err.toString());
  //   }
  // }

  // Future<void> uploadUserPhoto() async {
  //   emit(AccountUpdateImageLoading());
  //   try {
  //     final returnImage =
  //         await ImagePicker().pickImage(source: ImageSource.camera);
  //     if (returnImage != null) {
  //       String fileName = '${FirebaseAuth.instance.currentUser!.uid}.jpg';
  //       // String fileName =
  //       //     '${FirebaseAuth.instance.currentUser!.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
  //       Reference storageRef = FirebaseStorage.instance.ref().child(fileName);
  //       storageRef.putFile(File(returnImage.path));
  //       await loadPhoto();
  //       emit(AccountUpdateImageSuccess());
  //     } else {
  //       log("Image picking cancelled by user.");
  //       emit(AccountUpdateImageFailure(
  //           message: 'Image picking cancelled by user.'));
  //     }
  //   } catch (err) {
  //     log(err.toString());
  //     emit(AccountUpdateImageFailure(message: err.toString()));
  //   }
  // }
}
