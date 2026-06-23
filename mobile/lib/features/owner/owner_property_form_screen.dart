import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/constants/palestine_academic_data.dart';
import '../../core/theme/EduStay_design.dart';
import '../../models/property.dart';
import '../../providers/auth_provider.dart';
import '../../repositories/property_repository.dart';
import '../../widgets/EduStay_components.dart';
import '../map/location_picker_screen.dart';

class OwnerPropertyFormScreen extends StatefulWidget {
  const OwnerPropertyFormScreen({super.key});
  static const route = '/owner-property-form';

  @override
  State<OwnerPropertyFormScreen> createState() =>
      _OwnerPropertyFormScreenState();
}

class _OwnerPropertyFormScreenState extends State<OwnerPropertyFormScreen> {
  final formKey = GlobalKey<FormState>();
  final title = TextEditingController();
  final description = TextEditingController();
  final price = TextEditingController();
  final rooms = TextEditingController(text: '1');
  final bathrooms = TextEditingController(text: '1');
  final beds = TextEditingController(text: '1');
  final address = TextEditingController();
  final customRule = TextEditingController();
  final contactEmail = TextEditingController();
  final contactPhone = TextEditingController();
  String propertyType = 'Apartment';
  String priceDuration = 'month';
  int stayDuration = 0;
  String contactType = 'email';
  String contactCountryCode = '+970';
  final amenities = <String>{'WiFi'};
  final selectedRules = <String>{};
  final images = <File>[];
  final deletedImageIds = <int>{};
  String? city;
  String? university;
  PickedLocation? pickedLocation;
  Property? editing;
  bool saving = false;

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required';
    return null;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is Property && editing == null) {
      editing = arg;
      title.text = arg.title;
      description.text = arg.description;
      price.text = arg.price.toStringAsFixed(0);
      rooms.text = '${arg.rooms}';
      propertyType = arg.propertyType;
      priceDuration = arg.priceDuration;
      stayDuration = arg.stayDuration;
      selectedRules.addAll(arg.rules);
      contactEmail.text = arg.contactEmail ?? '';
      contactCountryCode = arg.contactWhatsappCountryCode ?? '+970';
      contactPhone.text = arg.contactWhatsappNumber ?? '';
      contactType = arg.contactType;
      city = arg.city;
      university = arg.university;
      address.text = arg.address ?? '';
      if (arg.latitude != null && arg.longitude != null) {
        pickedLocation = PickedLocation(
            latitude: arg.latitude!,
            longitude: arg.longitude!,
            city: arg.city ?? '');
      }
    }
  }

  double _discountedTotal() {
    final base = double.tryParse(price.text) ?? 0.0;
    final discountFactor = 1 - (stayDuration / 100.0);
    return base * discountFactor;
  }

  Future<void> deleteProperty() async {
    if (editing == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Property'),
        content: const Text('Are you sure you want to delete this property? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: EduStayColors.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (ok == true) {
      try {
        await context.read<PropertyRepository>().delete(editing!.id);
        if (mounted) Navigator.pop(context);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Delete failed: $e')));
        }
      }
    }
  }

  Future<void> save() async {
    if (!formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please complete all basic required text fields.')));
      return;
    }

    setState(() => saving = true);

    final double finalLatitude = pickedLocation?.latitude ?? 31.9522;
    final double finalLongitude = pickedLocation?.longitude ?? 35.2332;
    final String finalCity = city ?? 'Ramallah';
    final String finalUniversity = university ?? 'Birzeit University';

    final body = {
      'title': title.text,
      'description': description.text,
      'price': double.tryParse(price.text) ?? 0.0,
      'price_duration': 'month',
      'stay_duration': stayDuration,
      'location': '$finalCity, ${address.text}',
      'rooms': int.tryParse(rooms.text) ?? 1,
      'bathrooms': int.tryParse(bathrooms.text) ?? 1,
      'beds': int.tryParse(beds.text) ?? 1,
      'property_type': propertyType,
      'city': finalCity,
      'university': finalUniversity,
      'address': address.text,
      'latitude': finalLatitude,
      'longitude': finalLongitude,
      'amenities': amenities.toList(),
      'rules': [
        ...selectedRules,
        if (customRule.text.trim().isNotEmpty) customRule.text.trim()
      ],
      'availability': {'available': true},
      'contact_email':
          contactEmail.text.trim().isEmpty ? null : contactEmail.text.trim(),
      'contact_whatsapp_country_code': contactCountryCode,
      'contact_whatsapp_number': contactPhone.text.trim().isEmpty
          ? null
          : contactPhone.text.trim(),
      'contact_type': contactType,
    };

    try {
      final repo = context.read<PropertyRepository>();
      final response = editing == null
          ? await repo.create(body)
          : await repo.update(editing!.id, body);

      int? propertyId;
      if (editing != null) {
        propertyId = editing!.id;
      } else {
        propertyId = response['id'] is int
            ? response['id'] as int
            : int.tryParse(response['id']?.toString() ?? '');
        propertyId ??= response['data'] is Map
            ? (response['data']['id'] is int
                ? response['data']['id'] as int
                : int.tryParse(response['data']['id']?.toString() ?? ''))
            : null;
      }

      if (propertyId != null && propertyId > 0) {
        for (final imageId in deletedImageIds) {
          try { await repo.deleteImage(propertyId, imageId); } catch (_) {}
        }
        for (final file in images) {
          try { await repo.uploadImage(propertyId, file); } catch (e) {
            debugPrint('Image upload failed: $e');
          }
        }
      } else {
        debugPrint('Warning: could not extract property ID from response: $response');
      }
    } catch (networkError) {
      debugPrint('Error during save: $networkError');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to save property: ${networkError.toString().replaceAll(RegExp(r'Exception:?\s*'), '')}')));
        setState(() => saving = false);
      }
      return;
    }
    if (mounted) {
      setState(() => saving = false);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (city != null && !PalestineAcademicData.cities.contains(city)) {
      city = null;
    }
    final universities = PalestineAcademicData.universitiesFor(city);
    if (university != null && !universities.contains(university)) {
      university = null;
    }
    if (contactEmail.text.isEmpty) {
      contactEmail.text = context.read<AuthProvider>().user?.email ?? '';
    }
    final total = _discountedTotal();

    return Scaffold(
      appBar: AppBar(
          title: Text(editing == null ? 'Create Property' : 'Edit Property')),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            EduStayTextField(
                controller: title,
                label: 'Property Name',
                hint: 'Modern student apartment',
                validator: _required),
            const SizedBox(height: 12),
            EduStayTextField(
                controller: description,
                label: 'Description',
                hint: 'Describe the home',
                maxLines: 4,
                validator: _required),
            const SizedBox(height: 12),
            EduStayTextField(
                controller: price,
                label: 'Base Price',
                hint: 'Enter base price',
                icon: Icons.attach_money,
                keyboardType: TextInputType.number,
                validator: _required,
                onChanged: (_) => setState(() {})),
            const SizedBox(height: 12),
            InputDecorator(
              decoration:
                  const InputDecoration(labelText: 'Discount Percentage (%)'),
              child: Row(children: [
                IconButton(
                    onPressed: stayDuration > 0
                        ? () => setState(() => stayDuration -= 5)
                        : null,
                    icon: const Icon(Icons.remove_circle_outline)),
                Expanded(
                    child: Center(
                        child: Text('$stayDuration%',
                            style:
                                const TextStyle(fontWeight: FontWeight.w900)))),
                IconButton(
                    onPressed: stayDuration < 95
                        ? () => setState(() => stayDuration += 5)
                        : null,
                    icon: const Icon(Icons.add_circle_outline)),
              ]),
            ),
            const SizedBox(height: 12),
            Text('Total after discount: \$${total.toStringAsFixed(0)}',
                style: const TextStyle(
                    color: EduStayColors.darkGreen,
                    fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: EduStayTextField(
                    controller: rooms,
                    label: 'Rooms',
                    keyboardType: TextInputType.number,
                    validator: _required),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: EduStayTextField(
                    controller: beds,
                    label: 'Beds',
                    keyboardType: TextInputType.number,
                    validator: _required),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: EduStayTextField(
                    controller: bathrooms,
                    label: 'Bathrooms',
                    keyboardType: TextInputType.number,
                    validator: _required),
              ),
            ]),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: propertyType,
              decoration: const InputDecoration(labelText: 'Property Type'),
              items: const ['Apartment', 'Studio', 'Shared Room', 'Dormitory']
                  .map((item) =>
                      DropdownMenuItem(value: item, child: Text(item)))
                  .toList(),
              validator: (value) => value == null ? 'Required' : null,
              onChanged: (value) =>
                  setState(() => propertyType = value ?? 'Apartment'),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: ['WiFi', 'Parking', 'Gym', 'Kitchen', 'Laundry', 'AC']
                  .map((item) => FilterChip(
                        label: Text(item),
                        selected: amenities.contains(item),
                        onSelected: (selected) => setState(() => selected
                            ? amenities.add(item)
                            : amenities.remove(item)),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: city,
              decoration: const InputDecoration(
                  labelText: 'City', hintText: 'Select the property city'),
              items: PalestineAcademicData.cities
                  .map((item) =>
                      DropdownMenuItem(value: item, child: Text(item)))
                  .toList(),
              validator: (value) => value == null ? 'City is required' : null,
              onChanged: (value) => setState(() {
                city = value;
                university = null;
              }),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: university,
              decoration: const InputDecoration(
                  labelText: 'Nearby University',
                  hintText: 'Select nearby university'),
              items: universities
                  .map((item) =>
                      DropdownMenuItem(value: item, child: Text(item)))
                  .toList(),
              validator: (value) =>
                  value == null ? 'University is required' : null,
              onChanged: (value) => setState(() => university = value),
            ),
            const SizedBox(height: 12),
            EduStayTextField(
                controller: address, label: 'Address', validator: _required),
            const SizedBox(height: 12),
            const Text('Rules',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                'No smoking',
                'Students only',
                'No pets',
                'Quiet hours',
                'No parties'
              ]
                  .map((item) => FilterChip(
                        label: Text(item),
                        selected: selectedRules.contains(item),
                        onSelected: (selected) => setState(() => selected
                            ? selectedRules.add(item)
                            : selectedRules.remove(item)),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
            const Text('Contact Information',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: EduStayColors.darkGreen)),
            const SizedBox(height: 8),
            EduStayTextField(
                controller: contactEmail,
                label: 'Contact Email',
                hint: 'owner@example.com'),
            const SizedBox(height: 12),
            // Phone number row — simplified approach with consistent sizing
            const Text('Phone Number',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: EduStayColors.text)),
            const SizedBox(height: 8),
            Row(children: [
              Container(
                width: 100,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: EduStayColors.line),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: contactCountryCode,
                    isDense: true,
                    items: const ['+970', '+972', '+1']
                        .map((c) => DropdownMenuItem(
                            value: c,
                            child: Text(c,
                                style:
                                    const TextStyle(fontWeight: FontWeight.w800))))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => contactCountryCode = v ?? '+970'),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: contactPhone,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: '599123456',
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 20),
            const Text('Property Gallery Images',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: EduStayColors.darkGreen)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ...images.map((file) => Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            file,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 80,
                                height: 80,
                                color: const Color(0xFFEDEDED),
                                child: const Icon(Icons.broken_image,
                                    color: Colors.grey),
                              );
                            },
                          ),
                        ),
                        Positioned(
                          right: -4,
                          top: -4,
                          child: IconButton(
                            icon: const Icon(Icons.cancel,
                                color: EduStayColors.error, size: 20),
                            onPressed: () =>
                                setState(() => images.remove(file)),
                          ),
                        ),
                      ],
                    )),
                InkWell(
                  onTap: () async {
                    final picker = ImagePicker();
                    final picked =
                        await picker.pickImage(source: ImageSource.gallery);
                    if (picked != null)
                      setState(() => images.add(File(picked.path)));
                  },
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDEDED),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.withOpacity(0.5)),
                    ),
                    child: const Icon(Icons.add_a_photo_outlined,
                        color: Colors.grey),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            EduStayPrimaryButton(
              label: editing == null ? 'Create' : 'Save Changes',
              loading: saving,
              onPressed: save,
            ),
            if (editing != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: EduStayColors.error,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Delete Property',
                      style: TextStyle(fontWeight: FontWeight.w900)),
                  onPressed: deleteProperty,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}