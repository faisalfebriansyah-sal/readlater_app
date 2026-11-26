import 'package:flutter/material.dart';
import '../main.dart';
import '../services/api_service.dart';

class TopicPage extends StatefulWidget {
  const TopicPage({super.key});

  @override
  State<TopicPage> createState() => _TopicPageState();
}

class _TopicPageState extends State<TopicPage> {
  List<dynamic> _topics = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTopics();
  }

  Future<void> _loadTopics() async {
    setState(() => _loading = true);
    try {
      final data = await ApiService.getTopics();
      setState(() => _topics = data);
    } catch (_) {}
    setState(() => _loading = false);
  }

  void _showTopicForm({Map<String, dynamic>? existing}) {
    final ctrl = TextEditingController(text: existing?['name'] ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          existing == null ? 'Tambah Topik' : 'Edit Topik',
          style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w700),
        ),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(labelText: 'Nama Topik (misal: Teknologi)'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
            onPressed: () async {
              if (ctrl.text.trim().isEmpty) return;
              bool ok;
              if (existing == null) {
                ok = await ApiService.createTopic(ctrl.text.trim());
              } else {
                ok = await ApiService.updateTopic(existing['id'], ctrl.text.trim());
              }
              if (!ctx.mounted) return;
              Navigator.pop(ctx);
              if (ok) _loadTopics();
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTopic(int id) async {
    final ok = await ApiService.deleteTopic(id);
    if (ok) _loadTopics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Topik')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        onPressed: () => _showTopicForm(),
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : ListView.builder(
              padding: const EdgeInsets.all(14),
              itemCount: _topics.length,
              itemBuilder: (context, index) {
                final topic = _topics[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.label_rounded, color: AppColors.secondary),
                    ),
                    title: Text(
                      topic['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    subtitle: Text(
                      '${topic['bookmarks_count'] ?? 0} artikel tersimpan',
                      style: const TextStyle(color: AppColors.textMuted),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, color: AppColors.secondary),
                          onPressed: () => _showTopicForm(existing: topic),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: AppColors.primary),
                          onPressed: () => _deleteTopic(topic['id']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}