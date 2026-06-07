import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/network/api_client.dart';
import '../../core/constants/palestine_academic_data.dart';
import '../../core/theme/studyhub_design.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/studyhub_components.dart';
import '../booking/bookings_dashboard_screen.dart';
import '../favorites/favorites_screen.dart';
import '../notifications/notifications_screen.dart';
import '../settings/settings_screen.dart';
import '../support/help_support_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, this.embedded = false});
  static const route = '/profile';

  final bool embedded;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<AuthProvider>().loadStats());
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final name = user?.name ?? 'Student';
    final email = user?.email ?? '';
    final phone = user?.phone?.isNotEmpty == true ? user!.phone! : 'No phone on file';
    final items = [
      (Icons.person_outline, 'Edit Profile', 'Update your personal information', () async {
        await Navigator.pushNamed(context, EditProfileScreen.route);
        if (context.mounted) context.read<AuthProvider>().loadStats();
      }),
      (Icons.calendar_month_outlined, 'My Bookings', 'View your booking history', () => Navigator.pushNamed(context, BookingsDashboardScreen.route)),
      (Icons.favorite_border, 'Favorites', 'Your saved properties', () => Navigator.pushNamed(context, FavoritesScreen.route)),
      (Icons.rate_review_outlined, 'Reviews', 'Your property reviews', () => Navigator.pushNamed(context, MyReviewsScreen.route)),
      (Icons.notifications_outlined, 'Notifications', 'Unread and read alerts', () => Navigator.pushNamed(context, NotificationsScreen.route)),
      (Icons.settings_outlined, 'Settings', 'App preferences and notifications', () => Navigator.pushNamed(context, SettingsScreen.route)),
      (Icons.help_outline, 'Help & Support', 'Get help or contact us', () => Navigator.pushNamed(context, HelpSupportScreen.route)),
    ];

    final avatar = user?.profilePhotoUrl == null
        ? CircleAvatar(radius: 34, backgroundColor: StudyHubColors.orange, child: Text(_initials(name), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)))
        : CircleAvatar(radius: 34, backgroundImage: NetworkImage(user!.profilePhotoUrl!));

    final body = ListView(
      padding: EdgeInsets.zero,
      children: [
        Container(
          height: 150,
          padding: const EdgeInsets.fromLTRB(22, 28, 22, 22),
          decoration: const BoxDecoration(color: StudyHubColors.darkGreen, borderRadius: BorderRadius.vertical(bottom: Radius.circular(22))),
          child: Row(
            children: [
              avatar,
              const SizedBox(width: 16),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20)),
                  const SizedBox(height: 5),
                  if (email.isNotEmpty) Text(email, style: const TextStyle(color: Colors.white, fontSize: 12)),
                  Text(phone, style: const TextStyle(color: Colors.white, fontSize: 12)),
                ]),
              ),
            ],
          ),
        ),
        Transform.translate(
          offset: const Offset(0, -18),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.symmetric(vertical: 15),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: StudyHubShadows.soft),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _ProfileStat(value: '${auth.stats['bookings_count'] ?? 0}', label: 'Bookings', onTap: () => Navigator.pushNamed(context, BookingsDashboardScreen.route)),
                _ProfileStat(value: '${auth.stats['favorites_count'] ?? 0}', label: 'Favorites', onTap: () => Navigator.pushNamed(context, FavoritesScreen.route)),
                _ProfileStat(value: '${auth.stats['reviews_count'] ?? 0}', label: 'Reviews', onTap: () => Navigator.pushNamed(context, MyReviewsScreen.route)),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
          child: Column(
            children: items.map((item) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: StudyHubShadows.soft),
                child: ListTile(
                  leading: CircleAvatar(backgroundColor: StudyHubColors.softGreen, child: Icon(item.$1, color: StudyHubColors.darkGreen)),
                  title: Text(item.$2, style: const TextStyle(fontWeight: FontWeight.w900)),
                  subtitle: Text(item.$3, style: const TextStyle(fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: item.$4,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
    return widget.embedded ? SafeArea(child: body) : Scaffold(appBar: AppBar(title: const Text('Profile')), body: body);
  }

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((part) => part.isNotEmpty).toList();
    if (parts.isEmpty) return 'S';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({required this.value, required this.label, required this.onTap});
  final String value;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
          child: Column(children: [
            Text(value, style: const TextStyle(color: StudyHubColors.darkGreen, fontWeight: FontWeight.w900, fontSize: 18)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: StudyHubColors.secondaryText, fontSize: 11)),
          ]),
        ),
      );
}

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  static const route = '/edit-profile';

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();
  final dob = TextEditingController();
  final address = TextEditingController();
  final bio = TextEditingController();
  String? city;
  String? university;
  String? gender;
  final whatsappDrafts = <_WhatsappDraft>[];
  bool initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (initialized) return;
    final user = context.read<AuthProvider>().user;
    name.text = user?.name ?? '';
    email.text = user?.email ?? '';
    phone.text = user?.phone ?? '';
    dob.text = user?.dateOfBirth ?? '';
    address.text = user?.address ?? '';
    bio.text = user?.bio ?? '';
    city = user?.city;
    university = user?.university;
    gender = user?.gender;
    whatsappDrafts
      ..clear()
      ..addAll((user?.whatsappNumbers ?? const []).map(_WhatsappDraft.fromNumber));
    initialized = true;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    if (city != null && !PalestineAcademicData.cities.contains(city)) city = null;
    if (gender != null && !const ['Male', 'Female'].contains(gender)) gender = null;
    final universities = PalestineAcademicData.universitiesFor(city);
    if (university != null && !universities.contains(university)) university = null;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Center(
              child: Stack(children: [
                user?.profilePhotoUrl == null
                    ? const CircleAvatar(radius: 48, backgroundColor: StudyHubColors.orange, child: Icon(Icons.person, color: Colors.white, size: 42))
                    : CircleAvatar(radius: 48, backgroundImage: NetworkImage(user!.profilePhotoUrl!)),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: CircleAvatar(
                    backgroundColor: StudyHubColors.darkGreen,
                    child: IconButton(
                      tooltip: 'Upload profile photo',
                      icon: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                      onPressed: () async {
                        final file = await ImagePicker().pickImage(source: ImageSource.gallery);
                        if (file == null || !context.mounted) return;
                        final ok = await context.read<AuthProvider>().uploadProfilePhoto(File(file.path));
                        if (ok && context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile image uploaded.')));
                      },
                    ),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 18),
            StudyHubTextField(controller: name, label: 'Full Name', hint: 'Enter your full name', validator: _required),
            const SizedBox(height: 12),
            StudyHubTextField(controller: email, label: 'Email', hint: 'Email cannot be changed', icon: Icons.lock_outline, keyboardType: TextInputType.emailAddress, readOnly: true),
            const SizedBox(height: 12),
            StudyHubTextField(controller: phone, label: 'Phone', hint: 'Phone cannot be changed', icon: Icons.lock_outline, keyboardType: TextInputType.phone, readOnly: true),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: city,
              decoration: const InputDecoration(labelText: 'City', hintText: 'Select your city'),
              items: PalestineAcademicData.cities.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
              validator: (value) => value == null ? 'City is required' : null,
              onChanged: (value) => setState(() {
                city = value;
                university = null;
              }),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: university,
              decoration: const InputDecoration(labelText: 'University', hintText: 'Select your university'),
              items: universities.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
              validator: (value) => value == null ? 'University is required' : null,
              onChanged: (value) => setState(() => university = value),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: dob,
              keyboardType: TextInputType.datetime,
              decoration: InputDecoration(
                labelText: 'Date of Birth',
                hintText: 'YYYY-MM-DD',
                suffixIcon: IconButton(icon: const Icon(Icons.calendar_today_outlined), onPressed: () => _pickDate()),
              ),
              validator: (value) {
                final text = value?.trim() ?? '';
                if (text.isEmpty) return null;
                try {
                  DateFormat('yyyy-MM-dd').parseStrict(text);
                  return null;
                } catch (_) {
                  return 'Use YYYY-MM-DD';
                }
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: gender,
              decoration: const InputDecoration(labelText: 'Gender', hintText: 'Select gender'),
              items: const ['Male', 'Female'].map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
              onChanged: (value) => setState(() => gender = value),
            ),
            const SizedBox(height: 12),
            StudyHubTextField(controller: address, label: 'Address', hint: 'Street and building'),
            const SizedBox(height: 12),
            StudyHubTextField(controller: bio, label: 'Bio', hint: 'Tell owners a little about you', maxLines: 4),
            const SizedBox(height: 18),
            Row(children: [
              const Expanded(child: Text('WhatsApp Numbers', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16))),
              TextButton.icon(
                onPressed: () => setState(() => whatsappDrafts.add(_WhatsappDraft())),
                icon: const Icon(Icons.add),
                label: const Text('Add'),
              ),
            ]),
            if (whatsappDrafts.isEmpty)
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text('No WhatsApp numbers added yet.', style: TextStyle(color: StudyHubColors.secondaryText)),
              ),
            ...whatsappDrafts.map((draft) => _WhatsappEditor(
                  draft: draft,
                  onChanged: () => setState(() {}),
                  onSave: () => _saveWhatsapp(draft),
                  onDelete: () => _deleteWhatsapp(draft),
                )),
            const SizedBox(height: 18),
            StudyHubPrimaryButton(
              label: 'Save Profile',
              loading: auth.loading,
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final ok = await context.read<AuthProvider>().updateProfile({
                  'name': name.text.trim(),
                  'city': city,
                  'university': university,
                  'date_of_birth': dob.text.trim().isEmpty ? null : dob.text.trim(),
                  'gender': gender,
                  'address': address.text.trim().isEmpty ? null : address.text.trim(),
                  'bio': bio.text.trim().isEmpty ? null : bio.text.trim(),
                });
                if (!ok || !context.mounted) return;
                await context.read<AuthProvider>().loadStats();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile saved.')));
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final current = dob.text.trim().isEmpty ? DateTime(2000) : DateTime.tryParse(dob.text.trim()) ?? DateTime(2000);
    final picked = await showDatePicker(context: context, initialDate: current, firstDate: DateTime(1940), lastDate: DateTime.now());
    if (picked != null) dob.text = DateFormat('yyyy-MM-dd').format(picked);
  }

  Future<void> _saveWhatsapp(_WhatsappDraft draft) async {
    if (!RegExp(r'^[0-9]{6,12}$').hasMatch(draft.number.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('WhatsApp number must contain 6-12 digits.')));
      return;
    }
    final provider = context.read<AuthProvider>();
    final ok = draft.id == null
        ? await provider.addWhatsappNumber(draft.countryCode, draft.number.text.trim())
        : await provider.updateWhatsappNumber(draft.id!, draft.countryCode, draft.number.text.trim());
    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('WhatsApp number saved.')));
      setState(() {
        whatsappDrafts
          ..clear()
          ..addAll((provider.user?.whatsappNumbers ?? const []).map(_WhatsappDraft.fromNumber));
      });
    }
  }

  Future<void> _deleteWhatsapp(_WhatsappDraft draft) async {
    if (draft.id == null) {
      setState(() => whatsappDrafts.remove(draft));
      return;
    }
    final ok = await context.read<AuthProvider>().deleteWhatsappNumber(draft.id!);
    if (ok && mounted) {
      setState(() {
        whatsappDrafts
          ..clear()
          ..addAll((context.read<AuthProvider>().user?.whatsappNumbers ?? const []).map(_WhatsappDraft.fromNumber));
      });
    }
  }

  String? _required(String? value) => value == null || value.trim().isEmpty ? 'Required' : null;
}

