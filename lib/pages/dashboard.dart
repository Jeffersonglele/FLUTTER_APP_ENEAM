import 'package:concentric_transition/concentric_transition.dart';
import 'package:flutter/material.dart';
import 'package:eneam_projet/config/app_color.dart';
import 'welcome_page.dart';

// Classe pour gérer l'état de la page
class ConcentricAnimationState extends State<ConcentricAnimationOnboarding> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: ConcentricPageView(
        colors: pages.map((p) => p.bgColor).toList(),
        radius: screenWidth * 0.1,
        nextButtonBuilder: (context) {
          // Ne pas afficher le bouton sur la dernière page
          if (pages[currentPageIndex].isLast) {
            return const SizedBox.shrink();
          }
          return Padding(
            padding: const EdgeInsets.only(left: 3),
            child: Icon(
              Icons.navigate_next,
              size: screenWidth * 0.08,
              color: AppColors.primary,
            ),
          );
        },
        onChange: (index) {
          setState(() {
            currentPageIndex = index % pages.length;
          });
        },
        scaleFactor: 2,
        itemBuilder: (index) {
          final page = pages[index % pages.length];
          return SafeArea(child: _Page(page: page));
        },
      ),
    );
  }
}

final pages = [
  const PageData(
    icon: Icons.handshake_outlined,
    title: "Trouvez rapidement un prestataire fiable\nprêt à vous aider",
    bgColor: AppColors.primary,
    textColor: Colors.white,
  ),
  const PageData(
    icon: Icons.assignment_outlined,
    title: "Demandez un service en quelques clics\net suivez-le en temps réel",
    bgColor: AppColors.buttonYellow,
    textColor: AppColors.darkGreen,
  ),
  const PageData(
    icon: Icons.verified_outlined,
    title: "Bénéficiez de prestations de qualité\npar des professionnels vérifiés",
    bgColor: Colors.white,
    textColor: AppColors.primary,
    isLast: true, // dernière page
  ),
];

class ConcentricAnimationOnboarding extends StatefulWidget {
  const ConcentricAnimationOnboarding({super.key});

  @override
  State<ConcentricAnimationOnboarding> createState() => ConcentricAnimationState();
}

class PageData {
  final String? title;
  final IconData? icon;
  final Color bgColor;
  final Color textColor;
  final bool isLast;

  const PageData({
    this.title,
    this.icon,
    this.bgColor = Colors.white,
    this.textColor = Colors.black,
    this.isLast = false,
  });
}

class _Page extends StatelessWidget {
  final PageData page;

  const _Page({required this.page});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Icône au centre
        Container(
          padding: const EdgeInsets.all(20.0),
          margin: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: page.textColor,
          ),
          child: Icon(page.icon, size: screenHeight * 0.1, color: page.bgColor),
        ),

        // Texte
        Text(
          page.title ?? "",
          style: TextStyle(
            color: page.textColor,
            fontSize: screenHeight * 0.03,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 30),

        // BOUTON sur la dernière slide
        if (page.isLast)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: page.textColor,
              foregroundColor: page.bgColor,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const WelcomeScreen()),
              );
            },
            child: const Text(
              "Commencer",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
      ],
    );
  }
}
