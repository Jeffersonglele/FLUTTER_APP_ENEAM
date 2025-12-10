import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import 'home.dart' as home_page;
import 'signup_page.dart';

import '../config/app_color.dart' as app_color;
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
    // Masquer le clavier
    FocusScope.of(context).unfocus();
    
    // Validation des champs
    if (emailController.text.trim().isEmpty) {
      setState(() => errorMsg = 'Veuillez entrer votre email');
      return;
    }
    if (passwordController.text.trim().isEmpty) {
      setState(() => errorMsg = 'Veuillez entrer votre mot de passe');
      return;
    }

    setState(() {
      loading = true;
      errorMsg = null;
    });

    try {
      print('Tentative de connexion avec:');
      print('Email: ${emailController.text.trim()}');
      print('Mot de passe: ${passwordController.text.trim()}');
      
      final resp = await ApiService.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      print('Réponse du serveur: $resp');

      if (mounted) {
        setState(() => loading = false);

        if (resp["success"] == true) {
          // Créer l'objet utilisateur à partir de la réponse
          if (resp["data"] != null) {
            print('Données utilisateur reçues: ${resp["data"]}'); // Debug
            final user = UserModel.fromJson(resp["data"]);
            // Définir l'utilisateur dans AuthService
            final authService = Provider.of<AuthService>(context, listen: false);
            authService.setUser(user);
            print('Utilisateur défini dans AuthService: ${authService.currentUser}'); // Debug
          }
          
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const home_page.HomePage(),
            ),
          );
        } else {
          setState(() => errorMsg = resp["message"] ?? 'Une erreur est survenue');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          loading = false;
          errorMsg = 'Erreur de connexion. Veuillez réessayer.';
        });
      }
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
                      color: app_color.AppColors.primary,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "Enter your credentials to continue",
                    style: GoogleFonts.sora(
                      fontSize: 16,
                      color: app_color.AppColors.secondary,
                    ),
                  ),

                  const SizedBox(height: 30),

                  if (errorMsg != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        errorMsg!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  CustomTextField(
                    label: "Email",
                    controller: emailController,
                    prefixIcon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (_) {
                      if (errorMsg != null) {
                        setState(() => errorMsg = null);
                      }
                    },
                  ),

                  const SizedBox(height: 15),

                  CustomTextField(
                    label: "Mot de passe",
                    controller: passwordController,
                    isPassword: true,
                    prefixIcon: Icons.lock,
                    onChanged: (_) {
                      if (errorMsg != null) {
                        setState(() => errorMsg = null);
                      }
                    },
                    onSubmitted: (_) => loginUser(),
                  ),

                  const SizedBox(height: 10),

                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        // TODO: Implémenter la réinitialisation du mot de passe
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Fonctionnalité à venir'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Text(
                        "Mot de passe oublié ?",
                        style: GoogleFonts.sora(
                          color: app_color.AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // --- LOGIN BUTTON --- //
                  loading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: loginUser,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: app_color.AppColors.buttonYellow,
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
              child: Text(
                "Don't have an account? Sign up",
                style: TextStyle(
                  fontSize: 16,
                  color: app_color.AppColors.secondary,
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
