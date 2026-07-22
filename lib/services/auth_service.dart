import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:job_interview_quiz_app/routes/appRoutes.dart';
import '../models/user_model.dart';

class AuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Observable state
  final Rx<User?> currentUser = Rx<User?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Listen to auth state changes
    _auth.authStateChanges().listen((User? user) {
      currentUser.value = user;
      if (user != null) {
        // Check if email is verified
        if (user.emailVerified) {
          Get.offAllNamed(AppRoutes.homeRoute);
        } else {
          Get.offAllNamed(AppRoutes.emailVerification);
        }
      } else {
        Get.offAllNamed(AppRoutes.loginRoute);
      }
    });
  }

  // Sign Up with Email and Password
  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Create user with email and password
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password,
          );

      User? user = userCredential.user;

      if (user != null) {
        // Send email verification
        await user.sendEmailVerification();

        // Save user data to Firestore
        UserModel userModel = UserModel(
          uid: user.uid,
          name: name.trim(),
          email: email.trim(),
          createdAt: DateTime.now(),
          photoUrl: user.photoURL ?? '',
          quizHistory: [],
          totalScore: 0,
          quizzesTaken: 0,
        );

        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(userModel.toMap());

        // Navigate to verification screen
        Get.offAllNamed(AppRoutes.emailVerification);
      }
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    } catch (e) {
      errorMessage.value = 'Something went wrong. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  // Sign In with Email and Password
  Future<void> signIn({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        if (!user.emailVerified) {
          // If email is not verified, send verification again
          await user.sendEmailVerification();
          Get.offAllNamed(AppRoutes.emailVerification);
          return;
        }

        // Update Firestore last login
        await _firestore.collection('users').doc(user.uid).update({
          'lastLogin': FieldValue.serverTimestamp(),
        });

        // Navigate to home
        Get.offAllNamed(AppRoutes.homeRoute);
      }
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    } catch (e) {
      errorMessage.value = 'Something went wrong. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  // Resend Verification Email
  Future<void> resendVerificationEmail() async {
    try {
      isLoading.value = true;
      User? user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        Get.snackbar(
          'Success',
          'Verification email sent! Please check your inbox.',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to send verification email. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Check Email Verification Status
  Future<bool> checkEmailVerification() async {
    try {
      await _auth.currentUser?.reload();
      User? user = _auth.currentUser;
      if (user != null && user.emailVerified) {
        // Update Firestore
        await _firestore.collection('users').doc(user.uid).update({
          'emailVerified': true,
        });
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Send Password Reset Email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _auth.sendPasswordResetEmail(email: email.trim());

      Get.back();
      Get.snackbar(
        'Success',
        'Password reset email sent! Please check your inbox.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    } finally {
      isLoading.value = false;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to sign out. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Delete Account
  Future<void> deleteAccount() async {
    try {
      isLoading.value = true;
      User? user = _auth.currentUser;

      if (user != null) {
        // Delete user data from Firestore
        await _firestore.collection('users').doc(user.uid).delete();
        // Delete user from Authentication
        await user.delete();
        Get.snackbar(
          'Success',
          'Account deleted successfully.',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete account. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Get User Data from Firestore
  Future<UserModel?> getUserData() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return null;

      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Update User Score
  Future<void> updateUserScore(int score, int totalQuestions) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return;

      DocumentReference userRef = _firestore.collection('users').doc(user.uid);

      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(userRef);
        if (!snapshot.exists) return;

        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

        int currentTotalScore = data['totalScore'] ?? 0;
        int currentQuizzesTaken = data['quizzesTaken'] ?? 0;

        transaction.update(userRef, {
          'totalScore': currentTotalScore + score,
          'quizzesTaken': currentQuizzesTaken + 1,
          'quizHistory': FieldValue.arrayUnion([
            {
              'date': DateTime.now().toIso8601String(),
              'score': score,
              'totalQuestions': totalQuestions,
            },
          ]),
        });
      });
    } catch (e) {
      print('Error updating user score: $e');
    }
  }

  // Handle Firebase Auth Errors
  void _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        errorMessage.value = 'No user found with this email.';
        break;
      case 'wrong-password':
        errorMessage.value = 'Incorrect password. Please try again.';
        break;
      case 'email-already-in-use':
        errorMessage.value = 'This email is already registered.';
        break;
      case 'invalid-email':
        errorMessage.value = 'Please enter a valid email address.';
        break;
      case 'weak-password':
        errorMessage.value = 'Password should be at least 6 characters.';
        break;
      case 'too-many-requests':
        errorMessage.value = 'Too many requests. Please try again later.';
        break;
      case 'network-request-failed':
        errorMessage.value = 'Network error. Please check your connection.';
        break;
      default:
        errorMessage.value = 'An error occurred. Please try again.';
    }
  }

  // Get current user
  User? getCurrentUser() => _auth.currentUser;

  // Check if user is authenticated
  bool isAuthenticated() => _auth.currentUser != null;

  // Check if email is verified
  bool isEmailVerified() => _auth.currentUser?.emailVerified ?? false;
}
