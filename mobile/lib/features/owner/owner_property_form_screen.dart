import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/constants/palestine_academic_data.dart';
import '../../core/theme/studyhub_design.dart';
import '../../models/property.dart';
import '../../providers/auth_provider.dart';
import '../../repositories/property_repository.dart';
import '../../widgets/studyhub_components.dart';
import '../map/location_picker_screen.dart';

class OwnerPropertyFormScreen extends StatefulWidget {
  const OwnerPropertyFormScreen({super.key});
  static const route = '/owner-property-form';

  @override
  State<OwnerPropertyFormScreen> createState() => _OwnerPropertyFormScreenState();
}

class _OwnerPropertyFormScreenState extends State<OwnerPropertyFormScreen> {
  final formKey = GlobalKey<FormState>();
  final title = TextEditingController();
  final description = TextEditingController();
  final price = TextEditingController();
  final rooms = TextEditingController(text: '1');
  final bathrooms = TextEditingController(text: '1');
  final address = TextEditingController();
  final customRule = TextEditingController();
  final contactEmail = TextEditingController();
  final contactWhatsapp = TextEditingController();
  String propertyType = 'Apartment';
  String priceDuration = 'month';
  int stayDuration = 1;
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
      contactWhatsapp.text = arg.contactWhatsappNumber ?? '';
      contactType = arg.contactType;
      city = arg.city;
      university = arg.university;
      address.text = arg.address ?? '';
      if (arg.latitude != null && arg.longitude != null) {
        pickedLocation = PickedLocation(latitude: arg.latitude!, longitude: arg.longitude!, city: arg.city ?? '');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (city != null && !PalestineAcademicData.cities.contains(city)) city = null;
    final universities = PalestineAcademicData.universitiesFor(city);
    if (university != null && !universities.contains(university)) university = null;
    if (contactEmail.text.isEmpty) contactEmail.text = context.read<AuthProvider>().user?.email ?? '';
    final total = _discountedTotal();

    return Scaffold(
      appBar: AppBar(title: Text(editing == null ? 'Create Property' : 'Edit Property')),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            StudyHubTextField(controller: title, label: 'Property Name', hint: 'Modern student apartment', validator: _required),
            const SizedBox(height: 12),
            StudyHubTextField(controller: description, label: 'Description', hint: 'Describe the home', maxLines: 4, validator: _required),
            const SizedBox(height: 12),
            StudyHubTextField(controller: price, label: 'Base Price', hint: 'Enter base price', icon: Icons.attach_money, keyboardType: TextInputType.number, validator: _required, onChanged: (_) => setState(() {})),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: priceDuration,
                  decoration: const InputDecoration(labelText: 'Price Duration'),
                  items: const ['day', 'week', 'month'].map((item) => DropdownMenuItem(value: item, child: Text('per $item'))).toList(),
                  onChanged: (value) => setState(() => priceDuration = value ?? 'month'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Stay Duration'),
                  child: Row(children: [
                    IconButton(onPressed: stayDuration > 1 ? () => setState(() => stayDuration--) : null, icon: const Icon(Icons.remove_circle_outline)),
                    Expanded(child: Center(child: Text('$stayDuration', style: const TextStyle(fontWeight: FontWeight.w900)))),
                    IconButton(onPressed: () => setState(() => stayDuration++), icon: const Icon(Icons.add_circle_outline)),
                  ]),
                ),
              ),
            ]),
            const SizedBox(height: 8),
            Text('Total after discount: \$${total.toStringAsFixed(0)}', style: const TextStyle(color: StudyHubColors.darkGreen, fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: StudyHubTextField(controller: rooms, label: 'Rooms', keyboardType: TextInputType.number, validator: _required)),
              const SizedBox(width: 12),
              Expanded(child: StudyHubTextField(controller: bathrooms, label: 'Bathrooms', keyboardType: TextInputType.number, validator: _required)),
            ]),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: propertyType,
              decoration: const InputDecoration(labelText: 'Property Type'),
              items: const ['Apartment', 'Studio', 'Shared Room', 'Dormitory'].map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
              validator: (value) => value == null ? 'Required' : null,
              onChanged: (value) => setState(() => propertyType = value ?? 'Apartment'),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: ['WiFi', 'Parking', 'Gym', 'Kitchen', 'Laundry', 'AC'].map((item) => FilterChip(
                    label: Text(item),
                    selected: amenities.contains(item),
                    onSelected: (selected) => setState(() => selected ? amenities.add(item) : amenities.remove(item)),
                  )).toList(),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: city,
              decoration: const InputDecoration(labelText: 'City', hintText: 'Select the property city'),
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
              decoration: const InputDecoration(labelText: 'Nearby University', hintText: 'Select nearby university'),
              items: universities.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
              validator: (value) => value == null ? 'University is required' : null,
              onChanged: (value) => setState(() => university = value),
            ),
            const SizedBox(height: 12),
            StudyHubTextField(controller: address, label: 'Address', validator: _required),
            const SizedBox(height: 12),
            const Text('Rules', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ['No smoking', 'Students only', 'No pets', 'Quiet hours', 'No parties'].map((item) => FilterChip(
                    label: Text(item),
                    selected: selectedRules.contains(item),
                    onSelected: (selected) => setState(() => selected ? selectedRules.add(item) : selectedRules.remove(item)),
                  )).toList(),
            ),
            const SizedBox(height: 12),
            StudyHubTextField(controller: customRule, label: 'Custom Rule', hint: 'Add any custom house rule'),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: contactType,
              decoration: const InputDecoration(labelText: 'Contact Type'),
              items: const ['email', 'whatsapp', 'both'].map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
              onChanged: (value) => setState(() => contactType = value ?? 'email'),
            ),
            const SizedBox(height: 12),
            StudyHubTextField(controller: contactEmail, label: 'Contact Email', hint: 'Owner account email', keyboardType: TextInputType.emailAddress, validator: (value) => contactType == 'whatsapp' ? null : _required(value)),
            const SizedBox(height: 12),
            Row(children: [
              SizedBox(
                width: 96,
                child: DropdownButtonFormField<String>(
                  value: contactCountryCode,
                  decoration: const InputDecoration(labelText: 'Code'),
                  items: const ['+970', '+972', '+962', '+966', '+971'].map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
                  onChanged: (value) => setState(() => contactCountryCode = value ?? '+970'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(child: StudyHubTextField(controller: contactWhatsapp, label: 'WhatsApp Number', hint: 'Digits only', keyboardType: TextInputType.phone, validator: (value) => contactType == 'email' ? null : _required(value))),
            ]),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: () async {
                final result = await Navigator.pushNamed(context, LocationPickerScreen.route);
                if (result is PickedLocation) {
                  setState(() {
                    pickedLocation = result;
                    if (PalestineAcademicData.cities.contains(result.city)) {
                      city = result.city;
                      university = null;
                    }
                  });
                }
              },
              icon: Icon(pickedLocation == null ? Icons.location_on_outlined : Icons.check_circle, color: pickedLocation == null ? StudyHubColors.darkGreen : StudyHubColors.success),
              label: Text(pickedLocation == null ? 'Select mandatory map location' : 'Location selected: ${pickedLocation!.latitude.toStringAsFixed(4)}, ${pickedLocation!.longitude.toStringAsFixed(4)}'),
            ),
            if (editing != null && editing!.imageRecords.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text('Existing Images', style: TextStyle(fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: editing!.imageRecords.where((item) => !deletedImageIds.contains(item.id)).map((item) => Stack(children: [
                      ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(item.url, width: 92, height: 92, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(width: 92, height: 92, color: StudyHubColors.line, child: const Icon(Icons.broken_image_outlined)))),
                      Positioned(right: 0, top: 0, child: IconButton(onPressed: () => setState(() => deletedImageIds.add(item.id)), icon: const Icon(Icons.cancel, color: StudyHubColors.error))),
                    ])).toList(),
              ),
            ],
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () async {
                final picked = await ImagePicker().pickMultiImage();
                setState(() => images.addAll(picked.map((item) => File(item.path))));
              },
              icon: const Icon(Icons.image_outlined),
              label: Text(images.isEmpty ? 'Pick property images' : '${images.length} image(s) selected'),
            ),
            if (images.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: images.map((image) => Stack(children: [
                      ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(image, width: 92, height: 92, fit: BoxFit.cover)),
                      Positioned(right: 0, top: 0, child: IconButton(onPressed: () => setState(() => images.remove(image)), icon: const Icon(Icons.cancel, color: StudyHubColors.error))),
                    ])).toList(),
              ),
            ],
            const SizedBox(height: 18),
            StudyHubPrimaryButton(label: editing == null ? 'Publish Property' : 'Save Property', loading: saving, onPressed: save),
            if (editing != null) ...[
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => _confirmDelete(context),
                child: const Text('Delete Property'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> save() async {
    if (!formKey.currentState!.validate() || pickedLocation == null || city == null || university == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Complete all required fields and select a map location.')));
      return;
    }
    setState(() => saving = true);
    final body = {
      'title': title.text,
      'description': description.text,
      'price': double.tryParse(price.text) ?? 0.0,
      'price_duration': priceDuration,
      'stay_duration': stayDuration,
      'location': '$city, ${address.text}',
      'rooms': int.tryParse(rooms.text) ?? 1,
      'bathrooms': int.tryParse(bathrooms.text) ?? 1,
      'property_type': propertyType,
      'city': city,
      'university': university,
      'address': address.text,
      'latitude': pickedLocation!.latitude,
      'longitude': pickedLocation!.longitude,
      'amenities': amenities.toList(),
      'rules': [...selectedRules, if (customRule.text.trim().isNotEmpty) customRule.text.trim()],
      'availability': {'available': true},
      'contact_email': contactEmail.text.trim().isEmpty ? null : contactEmail.text.trim(),
      'contact_whatsapp_country_code': contactCountryCode,
      'contact_whatsapp_number': contactWhatsapp.text.trim().isEmpty ? null : contactWhatsapp.text.trim(),
      'contact_type': contactType,
    };
    final repo = context.read<PropertyRepository>();
    final response = editing == null ? await repo.create(body) : await repo.update(editing!.id, body);
    final propertyId = editing?.id ?? response['data']['id'];
    for (final imageId in deletedImageIds) {
      await repo.deleteImage(propertyId, imageId);
    }
    for (final image in images) {
      await repo.uploadImage(propertyId, image);
    }
    if (mounted) Navigator.pop(context);
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete property?'),
        content: const Text('The property will be archived and removed from public listings.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok == true && mounted && editing != null) {
      await context.read<PropertyRepository>().delete(editing!.id);
      if (mounted) Navigator.pop(context);
    }
  }

  String? _required(String? value) => value == null || value.trim().isEmpty ? 'Required' : null;

  double _discountedTotal() {
    final base = double.tryParse(price.text) ?? 0;
    var discount = 0.0;
    if (priceDuration == 'week') discount = 0.10;
    if (priceDuration == 'month') discount = 0.20;
    if (priceDuration == 'month' && stayDuration > 3) discount = 0.25;
    return base * stayDuration * (1 - discount);
  }
}
