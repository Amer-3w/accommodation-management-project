import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/studyhub_design.dart';
import '../../repositories/admin_repository.dart';

class OwnerReviewsScreen extends StatefulWidget {
  const OwnerReviewsScreen({super.key});
  static const route = '/owner-reviews';

  @override
  State<OwnerReviewsScreen> createState() => _OwnerReviewsScreenState();
}

class _OwnerReviewsScreenState extends State<OwnerReviewsScreen> {
  List<dynamic> reviews = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final response = await context.read<AdminRepository>().ownerReviews();
    final data = response['data'];
    setState(() {
      reviews = data is Map && data['data'] is List ? data['data'] : data as List<dynamic>;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Reviews')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(18),
              itemBuilder: (_, index) {
                final review = reviews[index];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: StudyHubShadows.soft),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Text(review['property']?['title'] ?? 'Property', style: const TextStyle(fontWeight: FontWeight.w900)),
                      const Spacer(),
                      const Icon(Icons.star, color: StudyHubColors.orange, size: 17),
                      Text('${review['rating']}'),
                    ]),
                    const SizedBox(height: 8),
                    Text(review['comment'] ?? '', style: const TextStyle(color: StudyHubColors.secondaryText)),
                    if (review['owner_reply'] != null) ...[
                      const SizedBox(height: 8),
                      Text('Reply: ${review['owner_reply']}', style: const TextStyle(fontWeight: FontWeight.w800)),
                    ],
                    Row(children: [
                      TextButton(onPressed: () => _reply(review['id']), child: const Text('Reply')),
                      TextButton(onPressed: () => _delete(review['id']), child: const Text('Delete')),
                    ]),
                  ]),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemCount: reviews.length,
            ),
    );
  }

  Future<void> _reply(int id) async {
    final controller = TextEditingController();
    final reply = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reply to review'),
        content: TextField(controller: controller, maxLines: 3, decoration: const InputDecoration(hintText: 'Write your reply')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Reply')),
        ],
      ),
    );
    if (reply?.trim().isNotEmpty == true) {
      await context.read<AdminRepository>().replyReview(id, reply!.trim());
      await load();
    }
  }

  Future<void> _delete(int id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete review?'),
        content: const Text('Use this only for inappropriate reviews.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok == true) {
      await context.read<AdminRepository>().deleteReview(id);
      await load();
    }
  }
}