class _WhatsappDraft {
  _WhatsappDraft({this.id, this.countryCode = '+970', String number = ''}) : number = TextEditingController(text: number);

  factory _WhatsappDraft.fromNumber(WhatsappNumber number) => _WhatsappDraft(id: number.id, countryCode: number.countryCode, number: number.number);

  final int? id;
  String countryCode;
  final TextEditingController number;
}

class _WhatsappEditor extends StatelessWidget {
  const _WhatsappEditor({required this.draft, required this.onChanged, required this.onSave, required this.onDelete});
  final _WhatsappDraft draft;
  final VoidCallback onChanged;
  final VoidCallback onSave;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: StudyHubShadows.soft),
      child: Row(children: [
        SizedBox(
          width: 92,
          child: DropdownButtonFormField<String>(
            value: draft.countryCode,
            decoration: const InputDecoration(labelText: 'Code'),
            items: const ['+970', '+972', '+962', '+966', '+971'].map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
            onChanged: (value) {
              if (value == null) return;
              draft.countryCode = value;
              onChanged();
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: draft.number,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'Number', hintText: 'Digits only'),
          ),
        ),
        IconButton(tooltip: 'Save WhatsApp number', onPressed: onSave, icon: const Icon(Icons.check_circle_outline, color: StudyHubColors.success)),
        IconButton(tooltip: 'Delete WhatsApp number', onPressed: onDelete, icon: const Icon(Icons.delete_outline, color: StudyHubColors.error)),
      ]),
    );
  }
}

