import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/palestine_academic_data.dart';
import '../../core/theme/EduStay_design.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_error.dart';
import '../../widgets/EduStay_components.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  static const route = '/register';

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();
  final password = TextEditingController();
  bool showPassword = false;
  String role = 'user';
  String? city;
  String? university;

  bool get canSubmit {
    final universities = PalestineAcademicData.universitiesFor(city);
    return name.text.trim().isNotEmpty &&
        RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email.text.trim()) &&
        phone.text.trim().isNotEmpty &&
        passwordStrength(password.text) == PasswordStrength.strong &&
        city != null &&
        university != null &&
        universities.contains(university);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final strength = passwordStrength(password.text);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 42, 24, 20),
                children: [
                  const Text('Create Account',
                      style:
                          TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 8),
                  const Text('Join EduStay today',
                      style: TextStyle(color: EduStayColors.secondaryText)),
                  const SizedBox(height: 24),
                  EduStayTextField(
                      controller: name,
                      label: 'Full Name',
                      hint: 'Enter your name',
                      icon: Icons.person_outline,
                      validator: _required,
                      onChanged: (_) => setState(() {})),
                  const SizedBox(height: 14),
                  EduStayTextField(
                    controller: email,
                    label: 'Email',
                    hint: 'Enter your email',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (_) => setState(() {}),
                    validator: (value) {
                      final text = value?.trim() ?? '';
                      if (text.isEmpty) return 'Email is required';
                      if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(text))
                        return 'Enter a valid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  EduStayTextField(
                      controller: phone,
                      label: 'Phone Number',
                      hint: 'Enter your phone number',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: _required,
                      onChanged: (_) => setState(() {})),
                  const SizedBox(height: 14),
                  EduStayTextField(
                    controller: password,
                    label: 'Password',
                    hint: 'Create a password',
                    icon: Icons.lock_outline,
                    obscureText: !showPassword,
                    onChanged: (_) => setState(() {}),
                    suffix: IconButton(
                      onPressed: () =>
                          setState(() => showPassword = !showPassword),
                      icon: Icon(
                          showPassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: EduStayIconSizes.small),
                    ),
                    validator: (value) {
                      final text = value ?? '';
                      if (passwordStrength(text) != PasswordStrength.strong)
                        return 'Use at least 8 digits with 1 capital, 1 number, and 1 symbol';
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: LinearProgressIndicator(
                            value: strength == PasswordStrength.short
                                ? .33
                                : strength == PasswordStrength.suitable
                                    ? .66
                                    : 1,
                            minHeight: 6,
                            color: passwordStrengthColor(strength),
                            backgroundColor: EduStayColors.line,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(passwordStrengthLabel(strength),
                          style: TextStyle(
                              color: passwordStrengthColor(strength),
                              fontWeight: FontWeight.w900)),
                    ],
                  ),
                  const SizedBox(height: 5),
                  const Text(
                      'At least 8 digits with 1 capital, 1 number, and 1 symbol',
                      style: TextStyle(
                          color: EduStayColors.secondaryText, fontSize: 12)),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    value: city,
                    decoration: const InputDecoration(
                        labelText: 'City', hintText: 'Select your city'),
                    items: PalestineAcademicData.cities
                        .map((item) =>
                            DropdownMenuItem(value: item, child: Text(item)))
                        .toList(),
                    validator: (value) =>
                        value == null ? 'City is required' : null,
                    onChanged: (value) => setState(() {
                      city = value;
                      university = null;
                    }),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    value: university,
                    decoration: const InputDecoration(
                        labelText: 'University',
                        hintText: 'Select your university'),
                    items: PalestineAcademicData.universitiesFor(city)
                        .map((item) =>
                            DropdownMenuItem(value: item, child: Text(item)))
                        .toList(),
                    validator: (value) =>
                        value == null ? 'University is required' : null,
                    onChanged: (value) => setState(() => university = value),
                  ),
                  const SizedBox(height: 18),
                  const Text('I am a',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(
                        child: _RoleButton(
                            label: 'Tenant',
                            selected: role == 'user',
                            onTap: () => setState(() => role = 'user'))),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _RoleButton(
                            label: 'Owner',
                            selected: role == 'owner',
                            onTap: () => setState(() => role = 'owner'))),
                  ]),
                  const SizedBox(height: 20),
                  if (auth.error != null) AppError(message: auth.error!),
                  const SizedBox(height: 14),
                  EduStayPrimaryButton(
                    label: 'Create Account',
                    loading: auth.loading,
                    onPressed: canSubmit
                        ? () async {
                            if (!formKey.currentState!.validate()) return;
                            final ok = await context
                                .read<AuthProvider>()
                                .register(
                                    name.text.trim(),
                                    email.text.trim(),
                                    phone.text.trim(),
                                    password.text,
                                    role,
                                    city!,
                                    university!);
                            if (!ok || !context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Account created. Please login with your credentials.')));
                            Navigator.pushNamedAndRemoveUntil(
                                context, LoginScreen.route, (_) => false);
                          }
                        : null,
                  ),
                  const SizedBox(height: 14),
                  Center(
                      child: TextButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, LoginScreen.route),
                          child: const Text('Already have an account? Login'))),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Required' : null;
}

class _RoleButton extends StatelessWidget {
  const _RoleButton(
      {required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      height: 52,
      decoration: BoxDecoration(
        color: selected ? EduStayColors.darkGreen : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: selected ? EduStayColors.darkGreen : EduStayColors.line),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Center(
            child: Text(label,
                style: TextStyle(
                    color: selected ? Colors.white : EduStayColors.text,
                    fontWeight: FontWeight.w900))),
      ),
    );
  }
}
