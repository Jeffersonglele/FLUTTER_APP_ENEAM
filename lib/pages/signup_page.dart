import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:eneam_projet/config/app_color.dart' as app_color;
import 'package:eneam_projet/widgets/custom_text_field.dart';
import 'package:eneam_projet/services/api_service.dart';
import 'package:eneam_projet/services/auth_service.dart';
import 'package:eneam_projet/models/user_model.dart';
import 'home.dart' as home_page;

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  SignupPageState createState() => SignupPageState();
}

class SignupPageState extends State<SignupPage> {
  final TextEditingController nom = TextEditingController();
  final TextEditingController prenom = TextEditingController();
  final TextEditingController age = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController confirmPassword = TextEditingController();

  String? selectedSexe;

  bool loading = false;
  String? errorMsg;

  @override
  void dispose() {
    nom.dispose();
    prenom.dispose();
    age.dispose();
    email.dispose();
    password.dispose();
    confirmPassword.dispose();
    super.dispose();
  }

  void registerUser() async {
    // Nettoyer les champs
    String nomText = nom.text.trim();
    String prenomText = prenom.text.trim();
    String ageText = age.text.trim();
    String emailText = email.text.trim();
    String passwordText = password.text.trim();
    String confirmPasswordText = confirmPassword.text.trim();

    // Debug prints
    print("Nom: '$nomText'");
    print("Prenom: '$prenomText'");
    print("Age: '$ageText'");
    print("Email: '$emailText'");
    print("Password: '$passwordText'");
    print("Confirm Password: '$confirmPasswordText'");
    print("Sexe: '$selectedSexe'");

    // Vérification des champs
    if (nomText.isEmpty ||
        prenomText.isEmpty ||
        ageText.isEmpty ||
        emailText.isEmpty ||
        passwordText.isEmpty ||
        confirmPasswordText.isEmpty ||
        selectedSexe == null) {
      setState(() => errorMsg = "Tous les champs sont requis");
      return;
    }

    if (passwordText != confirmPasswordText) {
      setState(() => errorMsg = "Les mots de passe ne correspondent pas");
      return;
    }

    setState(() {
      loading = true;
      errorMsg = null;
    });

    try {
      final resp = await ApiService.register(
        nom: nomText,
        prenom: prenomText,
        age: int.parse(ageText),
        email: emailText,
        sexe: selectedSexe!,
        password: passwordText,
      );

      print("API Response: $resp");

      setState(() => loading = false);

      if (resp["success"] == true) {
        // Créer l'objet utilisateur à partir de la réponse
        if (resp["data"] != null) {
          print('Données utilisateur reçues (inscription): ${resp["data"]}'); // Debug
          final user = UserModel.fromJson(resp["data"]);
          // Définir l'utilisateur dans AuthService
          final authService = Provider.of<AuthService>(context, listen: false);
          authService.setUser(user);
          print('Utilisateur défini dans AuthService (inscription): ${authService.currentUser}'); // Debug
        }
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const home_page.HomePage()),
        );
      } else {
        setState(() => errorMsg = resp["message"] ?? "Erreur inconnue");
      }
    } catch (e) {
      print("API Error: $e");
      setState(() {
        loading = false;
        errorMsg = "Erreur serveur, veuillez réessayer";
      });
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
            // IMAGE + ANIMATION
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.3,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    right: 0,
                    child: Image.asset("assets/images/bg.png", width: 190),
                  ),
                  Positioned(
                    right: 0,
                    child: Hero(
                      tag: "bikeAnimation",
                      child: Image.asset(
                        "assets/images/trusty.png",
                        width: 250,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // FORMULAIRE
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Create Account",
                    style: GoogleFonts.sora(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: app_color.AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Sign up to get started!",
                    style: GoogleFonts.sora(
                      fontSize: 16,
                      color: app_color.AppColors.secondary,
                    ),
                  ),
                  const SizedBox(height: 20),

                  if (errorMsg != null)
                    Text(errorMsg!, style: const TextStyle(color: Colors.red)),

                  CustomTextField(
                    controller: nom,
                    label: "Nom",
                    prefixIcon: Icons.person,
                  ),
                  const SizedBox(height: 15),
                  CustomTextField(
                    controller: prenom,
                    label: "Prénom",
                    prefixIcon: Icons.person_2,
                  ),
                  const SizedBox(height: 15),
                  CustomTextField(
                    controller: age,
                    label: "Âge",
                    prefixIcon: Icons.numbers,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 15),
                  CustomTextField(
                    controller: email,
                    label: "Email",
                    prefixIcon: Icons.email,
                  ),
                  const SizedBox(height: 15),

                  // Dropdown pour le sexe
                  DropdownButtonFormField<String>(
                    initialValue: selectedSexe,
                    decoration: InputDecoration(
                      labelText: "Sexe",
                      prefixIcon: const Icon(Icons.people),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: "Masculin",
                        child: Text("Masculin"),
                      ),
                      DropdownMenuItem(
                        value: "Féminin",
                        child: Text("Féminin"),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedSexe = value;
                      });
                    },
                  ),
                  const SizedBox(height: 15),

                  CustomTextField(
                    controller: password,
                    label: "Mot de passe",
                    prefixIcon: Icons.lock,
                    isPassword: true,
                  ),
                  const SizedBox(height: 15),
                  CustomTextField(
                    controller: confirmPassword,
                    label: "Confirmer mot de passe",
                    prefixIcon: Icons.lock,
                    isPassword: true,
                  ),
                  const SizedBox(height: 20),
                  loading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: registerUser,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: app_color.AppColors.buttonYellow,
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          child: Text(
                            "S'inscrire",
                            style: GoogleFonts.sora(
                              color: Colors.black,
                              fontSize: 18,
                            ),
                          ),
                        ),
                  const SizedBox(height: 10),
                  Text(
                    "Already have an account? Log in",
                    style: GoogleFonts.sora(
                      fontSize: 16,
                      color: app_color.AppColors.secondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
