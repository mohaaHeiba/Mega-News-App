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
import 'package:mega_news_app/features/auth/presentation/pages/email_verification_page.dart';
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
    currentPage.value = 2;
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

  /// ------------------ Auth Actions ------------------

  Future<void> signUp(String name, String email, String password) async {
    try {
      isLoading.value = true;
      // --- check net first ---
      if (!await NetworkService.isConnected) {
        throw const NetworkAppException('No internet connection.');
      }
      // ------------------------

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

      customSnackbar(
        title: 'Account Created Successfully!',
        message: 'A verification link has been sent to your email.',
        color: AppColors.success,
      );
      Get.to(EmailVerificationPage(), transition: Transition.fadeIn);
    } on NetworkAppException {
      customSnackbar(
        title: 'No Connection',
        message: 'Please check your internet connection and try again.',
        color: AppColors.error,
      );
    } on UserAlreadyExistsException {
      customSnackbar(
        title: 'Email Already Registered',
        message: 'This email is already in use. Please log in instead.',
        color: AppColors.warning,
      );
    } on AuthAppException catch (e) {
      customSnackbar(
        title: 'Signup Error',
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

  Future<void> signIn({required String email, required String password}) async {
    try {
      isLoading.value = true;
      if (!await NetworkService.isConnected) {
        throw const NetworkAppException('No internet connection.');
      }
      // ------------------------

      final user = await auth.signIn(email: email, password: password);

      final authEntity = AuthEntity(
        id: user.id,
        name: user.name,
        email: user.email,
        createdAt: user.createdAt ?? DateTime.now().toIso8601String(),
      );

      await localAuth.saveAuthData(authEntity);

      customSnackbar(
        title: 'Welcome Back!',
        message: 'You’ve signed in successfully.',
        color: AppColors.success,
      );
    } on NetworkAppException {
      customSnackbar(
        title: 'No Connection',
        message: 'Please check your internet connection and try again.',
        color: AppColors.error,
      );
    } on MissingDataException {
      customSnackbar(
        title: 'Invalid Credentials',
        message: 'Incorrect email or password. Please try again.',
        color: AppColors.warning,
      );
    } on AuthAppException catch (e) {
      customSnackbar(
        title: 'Sign-in Error',
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

  Future<void> googleSignIn() async {
    try {
      isLoading.value = true;
      if (!await NetworkService.isConnected) {
        throw const NetworkAppException('No internet connection.');
      }
      // ------------------------

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
      isLoading.value = true;
      // --- check net first ---
      if (!await NetworkService.isConnected) {
        throw const NetworkAppException('No internet connection.');
      }
      // ------------------------

      await auth.logout();
      await localAuth.clearAuthData();

      customSnackbar(
        title: 'Logged Out',
        message: 'You have been logged out successfully.',
        color: AppColors.success,
      );
      goToLogin();
    } on NetworkAppException {
      customSnackbar(
        title: 'No Connection',
        message: 'Please check your internet connection and try again.',
        color: AppColors.error,
      );
    } on UserNotFoundException catch (e) {
      customSnackbar(
        title: 'User Not Found',
        message: e.message,
        color: AppColors.error,
      );
    } on AuthAppException catch (e) {
      customSnackbar(
        title: 'Logout Error',
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

  Future<void> deleteAccount() async {
    try {
      isLoading.value = true;
      if (!await NetworkService.isConnected) {
        throw const NetworkAppException('No internet connection.');
      }

      final currentUser = await localAuth.getAuthData();
      if (currentUser == null) {
        throw const UserNotFoundException('No user is currently logged in.');
      }

      await auth.deleteAccount(currentUser.id);
      await localAuth.clearAuthData();

      customSnackbar(
        title: 'Account Deleted',
        message: 'Your account has been permanently removed.',
        color: AppColors.success,
      );
      goToLogin();
    } on NetworkAppException {
      customSnackbar(
        title: 'No Connection',
        message: 'Please check your internet connection and try again.',
        color: AppColors.error,
      );
    } on UserNotFoundException catch (e) {
      customSnackbar(
        title: 'User Not Found',
        message: e.message,
        color: AppColors.error,
      );
    } on AuthAppException catch (e) {
      customSnackbar(
        title: 'Deletion Failed',
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

  Future<void> updatePassword(String newPassword) async {
    try {
      isLoading.value = true;
      // --- check net first ---
      if (!await NetworkService.isConnected) {
        throw const NetworkAppException('No internet connection.');
      }
      // ------------------------

      await auth.updatePassword(newPassword);

      customSnackbar(
        title: 'Password Updated',
        message: 'Your password has been changed successfully.',
        color: AppColors.success,
      );

      backToLogin();
    } on NetworkAppException {
      customSnackbar(
        title: 'No Connection',
        message: 'Please check your internet connection and try again.',
        color: AppColors.error,
      );
    } on AuthAppException catch (e) {
      customSnackbar(
        title: 'Update Error',
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

  Future<void> resetPassword() async {
    final email = emailController.text.trim();

    try {
      // This check is fine here before loading
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
