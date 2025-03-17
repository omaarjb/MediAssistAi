import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum SocialAuthState { initial, loading, authenticated, unauthenticated, error }

class SocialAuthCubit extends Cubit<SocialAuthState> {
  SocialAuthCubit() : super(SocialAuthState.initial);

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _errorMessage;

  String? get errorMessage => _errorMessage;

  void _resetError() {
    _errorMessage = null;
  }

  Future<void> signInWithGoogle() async {
    try {
      _resetError();
      emit(SocialAuthState.loading);

      // Sign out from Google to clear the cached account
      await GoogleSignIn().signOut();

      // Attempt to sign in with Google
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        emit(SocialAuthState.unauthenticated);
        return; // User canceled the sign-in
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      // Check if the user exists in Firestore
      await _checkAndCreateUserDocument(userCredential.user!);

      emit(SocialAuthState.authenticated);
    } catch (e) {
      _errorMessage = "Error signing in with Google: $e";
      emit(SocialAuthState.error);
      print(_errorMessage); // Log the error
    }
  }

  Future<void> signInWithFacebook() async {
    try {
      _resetError();
      emit(SocialAuthState.loading);

      // Log out from Facebook to clear the cached account
      await FacebookAuth.instance.logOut();

      final LoginResult loginResult = await FacebookAuth.instance.login();
      if (loginResult.status != LoginStatus.success) {
        emit(SocialAuthState.unauthenticated);
        return; // User canceled or failed to log in
      }

      final OAuthCredential facebookAuthCredential =
          FacebookAuthProvider.credential(loginResult.accessToken!.tokenString);
      final userCredential =
          await _firebaseAuth.signInWithCredential(facebookAuthCredential);

      // Check if the user exists in Firestore
      await _checkAndCreateUserDocument(userCredential.user!);

      emit(SocialAuthState.authenticated);
    } catch (e) {
      _errorMessage = "Error signing in with Facebook: $e";
      emit(SocialAuthState.error);
      print(_errorMessage); // Log the error
    }
  }

  Future<void> signInWithApple() async {
    try {
      _resetError();
      emit(SocialAuthState.loading);

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        webAuthenticationOptions: WebAuthenticationOptions(
          clientId: '', // Use your actual iOS app's clientId
          redirectUri: Uri.parse(
              'https://dr-ai-97349.firebaseapp.com/__/auth/handler'), // Your redirect URI
        ),
      );

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final userCredential =
          await _firebaseAuth.signInWithCredential(oauthCredential);

      // Check if the user exists in Firestore
      await _checkAndCreateUserDocument(userCredential.user!);

      emit(SocialAuthState.authenticated);
    } catch (e) {
      _errorMessage = "Error signing in with Apple: $e";
      emit(SocialAuthState.error);
      print(_errorMessage); // Log the error
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      await GoogleSignIn().signOut(); // Sign out from Google
      await FacebookAuth.instance.logOut(); // Sign out from Facebook
      emit(SocialAuthState.unauthenticated);
    } catch (e) {
      _errorMessage = "Error signing out: $e";
      emit(SocialAuthState.error);
      print(_errorMessage); // Log the error
    }
  }

  // Helper method to check if a user document exists and create one if it doesn't
  Future<void> _checkAndCreateUserDocument(User user) async {
    final userDoc = await _firestore.collection('users').doc(user.uid).get();

    if (!userDoc.exists) {
      // Create a new user document in Firestore with default values
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'name': user.displayName ?? 'New User', // Use display name or a default
        'phoneNumber': '', // Default empty value
        'dob': '', // Default empty value
        'gender': '', // Default empty value
        'bloodType': '', // Default empty value
        'height': '', // Default empty value
        'weight': '', // Default empty value
        'chronicDiseases': '', // Default empty value
        'familyHistoryOfChronicDiseases': '', // Default empty value
      });
    }
  }

  void resetState() {
    emit(SocialAuthState.initial);
  }
}
