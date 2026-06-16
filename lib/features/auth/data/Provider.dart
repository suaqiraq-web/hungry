import 'package:flutter/material.dart';
import 'package:hungry/features/auth/data/auth_repo.dart';
import 'package:hungry/features/auth/data/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepo authRepo;

  AuthProvider(this.authRepo);

  UserModel? userModel;
  bool isGuest = false;
  bool isLoading = false;

  Future<void> autoLogin() async {
    if (userModel != null) return;

    isLoading = true;
    notifyListeners();

    try {
      final user = await authRepo.autoLogin();

      await Future.delayed(const Duration(seconds: 1));

      userModel = user;
      isGuest = authRepo.isGuest;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getProfileData() async {
    if (userModel != null) return;

    isLoading = true;
    notifyListeners();

    try {
      userModel = await authRepo.getProfileData();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}