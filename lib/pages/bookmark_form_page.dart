import 'package:flutter/material.dart';
import '../main.dart';
import '../services/api_service.dart';

class BookmarkFormPage extends StatefulWidget {
  final Map<String, dynamic>? existingBookmark;
  const BookmarkFormPage({super.key, this.existingBookmark});

  @override
  State<BookmarkFormPage> createState() => _BookmarkFormPageState();
}

class _BookmarkFormPageState extends State<BookmarkFormPage> {
  final _titleCtrl = TextEditingController();
  final _summaryCtrl = TextEditingController();
  final _keyPointsCtrl = TextEditingController();
  List<dynamic> _topics = [];
  int? _selectedTopicId;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingBookmark != null) {
      _titleCtrl.text = widget.existingBookmark!['title'] ?? '';
      _summaryCtrl.text = widget.existingBookmark!['summary'] ?? '';
      _keyPointsCtrl.text = widget.existingBookmark!['key_points'] ?? '';
      _selectedTopicId = widget.existingBookmark!['topic_id'];
    }
    _fetchTopics();
  }

  Future<void> _fetchTopics() async {
    try {
      final data = await ApiService.getTopics();
      setState(() {
        _topics = data;
        if (_selectedTopicId == null && _topics.isNotEmpty) {
          _selectedTopicId = _topics.first['id'];
        }
      });
    } catch (_) {}
    setState(() => _loading = false);
  }

  Future<void> _submit() async {
    if (_selectedTopicId == null ||
        _titleCtrl.text.isEmpty ||
        _summaryCtrl.text.isEmpty ||
        _keyPointsCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.primary,
          content: Text('Semua field dan topik wajib diisi!'),
        ),
      );
      return;
    }

    setState(() => _saving = true);
    bool ok;
    if (widget.existingBookmark == null) {
      ok = await ApiService.createBookmark(
        topicId: _selectedTopicId!,
        title: _titleCtrl.text.trim(),
        summary: _summaryCtrl.text.trim(),
        keyPoints: _keyPointsCtrl.text.trim(),
      );
    } else {
      ok = await ApiService.updateBookmark(
        id: widget.existingBookmark!['id'],
        topicId: _selectedTopicId!,
        title: _titleCtrl.text.trim(),
        summary: _summaryCtrl.text.trim(),
        keyPoints: _keyPointsCtrl.text.trim(),
      );
    }
    setState(() => _saving = false);

    if (!mounted) return;
    if (ok) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.primary,
          content: Text('Gagal menyimpan bookmark'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingBookmark != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Bookmark' : 'Tambah Bookmark')),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DropdownButtonFormField<int>(
                        value: _selectedTopicId,
                        dropdownColor: AppColors.surface,
                        decoration: const InputDecoration(labelText: 'Pilih Topik'),
                        items: _topics
                            .map((t) => DropdownMenuItem<int>(
                                  value: t['id'],
                                  child: Text(t['name']),
                                ))
                            .toList(),
                        onChanged: (val) => setState(() => _selectedTopicId = val),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _titleCtrl,
                        decoration: const InputDecoration(labelText: 'Judul Artikel'),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _summaryCtrl,
                        maxLines: 3,
                        decoration: const InputDecoration(labelText: 'Ringkasan'),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _keyPointsCtrl,
                        maxLines: 2,
                        decoration: const InputDecoration(labelText: 'Poin Penting'),
                      ),
                      const SizedBox(height: 22),
                      ElevatedButton(
                        onPressed: _saving ? null : _submit,
                        child: _saving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(isEdit ? 'Update Bookmark' : 'Simpan Bookmark'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}