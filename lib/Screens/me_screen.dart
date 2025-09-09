import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vocab_5k/Providers/main_provider.dart';

import '../Helper/app_colors.dart';
import '../Providers/db_provider.dart';

class MeScreen extends StatefulWidget {
  const MeScreen({super.key});

  @override
  State<MeScreen> createState() => _MeScreenState();
}

class _MeScreenState extends State<MeScreen> {
  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  Widget sectionContainer({
    required String title,
    required Widget child,
    Color? color,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    //
  }

  @override
  void dispose() {
    super.dispose();

    //
  }

  @override
  Widget build(BuildContext context) {
    var mainProvider = context.watch<MainProvider>();
    var dbProvider = context.watch<DbProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        toolbarHeight: 0,
      ),
      backgroundColor: AppColors.facebookBackground,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Zone
            CircleAvatar(
              radius: 50,
              backgroundImage: const AssetImage(
                'assets/images/480704000_9188819427879388_4865635644496713932_n.jpg',
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Design By KSN",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),

            // About Me Section
            sectionContainer(
              title: "About Me",
              color: Colors.white,
              child: Text(
                "Purpose: Learn vocabulary and improve English skills daily.",
                style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
              ),
            ),

            // Interests Section
            sectionContainer(
              title: "My Interests",
              color: Colors.blue.shade50,
              child: Text(
                "- Programming & Flutter Development\n"
                "- Learning English & Vocabulary\n"
                "- Mobile App Design\n"
                "- Technology & Gadgets",
                style: TextStyle(fontSize: 16, color: Colors.grey.shade800),
              ),
            ),

            // App Features Section
            sectionContainer(
              title: "App Features",
              color: Colors.green.shade50,
              child: Text(
                "- Daily vocabulary quizzes\n"
                "- Track learning history\n"
                "- Customizable number of choices\n"
                "- Sound toggle for quizzes",
                style: TextStyle(fontSize: 16, color: Colors.grey.shade800),
              ),
            ),

            // Contact Section
            sectionContainer(
              title: "Contact & Social",
              color: Colors.orange.shade50,
              child: RichText(
                textAlign: TextAlign.start,
                text: TextSpan(
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                  children: [
                    const TextSpan(text: "Email: "),
                    TextSpan(
                      text: "kritsana.dk@gmail.com\n",
                      style: const TextStyle(color: Colors.blue),
                      recognizer:
                          TapGestureRecognizer()
                            ..onTap =
                                () =>
                                    _launchUrl("mailto:kritsana.dk@gmail.com"),
                    ),
                    const TextSpan(text: "GitHub: "),
                    TextSpan(
                      text: "github.com/KritsanaDK\n",
                      style: const TextStyle(color: Colors.blue),
                      recognizer:
                          TapGestureRecognizer()
                            ..onTap =
                                () =>
                                    _launchUrl("https://github.com/KritsanaDK"),
                    ),
                    const TextSpan(text: "LinkedIn: "),
                    TextSpan(
                      text: "linkedin.com/in/kritsana",
                      style: const TextStyle(color: Colors.blue),
                      recognizer:
                          TapGestureRecognizer()
                            ..onTap =
                                () => _launchUrl(
                                  "https://linkedin.com/in/kritsana-wathaniyanon-4155548b/",
                                ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
            Text(
              "Version: 1.0.0",
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
            Text(
              "© 2025 KSN",
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}
