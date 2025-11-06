import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mega_news_app/core/errors/app_exception.dart';
import 'package:mega_news_app/core/service/network_service.dart';
import 'package:mega_news_app/features/auth/domain/model/auth_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final supabase = Supabase.instance.client;

  // ================= Sign Up =================
  Future<AuthModel> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final res = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
        emailRedirectTo: 'io.supabase.flutter://login-callback/',
      );

      if (res.user != null) {
        final data = AuthModel(
          id: res.user!.id,
          name: name,
          email: email,
          createdAtDate: DateTime.now(),
        );

        await supabase.from('profiles').insert(data.toMap());
        return data;
      } else {
        throw const AuthAppException(
          'Signup failed - no user created',
          'signup_failed',
        );
      }
    } on AuthApiException catch (e) {
      if (e.code == 'user_already_exists' ||
          e.code == 'email_exists' ||
          e.statusCode == 409 ||
          e.statusCode == 422) {
        throw const UserAlreadyExistsException('User already registered');
      }
      throw AuthAppException(e.message, e.code);
    } on SocketException {
      throw const NetworkAppException('No internet connection.');
    } catch (e) {
      throw AuthAppException('Unexpected error: ${e.toString()}');
    }
  }

  // ================= Sign In =================
  Future<AuthModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final res = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final profileResponse = await supabase
          .from('profiles')
          .select('*')
          .eq('id', res.user!.id)
          .maybeSingle();

      if (profileResponse == null) {
        throw const MissingDataException('Profile not found.');
      }

      return AuthModel.fromMap(profileResponse);
    } on AuthApiException catch (e) {
      if (e.code == 'invalid_credentials' ||
          e.statusCode == 400 ||
          e.message.toLowerCase().contains('invalid login credentials')) {
        throw const MissingDataException('Invalid login credentials');
      }
      throw AuthAppException(e.message, e.code);
    } on SocketException {
      throw const NetworkAppException('No internet connection.');
    } catch (e) {
      throw AuthAppException('Unexpected error: ${e.toString()}');
    }
  }

  // ================= Reset Password =================
  Future<void> resetPassword(String email) async {
    try {
      await supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: 'io.supabase.flutter://reset-password/',
      );
    } on AuthApiException catch (e) {
      if (e.code == 'invalid_credentials' ||
          e.statusCode == 400 ||
          e.message.toLowerCase().contains('email not found')) {
        throw const UserNotFoundException('No account found for this email.');
      }
      throw AuthAppException(e.message, e.code);
    } on SocketException {
      throw const NetworkAppException('No internet connection.');
    } catch (_) {
      throw const AuthAppException('Something went wrong. Please try again.');
    }
  }

  // ================= Update Password =================
  Future<void> updatePassword(String newPassword) async {
    try {
      await supabase.auth.updateUser(UserAttributes(password: newPassword));
    } on AuthApiException catch (e) {
      throw AuthAppException(e.message, e.code);
    } on SocketException {
      throw const NetworkAppException('No internet connection.');
    } catch (e) {
      throw const AuthAppException('Unexpected error while updating password.');
    }
  }

  // ================= Google Sign-In =================
  Future<AuthModel> googleSignIN() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;

      await googleSignIn.initialize(
        clientId: dotenv.env['CLIENT_ID']!,
        serverClientId: dotenv.env['SERVER_CLIENT_ID']!,
      );

      final googleUser = await googleSignIn.authenticate();
      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw const AuthAppException(
          'Google Sign-In failed: Missing ID Token.',
        );
      }

      final response = await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      );

      final user = response.user;
      if (user == null || response.session == null) {
        throw const AuthAppException(
          'Google sign-in failed: No session created.',
        );
      }

      final profileResponse = await supabase
          .from('profiles')
          .select('*')
          .eq('id', user.id)
          .maybeSingle();

      if (profileResponse == null) {
        final newProfile = AuthModel(
          id: user.id,
          name: user.userMetadata?['name'] ?? user.email ?? '',
          email: user.email ?? '',
          createdAtDate: DateTime.now(),
        );
        await supabase.from('profiles').insert(newProfile.toMap());
        return newProfile;
      } else {
        return AuthModel.fromMap(profileResponse);
      }
    } on SocketException {
      throw const NetworkAppException('No internet connection.');
    } catch (e) {
      throw AuthAppException('Unexpected error during Google Sign-In: $e');
    }
  }

  // ================= Sign Out =================
  Future<void> logout() async {
    try {
      await supabase.auth.signOut();
    } on AuthException catch (e) {
      throw AuthAppException('Logout failed: ${e.message}');
    } catch (e) {
      throw UserNotFoundException('Unexpected error during logout: $e');
    }
  }

  final supabaseAdmin = SupabaseClient(
    dotenv.env['SUPABASE_URL']!,
    dotenv.env['SUPABASE_SERVICEROLE']!,
  );

  Future<void> deleteAccount(String userId) async {
    if (!await NetworkService.isConnected) {
      throw const NetworkAppException('No internet connection.');
    }

    try {
      // Delete profile data
      await supabase.from('profiles').delete().eq('id', userId);
      await supabaseAdmin.auth.admin.deleteUser(userId);

      await supabase.auth.signOut();
    } on AuthException catch (e) {
      throw AuthAppException(e.message);
    } catch (e) {
      throw UserNotFoundException('Failed to delete account: $e');
    }
  }

  // ================= Check Logged In =================
  bool get isLoggedIn => supabase.auth.currentUser != null;
}
