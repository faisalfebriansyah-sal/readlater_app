import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/app_routing.dart';
import '../main.dart';
import '../pages/profile_page.dart';
import '../services/api_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String _userName = '';
  String _searchQuery = '';
  String? _selectedTag;
  List<dynamic> _publicPosts = [];
  List<dynamic> _bookmarks = [];
  bool _loadingPublic = true;
  bool _loadingBookmarks = true;
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadPublicPosts();
    _loadBookmarks();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _userName = prefs.getString('user_name') ?? '';
    });
  }

  Future<void> _loadPublicPosts() async {
    if (mounted) setState(() => _loadingPublic = true);
    try {
      final data = await ApiService.fetchPublicPosts();
      if (!mounted) return;
      setState(() {
        _publicPosts = data;
        // FIX: Jangan reset _selectedTag di sini, biar filter gak hilang pas refresh
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.primary,
            content: Text('Gagal memuat artikel publik: $e'),
          ),
        );
      }
    }
    if (mounted) setState(() => _loadingPublic = false);
  }

  Future<void> _loadBookmarks() async {
    if (mounted) setState(() => _loadingBookmarks = true);
    try {
      final data = await ApiService.getBookmarks();
      if (!mounted) return;
      setState(() => _bookmarks = data);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.primary,
            content: Text('Gagal memuat bookmarks: $e'),
          ),
        );
      }
    }
    if (mounted) setState(() => _loadingBookmarks = false);
  }

  Future<void> _deleteBookmark(int id) async {
    // FIX: Tambah konfirmasi dulu
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Bookmark?'),
        content: const Text('Artikel ini akan dihapus dari koleksi kamu.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final ok = await ApiService.deleteBookmark(id);
    if (ok) {
      await _loadBookmarks();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.primary,
            content: Text('Bookmark dihapus'),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.primary,
            content: Text('Gagal menghapus bookmark'),
          ),
        );
      }
    }
  }

  Future<void> _handleLogout() async {
    await ApiService.logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, AppRouting.login, (route) => false);
  }

  Future<void> _openAddArticleForm() async {
    final res = await Navigator.pushNamed(context, AppRouting.bookmarkForm);
    if (res == true && mounted) {
      setState(() => _selectedIndex = 1);
      await _loadBookmarks();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.secondary,
            content: Text('Artikel berhasil ditambahkan ke Bookmarks'),
          ),
        );
      }
    }
  }

  Future<void> _openProfileRoute() async {
    await Navigator.pushNamed(context, AppRouting.profile);
    await _loadUserName();
  }

  String _headerTitle() {
    if (_selectedIndex == 0) return 'Jelajah Artikel';
    if (_selectedIndex == 1) return 'Bookmarks';
    return 'Profil';
  }

  Widget _buildCurrentBody() {
    if (_selectedIndex == 0) return _buildPublicTab();
    if (_selectedIndex == 1) return _buildBookmarkTab();
    return const ProfilePage();
  }

  Widget _buildTopActionButton({
    required String tooltip,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Material(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.border),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Tooltip(
            message: tooltip,
            child: SizedBox(
              width: 38,
              height: 38,
              child: Icon(icon, color: color, size: 20),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isBookmarksTab = _selectedIndex == 1;
    final isProfileTab = _selectedIndex == 2;

    return Scaffold(
      appBar: isProfileTab
          ? null
          : AppBar(
              toolbarHeight: 68,
              centerTitle: isBookmarksTab,
              title: isBookmarksTab
                  ? const Text('Bookmarks')
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_headerTitle()),
                        if (_userName.isNotEmpty)
                          Row(
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(
                                  color: AppColors.secondary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  'Halo, $_userName',
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
              actions: [
                _buildTopActionButton(
                  tooltip: 'Profil',
                  icon: Icons.person_outline_rounded,
                  color: AppColors.secondary,
                  onPressed: _openProfileRoute,
                ),
                _buildTopActionButton(
                  tooltip: 'Kelola Topik',
                  icon: Icons.category_outlined,
                  color: AppColors.secondary,
                  onPressed: () async {
                    await Navigator.pushNamed(context, AppRouting.topics);
                    _loadBookmarks();
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _buildTopActionButton(
                    tooltip: 'Logout',
                    icon: Icons.logout_rounded,
                    color: AppColors.primary,
                    onPressed: _handleLogout,
                  ),
                ),
              ],
            ),
      body: _buildCurrentBody(),
      floatingActionButton: isProfileTab
          ? null
          : FloatingActionButton.extended(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              onPressed: _openAddArticleForm,
              icon: const Icon(Icons.add),
              label: const Text('Tambah Artikel'),
            ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primary.withValues(alpha: 0.16),
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) {
          setState(() => _selectedIndex = i);
          if (i == 1) _loadBookmarks();
          if (i == 2) _loadUserName();
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.public_outlined),
            selectedIcon: Icon(Icons.public, color: AppColors.primary),
            label: 'Artikel Publik',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_border),
            selectedIcon: Icon(Icons.bookmark, color: AppColors.primary),
            label: 'Bookmarks',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded, color: AppColors.primary),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  List<String> _popularTags({int limit = 8}) {
    final Map<String, int> counts = {};
    for (final post in _publicPosts) {
      final tags = post['tags'] as List<dynamic>? ?? [];
      for (final t in tags) {
        final tag = t.toString().toLowerCase().trim();
        if (tag.isNotEmpty) {
          counts[tag] = (counts[tag] ?? 0) + 1;
        }
      }
    }
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(limit).map((e) => e.key).toList();
  }

  void _selectTagFilter(String? tag) {
    setState(() {
      if (tag == null || _selectedTag == tag) {
        _selectedTag = null;
        _searchQuery = '';
        _searchCtrl.clear();
      } else {
        _selectedTag = tag;
        _searchQuery = tag;
        _searchCtrl.text = tag;
      }
    });
  }

  List<dynamic> _filteredPublicPosts() {
    final q = _searchQuery.toLowerCase().trim();
    return _publicPosts.where((post) {
      final postTags = (post['tags'] as List<dynamic>? ?? [])
          .map((e) => e.toString().toLowerCase().trim())
          .toList();

      if (_selectedTag != null && !postTags.contains(_selectedTag)) {
        return false;
      }

      if (q.isEmpty) return true;
      final title = (post['title'] ?? '').toString().toLowerCase();
      final body = (post['body'] ?? '').toString().toLowerCase();
      final tagsJoined = postTags.join(' ');
      return title.contains(q) || body.contains(q) || tagsJoined.contains(q);
    }).toList();
  }

  Widget _buildTagFilterBar() {
    final popularTags = _popularTags();
    if (popularTags.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: SizedBox(
        height: 38,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: popularTags.length + 1,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            if (index == 0) {
              final isAllSelected = _selectedTag == null && _searchQuery.trim().isEmpty;
              return ChoiceChip(
                label: const Text('Semua'),
                selected: isAllSelected,
                onSelected: (_) => _selectTagFilter(null),
                selectedColor: AppColors.secondary,
                backgroundColor: AppColors.surface,
                labelStyle: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: isAllSelected ? Colors.white : AppColors.textDark,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                  side: BorderSide(
                    color: isAllSelected ? AppColors.secondary : AppColors.border,
                  ),
                ),
                showCheckmark: false,
              );
            }

            final tag = popularTags[index - 1];
            final isSelected = _selectedTag == tag;
            return ChoiceChip(
              label: Text('#$tag'),
              selected: isSelected,
              onSelected: (_) => _selectTagFilter(tag),
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.surface,
              labelStyle: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textDark,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
                side: BorderSide(
                  color: isSelected ? AppColors.primary : AppColors.border,
                ),
              ),
              showCheckmark: false,
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.secondary.withValues(alpha: 0.14),
            AppColors.primary.withValues(alpha: 0.10),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.auto_stories_rounded,
              color: AppColors.secondary,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bacaan Kurasi Publik',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_publicPosts.length} artikel siap dibaca & disimpan ke koleksi',
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (val) => setState(() {
          _searchQuery = val;
          if (_selectedTag != null && val.toLowerCase().trim() != _selectedTag) {
            _selectedTag = null;
          }
        }),
        decoration: InputDecoration(
          hintText: 'Cari judul, isi, atau tag (#history, #fiction)...',
          hintStyle: const TextStyle(fontSize: 13.5, color: AppColors.textMuted),
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.secondary),
          suffixIcon: (_searchQuery.isNotEmpty || _selectedTag != null)
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                  onPressed: () => _selectTagFilter(null),
                )
              : null,
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.secondary, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyPublicState() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(Icons.search_off_rounded, color: AppColors.primary, size: 34),
          const SizedBox(height: 10),
          const Text(
            'Artikel tidak ditemukan',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Coba kata kunci atau tag lain untuk "$_searchQuery".',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () => _selectTagFilter(null),
            child: const Text('Reset Pencarian'),
          ),
        ],
      ),
    );
  }

  Widget _buildPublicTab() {
    if (_loadingPublic) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    final posts = _filteredPublicPosts();

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadPublicPosts,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 92),
        children: [
          _buildHeaderCard(),
          _buildSearchField(),
          _buildTagFilterBar(),
          if (posts.isEmpty)
            _buildEmptyPublicState()
          else
            ...posts.asMap().entries.map((entry) {
              final postIndex = entry.key;
              final post = entry.value;
              final List<dynamic> tags = post['tags'] ?? [];
              final String mainTag = tags.isNotEmpty ? tags.first.toString().toUpperCase() : 'ARTIKEL';
              final String bodyText = (post['body'] ?? '').toString();
              final int views = post['views'] ?? 0;
              final int likes = post['reactions']?['likes'] ?? 0;

              return Card(
                margin: const EdgeInsets.only(bottom: 14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () async {
                    final saved = await Navigator.pushNamed(
                      context,
                      AppRouting.publicDetail,
                      arguments: post,
                    );
                    if (saved == true) _loadBookmarks();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.secondary.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                mainTag,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                  color: AppColors.secondary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '#${postIndex + 1}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textMuted,
                              ),
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          post['title'] ?? '',
                          style: const TextStyle(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                            height: 1.3,
                          ),
                        ),
                        if (bodyText.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            bodyText,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              height: 1.45,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                        if (tags.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: tags
                                .map((t) => Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: AppColors.cardAlt,
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      child: Text(
                                        '#$t',
                                        style: const TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textDark,
                                        ),
                                      ),
                                    ))
                                .toList(),
                          ),
                        ],
                        const Divider(height: 20, color: AppColors.border),
                        Row(
                          children: [
                            const Icon(Icons.visibility_outlined, size: 15, color: AppColors.textMuted),
                            const SizedBox(width: 4),
                            Text(
                              '$views',
                              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                            ),
                            const SizedBox(width: 14),
                            const Icon(Icons.favorite_border_rounded, size: 15, color: AppColors.primary),
                            const SizedBox(width: 4),
                            Text(
                              '$likes',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                            const Spacer(),
                            const Text(
                              'Baca & Simpan',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.secondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildEmptyBookmarksState() {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadBookmarks,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(28, 36, 28, 96),
        children: [
          const SizedBox(height: 16),
          Center(
            child: SizedBox(
              width: 190,
              height: 160,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    bottom: 8,
                    child: Container(
                      width: 140,
                      height: 20,
                      decoration: BoxDecoration(
                        color: AppColors.cardAlt,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 26,
                    child: Transform.rotate(
                      angle: 0.08,
                      child: Container(
                        width: 84,
                        height: 54,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.border),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 126,
                    height: 94,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border, width: 1.4),
                    ),
                    child: Center(
                      child: Container(
                        width: 38,
                        height: 46,
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.bookmark_rounded,
                          color: AppColors.secondary,
                          size: 26,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    left: 24,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.14),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.auto_stories_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'Add Bookmarks',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Jangan lupa simpan artikel yang paling kamu sukai agar mudah dibaca ulang dan diringkas di sini.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5,
              height: 1.5,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: [
              ElevatedButton.icon(
                onPressed: _openAddArticleForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Tambah Artikel'),
              ),
              OutlinedButton.icon(
                onPressed: () => setState(() => _selectedIndex = 0),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textDark,
                  side: const BorderSide(color: AppColors.border),
                  padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                icon: const Icon(Icons.explore_outlined, size: 18, color: AppColors.primary),
                label: const Text('Jelajah Publik'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBookmarkTab() {
    if (_loadingBookmarks) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (_bookmarks.isEmpty) {
      return _buildEmptyBookmarksState();
    }
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadBookmarks,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 88),
        itemCount: _bookmarks.length,
        itemBuilder: (context, index) {
          final item = _bookmarks[index];
          final topicName = item['topic']?['name'] ?? 'Tanpa Topik';
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          topicName,
                          style: const TextStyle(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.secondary),
                        onPressed: () async {
                          final updated = await Navigator.pushNamed(
                            context,
                            AppRouting.bookmarkForm,
                            arguments: item,
                          );
                          if (updated == true) _loadBookmarks();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.primary),
                        onPressed: () => _deleteBookmark(item['id']),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item['title'] ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item['summary'] ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.textMuted),
                  ),
                  const Divider(height: 18, color: AppColors.border),
                  Text(
                    'Poin Penting: ${item['key_points'] ?? '-'}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textDark,
                      fontStyle: FontStyle.italic,
                    ),
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