class MyReviewsScreen extends StatefulWidget {
  const MyReviewsScreen({super.key});
  static const route = '/my-reviews';

  @override
  State<MyReviewsScreen> createState() => _MyReviewsScreenState();
}

class _MyReviewsScreenState extends State<MyReviewsScreen> {
  bool loading = true;
  List<dynamic> reviews = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final json = await context.read<ApiClient>().get('/me/reviews');
      if (!mounted) return;
      setState(() {
        reviews = (json['data']?['data'] as List<dynamic>? ?? const []);
        loading = false;
      });
      await context.read<AuthProvider>().loadStats();
    } catch (_) {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('My Reviews')),
      body: reviews.isEmpty
          ? const Center(child: Text('No reviews yet.', style: TextStyle(color: StudyHubColors.secondaryText)))
          : ListView.separated(
              padding: const EdgeInsets.all(18),
              itemBuilder: (_, index) {
                final review = reviews[index] as Map<String, dynamic>;
                final property = review['property'] as Map<String, dynamic>?;
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: StudyHubShadows.soft),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(property?['title']?.toString() ?? 'Property', style: const TextStyle(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 6),
                    Row(children: [
                      const Icon(Icons.star, color: StudyHubColors.orange, size: 16),
                      const SizedBox(width: 4),
                      Text('${review['rating'] ?? 0}', style: const TextStyle(fontWeight: FontWeight.w800)),
                    ]),
                    if ((review['comment']?.toString() ?? '').isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(review['comment'].toString()),
                    ],
                    if ((review['owner_reply']?.toString() ?? '').isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text('Owner reply: ${review['owner_reply']}', style: const TextStyle(color: StudyHubColors.secondaryText)),
                    ],
                  ]),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemCount: reviews.length,
            ),
    );
  }
}
