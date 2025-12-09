import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/api_service.dart';
import 'dashboard.dart';
import 'signup_page.dart';

import '../config/app_color.dart';
import '../widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;
  String? errorMsg;

  void loginUser() async {
    setState(() => loading = true);

    final resp = await ApiService.login(
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    setState(() => loading = false);

    if (resp["success"] == true) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const ConcentricAnimationOnboarding(),
        ),
      );
    } else {
      setState(() => errorMsg = resp["message"]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        leading: const BackButton(),
        backgroundColor: Colors.white,
        elevation: 0,
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // --- TOP IMAGE + HERO --- //
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.3,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    right: 0,
                    child: Image.asset('assets/images/bg.png', width: 190),
                  ),
                  Positioned(
                    right: 0,
                    child: Hero(
                      tag: 'bikeAnimation',
                      child: Image.asset(
                        'assets/images/trusty.png',
                        width: 250,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --- FORM ZONE --- //
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome back",
                    style: GoogleFonts.sora(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "Enter your credentials to continue",
                    style: GoogleFonts.sora(
                      fontSize: 16,
                      color: AppColors.secondary,
                    ),
                  ),

                  const SizedBox(height: 30),

                  if (errorMsg != null)
                    Text(errorMsg!, style: const TextStyle(color: Colors.red)),

                  CustomTextField(
                    label: "Email ",
                    controller: emailController,
                    prefixIcon: Icons.person,
                  ),

                  const SizedBox(height: 15),

                  CustomTextField(
                    label: "Password",
                    controller: passwordController,
                    isPassword: true,
                    prefixIcon: Icons.lock,
                  ),

                  const SizedBox(height: 10),

                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "Forgot password?",
                      style: GoogleFonts.sora(color: Colors.black),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // --- LOGIN BUTTON --- //
                  loading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: loginUser,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.buttonYellow,
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          child: Text(
                            "Log in",
                            style: GoogleFonts.sora(
                              color: Colors.black,
                              fontSize: 18,
                            ),
                          ),
                        ),
                ],
              ),
            ),

            // --- SIGNUP BUTTON --- //
            CupertinoButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SignupPage()),
                );
              },
              padding: EdgeInsets.zero,
              child: const Text(
                "Don't have an account? Sign up",
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
