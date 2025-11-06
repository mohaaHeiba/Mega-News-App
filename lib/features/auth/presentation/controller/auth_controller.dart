import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mega_news_app/core/custom/custom_snackbar.dart';
import 'package:mega_news_app/core/errors/app_exception.dart';
import 'package:mega_news_app/core/routes/app_pages.dart';
import 'package:mega_news_app/core/service/network_service.dart';
import 'package:mega_news_app/core/theme/app_colors.dart';
import 'package:mega_news_app/features/auth/data/auth_local.dart';
import 'package:mega_news_app/features/auth/data/auth_service.dart';
import 'package:mega_news_app/features/auth/domain/entity/auth_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthController extends GetxController {
  final AuthService auth = AuthService();
  final AuthLocalService localAuth = AuthLocalService();

  // ------------------ Form & Page ------------------
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final PageController pageController = PageController(initialPage: 0);
  final currentPage = 0.obs;

  void onPageChanged(int index) => currentPage.value = index;

  // ------------------ Text Controllers ------------------
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passController = TextEditingController();
  final confirmPassController = TextEditingController();
  final isPasswordObscure = true.obs;
  final isConfirmPasswordObscure = true.obs;
  final isLoading = false.obs;

  // ------------------ Page Navigation ------------------
  // PageController واحد فقط

  // ================= Page Navigation =================
  Future<void> goToRegister() async {
    pageController.animateToPage(
      1,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
    await clearControllers();
  }

  Future<void> goToLogin() async {
    pageController.animateToPage(
      0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
    await clearControllers();
  }

  Future<void> goToForgotPass() async {
    currentPage.value = 2; // تتوافق مع صفحة ForgotPassword
    await Future.delayed(const Duration(milliseconds: 100));
    pageController.jumpToPage(2);
    await clearControllers();
  }

  Future<void> backFromForgotPass() async {
    await Future.delayed(const Duration(milliseconds: 100));
    pageController.jumpToPage(0);
    await clearControllers();
  }

  Future<void> goToNewPass() async {
    await Future.delayed(const Duration(milliseconds: 100));
    pageController.jumpToPage(3);
    await clearControllers();
  }

  Future<void> backToLogin() async {
    await Future.delayed(const Duration(milliseconds: 100));
    pageController.jumpToPage(0);
    await clearControllers();
  }

  // ------------------ Auth Actions ------------------
  Future<void> signUp(String name, String email, String password) async {
    try {
      isLoading.value = true;
      final user = await auth.signUp(
        name: name,
        email: email,
        password: password,
      );

      final authEntity = AuthEntity(
        id: user.id,
        name: user.name,
        email: user.email,
        createdAt: user.createdAt ?? DateTime.now().toIso8601String(),
      );

      await localAuth.saveAuthData(authEntity);

      // --- Updated ---
      customSnackbar(
        title: 'Account Created',
        message: 'Please verify your email.',
        color: AppColors.success,
      );
      goToLogin();
    } catch (e) {
      // --- Updated ---
      customSnackbar(
        title: 'Signup Error',
        message: e.toString(),
        color: AppColors.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    try {
      isLoading.value = true;
      final user = await auth.signIn(email: email, password: password);

      final authEntity = AuthEntity(
        id: user.id,
        name: user.name,
        email: user.email,
        createdAt: user.createdAt ?? DateTime.now().toIso8601String(),
      );

      await localAuth.saveAuthData(authEntity);

      // --- Updated and Corrected ---
      customSnackbar(
        title: 'Welcome!',
        message: 'Signed in successfully.',
        color: AppColors.success,
      );
      // Get.offAllNamed(AppPages.loyoutPage);
    } catch (e) {
      // --- Updated ---
      customSnackbar(
        title: 'Login Error',
        message: e.toString(),
        color: AppColors.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> googleSignIn() async {
    try {
      isLoading.value = true;
      final user = await auth.googleSignIN();

      final authEntity = AuthEntity(
        id: user.id,
        name: user.name,
        email: user.email,
        createdAt: user.createdAt ?? DateTime.now().toIso8601String(),
      );

      await localAuth.saveAuthData(authEntity);
      customSnackbar(
        title: 'Welcome!',
        message: 'Signed in successfully with Google.',
        color: AppColors.success,
      );
      // Get.offAllNamed(AppPages.loyoutPage);
    } on NetworkAppException {
      customSnackbar(
        title: 'No Connection',
        message: 'Please check your internet connection and try again.',
        color: AppColors.error,
      );
    } on AuthAppException catch (e) {
      customSnackbar(
        title: 'Sign-in Error',
        message: e.message,
        color: AppColors.warning,
      );
    } catch (e) {
      customSnackbar(
        title: 'Unexpected Error',
        message: 'Something went wrong. Please try again later.',
        color: AppColors.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await auth.logout();
      await localAuth.clearAuthData();
      // --- Updated ---
      customSnackbar(
        title: 'Logged Out',
        message: 'You have been logged out successfully.',
        color: AppColors.success,
      );
      goToLogin();
    } catch (e) {
      // --- Updated ---
      customSnackbar(
        title: 'Logout Error',
        message: e.toString(),
        color: AppColors.error,
      );
    }
  }

  Future<void> deleteAccount() async {
    try {
      final currentUser = await localAuth.getAuthData();
      if (currentUser == null) throw 'No user logged in';

      await auth.deleteAccount(currentUser.id);
      await localAuth.clearAuthData();

      // --- Updated ---
      customSnackbar(
        title: 'Deleted',
        message: 'Account has been removed.',
        color: AppColors.success,
      );
      goToLogin();
    } catch (e) {
      // --- Updated ---
      customSnackbar(
        title: 'Delete Error',
        message: e.toString(),
        color: AppColors.error,
      );
    }
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      isLoading.value = true;
      await auth.updatePassword(newPassword);

      customSnackbar(
        title: 'Password Updated',
        message: 'Your password has been changed successfully.',
        color: AppColors.success,
      );

      backToLogin();
    } on AuthAppException catch (e) {
      customSnackbar(
        title: 'Error',
        message: e.message,
        color: AppColors.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resetPassword() async {
    final email = emailController.text.trim();

    try {
      if (!await NetworkService.isConnected) {
        throw const NetworkAppException('No internet connection.');
      }

      isLoading.value = true;

      await auth.resetPassword(email);

      customSnackbar(
        title: 'Email Sent',
        message: 'A password reset link has been sent to your email.',
        color: AppColors.success,
      );
      emailController.clear();
    } on UserNotFoundException {
      customSnackbar(
        title: 'User Not Found',
        message: 'No account found with this email.',
        color: AppColors.error,
      );
    } on NetworkAppException {
      customSnackbar(
        title: 'No Internet',
        message: 'Please check your connection and try again.',
        color: AppColors.warning,
      );
    } on AuthAppException catch (e) {
      customSnackbar(
        title: 'Error',
        message: e.message,
        color: AppColors.error,
      );
    } catch (e) {
      customSnackbar(
        title: 'Unexpected Error',
        message: 'Something went wrong. Please try again later.',
        color: AppColors.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  final supabase = Supabase.instance.client;

  @override
  void onInit() {
    super.onInit();

    supabase.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      final user = data.session?.user;

      if (event == AuthChangeEvent.passwordRecovery) {
        goToNewPass();
        return;
      }

      if (event == AuthChangeEvent.signedIn && user != null) {
        if (user.emailConfirmedAt != null) {
          GetStorage().write('loginBefore', true);
          Get.offAllNamed(AppPages.loyoutPage);
        }
      }
    });
  }

  // ------------------ Helpers ------------------
  Future<void> clearControllers() async {
    nameController.clear();
    emailController.clear();
    passController.clear();
    confirmPassController.clear();
    isPasswordObscure.value = true;
    isConfirmPasswordObscure.value = true;
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passController.dispose();
    confirmPassController.dispose();
    pageController.dispose();
    super.onClose();
  }
}
