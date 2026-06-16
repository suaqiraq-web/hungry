import 'package:flutter/material.dart';
import 'package:hungry/features/auth/data/auth_repo.dart';
import 'package:hungry/features/auth/data/user_model.dart';

class UserProvider extends ChangeNotifier {
  final AuthRepo authRepo = AuthRepo();

  UserModel? user;
  bool isGuest = false;
  bool isLoading = true;
  bool isLoadingUpdate = false;
  bool isLoadingLogout = false;

  Future<void> initialize() async {
    if (!isLoading) return;

    await autoLogin();

    if (!isGuest) {
      await getProfileData();
    }

    isLoading = false;
    notifyListeners();
  }

Future<void> autoLogin() async {
  user = await authRepo.autoLogin();
  isGuest = authRepo.isGuest;
  notifyListeners();
}

Future<void> getProfileData() async {
  if (isGuest) return;

  user = await authRepo.getProfileData();
  notifyListeners();
}

Future<void> updateProfile({
  required String name,
  required String email,
  required String address,
  required String visa,
  String? imagePath,
}) async {
  try {
    isLoadingUpdate = true;
    notifyListeners();

    user = await authRepo.updateProfileData(
      name: name,
      email: email,
      address: address,
      visa: visa,
      imagepath: imagePath,
    );
  } catch (e) {
    rethrow;
  } finally {
    isLoadingUpdate = false;
    notifyListeners();
  }
}

  Future<void> logout() async {
    isLoadingLogout = true;
    notifyListeners();

    await authRepo.logout();

    user = null;
    isGuest = true;

    isLoadingLogout = false;
    notifyListeners();
  }
}