import 'package:flutter/material.dart';

import '../../core/theme/EduStay_design.dart';
import '../shell/EduStay_shell.dart';

class BookingSuccessScreen extends StatelessWidget {
  const BookingSuccessScreen({super.key});
  static const route = '/booking-success';

  @override
  Widget build(BuildContext context) {
    Future<void>.delayed(const Duration(seconds: 2), () {
      if (context.mounted)
        Navigator.pushNamedAndRemoveUntil(
            context, EduStayShell.route, (_) => false);
    });
    return const Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                  radius: 42,
                  backgroundColor: Color(0xFFE7F8ED),
                  child: Icon(Icons.check,
                      color: EduStayColors.success, size: 56)),
              SizedBox(height: 24),
              Text('Booking Confirmed!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
              SizedBox(height: 12),
              Text(
                  'Your booking has been successfully confirmed. You will receive a confirmation email shortly.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: EduStayColors.secondaryText, height: 1.4)),
            ],
          ),
        ),
      ),
    );
  }
}
