import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hungry/core/network/api_error.dart';
import 'package:hungry/core/theme/app_colors.dart';
import 'package:hungry/core/widgets/Guest_view.dart';
import 'package:hungry/features/Login/view/login_view.dart';
import 'package:hungry/features/Profile/widget/profile_bottom.dart';
import 'package:hungry/core/theme/custom_text.dart';
import 'package:hungry/features/Profile/widget/profile_card.dart';
import 'package:hungry/features/Profile/widget/profile_info_card.dart';
import 'package:hungry/features/auth/data/auth_repo.dart';
import 'package:hungry/features/auth/data/user_model.dart';
import 'package:hungry/shared/custom_snack.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController name = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController visa = TextEditingController();
  final TextEditingController deliveryAddress = TextEditingController();
  String selectedPaymentMethod = "Visa";
  String? selectedImage;
  bool isLoading = true;
  bool _firstTime = true;
  bool isGuest = false;
  bool isLoadingLogout = false;
  bool isLoadingupdate = false;
  UserModel? userModel;
  AuthRepo authRepo = AuthRepo();

  /// get profile data
  Future<void> getProfileData() async {
    try {
      final user = await authRepo.getProfileData();
      if (!mounted) return;
      setState(() {
        userModel = user;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      String errorMsg = e.toString();

      if (e is ApiError) {
        errorMsg = e.message;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: CustomText(errorMsg)));
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  /// logout
  Future<void> logout() async {
    if (!mounted) return;
    setState(() => isLoadingLogout = true);
    await authRepo.logout();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginView()),
    );
    setState(() => isLoadingLogout = false);
  }

  /// update profile data
  Future<void> updateProfileData() async {
    try {
      if (!mounted) return;
      setState(() => isLoadingupdate = true);
      final user = await authRepo.updateProfileData(
        name: name.text.trim(),
        email: email.text.trim(),
        address: deliveryAddress.text.trim(),
        imagepath: selectedImage,
        visa: visa.text.trim(),
      );
      if (!mounted) return;
      setState(() => isLoadingupdate = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(customSnackBarSuccess("Profile updated successfully"));
      setState(() => userModel = user);
      await getProfileData();
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoadingupdate = false);
      String errorMsg = "Failed to update profile";
      if (e is ApiError) {
        errorMsg = e.message;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: CustomText(errorMsg)));
    }
  }

  /// pick image
  Future<void> pickImage() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedImage != null) {
      setState(() {
        selectedImage = pickedImage.path;
      });
    }
  }

  // auto login
  Future<void> autoLogin() async {
    if (!mounted) return;
    final user = await authRepo.autoLogin();
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() {
      isGuest = authRepo.isGuest;
      userModel = user;
      isLoading = false;
    });
    if (user != null) {}
  }

  @override
  void initState() {
    if (!mounted) return;
    if (_firstTime) {
      _firstTime = false;
      autoLogin();
      getProfileData().then((_) {
        if (!mounted) return;
        name.text = userModel?.name ?? '';
        email.text = userModel?.email ?? '';
        deliveryAddress.text = userModel?.address ?? '';
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    password.dispose();
    visa.dispose();
    deliveryAddress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (isLoading) {
      return RefreshIndicator(
        displacement: 60,
        color: Appcolors.background,
        backgroundColor: Appcolors.white,
        onRefresh: () async {
          await getProfileData();
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
            extendBody: true,
            resizeToAvoidBottomInset: true,
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              title: CustomText(
                'PROFILE',
                style: TextStyle(
                  color: Appcolors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                IconButton(
                  onPressed: () {},
                  icon: SvgPicture.asset(
                    'assets/icon/settings.svg',
                    height: 24,
                    colorFilter: ColorFilter.mode(
                      Appcolors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: Appcolors.background,
            body: Skeletonizer(
              enabled: isLoading,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Appcolors.background, Color(0xFF0A3B1F)],
                  ),
                ),
                child: SafeArea(
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.manual,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ProfileCard(
                          onEditImage: pickImage,
                          name: userModel?.name ?? '',
                          subtitle:
                              'Keep your profile up to date for a better experience.',
                          selectedImage: selectedImage,
                          imageUrl: userModel?.image,
                        ),
                        SizedBox(height: 24),
                        ProfileInfoCard(
                          nameController: name,
                          emailController: email,
                          deliveryAddressController: deliveryAddress,
                          passwordController: password,
                          numberVisa: userModel?.visa,
                          selectedPaymentMethod: selectedPaymentMethod,
                          onPaymentMethodChanged: (value) {
                            setState(() {
                              selectedPaymentMethod = value;
                            });
                          },
                          visaController: visa,
                          isVisa: userModel?.visa == null ? true : false,
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (isGuest) {
      return GuestView(
        title: 'Your profile is waiting',
        description: 'Sign in to  for you can see your profile.',
      );
    }
    return RefreshIndicator(
      displacement: 60,
      color: Appcolors.background,
      backgroundColor: Appcolors.white,
      onRefresh: () async {
        await getProfileData();
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          extendBody: true,
          resizeToAvoidBottomInset: true,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            actions: [
              IconButton(
                onPressed: () {},
                icon: SvgPicture.asset(
                  'assets/icon/settings.svg',
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    Appcolors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Appcolors.background,
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Appcolors.background, Color(0xFF0A3B1F)],
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.manual,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                child: Skeletonizer(
                  enabled: isLoading,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ProfileCard(
                        onEditImage: pickImage,
                        name: userModel?.name ?? '',
                        subtitle:
                            'Keep your profile up to date for a better experience.',
                        selectedImage: selectedImage,
                        imageUrl: userModel?.image,
                      ),

                      const SizedBox(height: 24),

                      ProfileInfoCard(
                        nameController: name,
                        emailController: email,
                        deliveryAddressController: deliveryAddress,
                        passwordController: password,
                        numberVisa: userModel?.visa,
                        selectedPaymentMethod: selectedPaymentMethod,
                        onPaymentMethodChanged: (value) {
                          setState(() {
                            selectedPaymentMethod = value;
                          });
                        },
                        visaController: visa,
                        isVisa: userModel?.visa == null,
                      ),

                      const SizedBox(height: 30),

                      ProfileBottomActions(
                        isLoadingUpdate: isLoadingupdate,
                        isLoadingLogout: isLoadingLogout,
                        onEditTap: updateProfileData,
                        Logout: logout,
                        isLoadingSkeleton: isLoading,
                      ),
                      const SizedBox(height: 140),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
