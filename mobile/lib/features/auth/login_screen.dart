import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/EduStay_design.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_error.dart';
import '../../widgets/EduStay_components.dart';
import '../admin/admin_dashboard_screen.dart';
import '../home/home_screen.dart';
import '../owner/owner_dashboard_screen.dart';
import '../shell/EduStay_shell.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  static const route = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  final email = TextEditingController();
  final password = TextEditingController();
  bool showPassword = false;

  static const adminLogin = '0599776965';

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 72, 24, 24),
                children: [
                  const Text('Welcome Back!',
                      style:
                          TextStyle(fontSize: 27, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 10),
                  const Text('Login to continue your search',
                      style: TextStyle(color: EduStayColors.secondaryText)),
                  const SizedBox(height: 30),
                  EduStayTextField(
                    controller: email,
                    label: 'Email',
                    hint: 'Enter your email or admin phone',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      final text = value?.trim() ?? '';
                      if (text.isEmpty) return 'Email or phone is required';
                      if (text != adminLogin &&
                          !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(text))
                        return 'Enter a valid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  EduStayTextField(
                    controller: password,
                    label: 'Password',
                    hint: 'Enter your password',
                    icon: Icons.lock_outline,
                    obscureText: !showPassword,
                    suffix: IconButton(
                      onPressed: () =>
                          setState(() => showPassword = !showPassword),
                      icon: Icon(
                          showPassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: EduStayIconSizes.small),
                    ),
                    validator: (value) =>
                        (value ?? '').isEmpty ? 'Password is required' : null,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                        onPressed: () => Navigator.pushNamed(
                            context, ForgotPasswordScreen.route),
                        child: const Text('Forgot Password?')),
                  ),
                  if (auth.error != null) AppError(message: auth.error!),
                  const SizedBox(height: 16),
                  EduStayPrimaryButton(
                    label: 'Login',
                    color: EduStayColors.darkGreen,
                    loading: auth.loading,
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;
                      final ok = await context
                          .read<AuthProvider>()
                          .login(email.text.trim(), password.text);
                      if (!ok || !context.mounted) return;
                      final role = context.read<AuthProvider>().user?.role;
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        role == 'admin'
                            ? AdminDashboardScreen.route
                            : role == 'owner'
                                ? OwnerDashboardScreen.route
                                : EduStayShell.route,
                        (_) => false,
                      );
                    },
                  ),
                  const SizedBox(height: 18),
                  const _SocialButton(
                      label: 'Continue with Google',
                      color: Color(0xFFDB4437),
                      letter: 'G'),
                  const SizedBox(height: 10),
                  const _SocialButton(
                      label: 'Continue with Microsoft',
                      color: Color(0xFF2F2F2F),
                      letter: 'M'),
                  const SizedBox(height: 10),
                  const _SocialButton(
                      label: 'Continue with Facebook',
                      color: Color(0xFF1877F2),
                      letter: 'f'),
                  const SizedBox(height: 22),
                  Center(
                    child: TextButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, RegisterScreen.route),
                      child: const Text("Don't have an account? Register"),
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

class _SocialButton extends StatelessWidget {
  const _SocialButton(
      {required this.label, required this.color, required this.letter});
  final String label;
  final Color color;
  final String letter;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      // TODO(oauth): Wire this to the real provider SDK and backend OAuth exchange before production enablement.
      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$label requires provider credentials.'))),
      style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(50),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        CircleAvatar(
            radius: 12,
            backgroundColor: color,
            child: Text(letter,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 12))),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
      ]),
    );
  }
}
