import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mega_news_app/features/auth/data/auth_local.dart';
import 'package:mega_news_app/features/auth/data/auth_service.dart';
import 'package:mega_news_app/features/auth/domain/entity/auth_entity.dart';

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
  Future<void> goToRegister() async => pageController.animateToPage(
    1,
    duration: const Duration(milliseconds: 400),
    curve: Curves.easeInOut,
  );

  Future<void> goToLogin() async => pageController.animateToPage(
    0,
    duration: const Duration(milliseconds: 400),
    curve: Curves.easeInOut,
  );

  Future<void> goToForgotPass() async => pageController.jumpToPage(2);
  Future<void> goToNewPass() async => pageController.jumpToPage(3);

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

      Get.snackbar('Account Created', 'Please verify your email.');
      goToLogin();
    } catch (e) {
      Get.snackbar('Signup Error', e.toString());
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

      Get.snackbar('Welcome', 'Signed in successfully');
      Get.offAllNamed('/home');
    } catch (e) {
      Get.snackbar('Login Error', e.toString());
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
      Get.snackbar('Welcome', 'Signed in with Google');
      Get.offAllNamed('/home');
    } catch (e) {
      Get.snackbar('Google Sign-In Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await auth.logout();
      await localAuth.clearAuthData();
      Get.snackbar('Logged Out', 'You have been logged out successfully');
      goToLogin();
    } catch (e) {
      Get.snackbar('Logout Error', e.toString());
    }
  }

  Future<void> deleteAccount() async {
    try {
      final currentUser = await localAuth.getAuthData();
      if (currentUser == null) throw 'No user logged in';

      await auth.deleteAccount(currentUser.id);
      await localAuth.clearAuthData();

      Get.snackbar('Deleted', 'Account has been removed');
      goToLogin();
    } catch (e) {
      Get.snackbar('Delete Error', e.toString());
    }
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
