import 'package:flutter/material.dart';
import '../main.dart';
import '../services/api_service.dart';

class PublicPostDetailPage extends StatefulWidget {
  final Map<String, dynamic> post;
  const PublicPostDetailPage({super.key, required this.post});

  @override
  State<PublicPostDetailPage> createState() => _PublicPostDetailPageState();
}

class _PublicPostDetailPageState extends State<PublicPostDetailPage> {
  Future<void> _showSaveDialog() async {
    List<dynamic> topics = [];
    try {
      topics = await ApiService.getTopics();
    } catch (_) {}

    if (!mounted) return;
    if (topics.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.primary,
          content: Text('Buat topik terlebih dahulu di menu Topik!'),
        ),
      );
      return;
    }

    int selectedTopicId = topics.first['id'];
    final bodyText = widget.post['body']?.toString() ?? '';
    final summaryCtrl = TextEditingController(
      text: bodyText.length > 100 ? '${bodyText.substring(0, 100)}...' : bodyText,
    );
    final keyPointsCtrl = TextEditingController(
      text: (widget.post['tags'] as List<dynamic>? ?? []).join(', '),
    );

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Text(
            'Simpan ke Koleksi',
            style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w700),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  value: selectedTopicId,
                  dropdownColor: AppColors.surface,
                  decoration: const InputDecoration(labelText: 'Pilih Topik (Kategori)'),
                  items: topics
                      .map((t) => DropdownMenuItem<int>(
                            value: t['id'],
                            child: Text(t['name']),
                          ))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setDialogState(() => selectedTopicId = val);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: summaryCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Ringkasan'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: keyPointsCtrl,
                  decoration: const InputDecoration(labelText: 'Poin Penting'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal', style: TextStyle(color: AppColors.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
              onPressed: () async {
                final ok = await ApiService.createBookmark(
                  topicId: selectedTopicId,
                  title: widget.post['title'] ?? 'Tanpa Judul',
                  summary: summaryCtrl.text,
                  keyPoints: keyPointsCtrl.text,
                );
                if (!ctx.mounted) return;
                Navigator.pop(ctx);
                if (ok && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: AppColors.secondary,
                      content: Text('Berhasil disimpan ke koleksi!'),
                    ),
                  );
                  Navigator.pop(context, true);
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final likes = post['reactions']?['likes'] ?? 0;
    final views = post['views'] ?? 0;
    final List<dynamic> tags = post['tags'] ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Artikel')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post['title'] ?? '',
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.cardAlt,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.visibility, size: 16, color: AppColors.textMuted),
                              const SizedBox(width: 5),
                              Text(
                                '$views views',
                                style: const TextStyle(fontSize: 12, color: AppColors.textDark),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.favorite, size: 16, color: AppColors.primary),
                              const SizedBox(width: 5),
                              Text(
                                '$likes likes',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: tags
                          .map((t) => Chip(
                                label: Text('#$t'),
                                visualDensity: VisualDensity.compact,
                              ))
                          .toList(),
                    ),
                    const Divider(height: 24, color: AppColors.border),
                    Text(
                      post['body'] ?? '',
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.65,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _showSaveDialog,
                icon: const Icon(Icons.bookmark_add_rounded),
                label: const Text('Simpan ke Koleksi'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}