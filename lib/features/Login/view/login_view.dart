import 'package:flutter/material.dart';
import 'package:hungry/core/theme/app_colors.dart';
import 'package:hungry/features/Login/widget/login_form_card.dart';
import 'package:hungry/features/Login/widget/login_header.dart';
import 'package:hungry/core/widgets/continue_as_guest_button.dart';
import 'package:hungry/features/auth/data/auth_repo.dart';
import 'package:hungry/features/signup/view/Signup_view.dart';
import 'package:hungry/features/signup/widget/animated_burger_background.dart';
import 'package:hungry/shared/custom_snack.dart';
import 'package:hungry/root.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => LoginViewState();
}

class LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  final AuthRepo authRepo = AuthRepo();

  Future<void> login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);
    try {
      final user = await authRepo.login(
        emailController.text.trim(),
        passwordController.text.trim(),
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

  void _navigateToSignup() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => SignupView()),
    );
  }

  void _continueAsGuest() {
    authRepo.continueAsGuest();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => Root()),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Form(
          key: _formKey,
          child: Scaffold(
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Appcolors.background, Appcolors.green],
                ),
              ),
              child: Stack(
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
                      physics: BouncingScrollPhysics(),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 22),
                        child: Column(
                          children: [
                            const SizedBox(height: 40),

                            LoginHeader(),

                            const SizedBox(height: 35),

                            Container(
                              decoration: BoxDecoration(
                                color: Appcolors.white.withValues(alpha: .10),
                                borderRadius: BorderRadius.circular(32),
                                border: Border.all(
                                  color: Appcolors.white.withValues(alpha: .15),
                                ),
                              ),
                              child: LoginFormCard(
                                isLoading: isLoading,
                                onLogin: login,
                                onSignupTap: _navigateToSignup,
                                onForgotPassword: () {},
                                emailController: emailController,
                                passwordController: passwordController,
                              ),
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
      ),
    );
  }
}
