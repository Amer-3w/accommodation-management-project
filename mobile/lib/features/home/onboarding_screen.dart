import 'package:flutter/material.dart';

import '../../core/theme/EduStay_design.dart';
import '../../widgets/EduStay_components.dart';
import '../auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  static const route = '/onboarding';

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final controller = PageController();
  int page = 0;

  final items = const [
    (
      'Find Your Perfect Place',
      'Discover thousands of student-friendly accommodations near your university',
      Icons.search,
      EduStayColors.darkGreen,
      Color(0xFFF2EFEB)
    ),
    (
      'Safe & Verified',
      'All properties are verified and owners are background-checked for your safety',
      Icons.shield_outlined,
      EduStayColors.success,
      Color(0xFFEAF7F1)
    ),
    (
      'Easy Communication',
      'Chat directly with property owners and get instant responses to your questions',
      Icons.chat_bubble_outline,
      EduStayColors.orange,
      Color(0xFFF3F0EB)
    ),
  ];

  void _finish() => Navigator.pushReplacementNamed(context, LoginScreen.route);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
                alignment: Alignment.centerRight,
                child:
                    TextButton(onPressed: _finish, child: const Text('Skip'))),
            Expanded(
              child: PageView.builder(
                controller: controller,
                itemCount: items.length,
                onPageChanged: (value) => setState(() => page = value),
                itemBuilder: (_, index) {
                  final item = items[index];
                  return FadeSlideIn(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 34),
                      child: Column(
                        children: [
                          const Spacer(flex: 2),
                          Container(
                            width: 210,
                            height: 210,
                            decoration: BoxDecoration(
                                color: item.$5, shape: BoxShape.circle),
                            child: Icon(item.$3, color: item.$4, size: 82),
                          ),
                          const Spacer(flex: 2),
                          Text(item.$1,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 23, fontWeight: FontWeight.w900)),
                          const SizedBox(height: 16),
                          Text(item.$2,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: EduStayColors.secondaryText,
                                  height: 1.45)),
                          const SizedBox(height: 28),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(items.length, (index) {
                final selected = page == index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: selected ? 24 : 7,
                  height: 6,
                  decoration: BoxDecoration(
                      color: selected
                          ? EduStayColors.darkGreen
                          : EduStayColors.line,
                      borderRadius: BorderRadius.circular(8)),
                );
              }),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: EduStayPrimaryButton(
                label: page == items.length - 1 ? 'Get Started' : 'Next',
                onPressed: page == items.length - 1
                    ? _finish
                    : () => controller.nextPage(
                        duration: const Duration(milliseconds: 280),
                        curve: Curves.easeOutCubic),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
