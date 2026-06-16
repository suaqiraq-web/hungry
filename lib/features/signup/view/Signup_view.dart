import 'package:flutter/material.dart';
import 'package:hungry/core/theme/app_colors.dart';
import 'package:hungry/features/Login/view/login_view.dart';
import 'package:hungry/features/auth/data/auth_repo.dart';
import 'package:hungry/core/widgets/continue_as_guest_button.dart';
import 'package:hungry/features/signup/widget/animated_burger_background.dart';
import 'package:hungry/features/signup/widget/signup_form_card.dart';
import 'package:hungry/features/signup/widget/signup_header.dart';
import 'package:hungry/root.dart';
import 'package:hungry/shared/custom_snack.dart';

class SignupView extends StatefulWidget {
  const SignupView({super.key});

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool isLoading = false;
  final AuthRepo authRepo = AuthRepo();

  Future<void> signup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);
    try {
      final user = await authRepo.signup(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (user != null) {
        if (!mounted) return;
        setState(() => isLoading = false);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Root()),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(customSnackBarerror(e.toString()));
    }
  }

  void _openLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginView()),
    );
  }

  void _continueAsGuest() {
    authRepo.continueAsGuest();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const Root()),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Form(
        key: _formKey,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            backgroundColor: Appcolors.white,
            body: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Appcolors.background, Color(0xFF0F6A35)],
                    ),
                  ),
                ),
                AnimatedBurgerBackground(),

                SafeArea(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: Column(
                        children: [
                          const SizedBox(height: 30),

                          const SignupHeader(),

                          const SizedBox(height: 30),

                          SignupFormCard(
                            isLoading: isLoading,
                            onSignup: signup,
                            onSwitchToLogin: _openLogin,
                            name: _nameController,
                            email: _emailController,
                            password: _passwordController,
                          ),

                          const SizedBox(height: 20),

                          ContinueAsGuestButton(onTap: _continueAsGuest),

                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
