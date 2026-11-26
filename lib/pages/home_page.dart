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
  List<dynamic> _publicPosts = [];
  List<dynamic> _bookmarks = [];
  bool _loadingPublic = true;
  bool _loadingBookmarks = true;

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadPublicPosts();
    _loadBookmarks();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _userName = prefs.getString('user_name') ?? '';
    });
  }

  Future<void> _loadPublicPosts() async {
    setState(() => _loadingPublic = true);
    try {
      final data = await ApiService.fetchPublicPosts();
      if (!mounted) return;
      setState(() => _publicPosts = data);
    } catch (_) {}
    if (mounted) setState(() => _loadingPublic = false);
  }

  Future<void> _loadBookmarks() async {
    setState(() => _loadingBookmarks = true);
    try {
      final data = await ApiService.getBookmarks();
      if (!mounted) return;
      setState(() => _bookmarks = data);
    } catch (_) {}
    if (mounted) setState(() => _loadingBookmarks = false);
  }

  Future<void> _deleteBookmark(int id) async {
    final ok = await ApiService.deleteBookmark(id);
    if (ok) {
      _loadBookmarks();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.primary,
            content: Text('Bookmark dihapus'),
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

  @override
  Widget build(BuildContext context) {
    final isBookmarksTab = _selectedIndex == 1;
    final isProfileTab = _selectedIndex == 2;

    return Scaffold(
      appBar: isProfileTab
          ? null
          : AppBar(
              centerTitle: isBookmarksTab,
              title: isBookmarksTab
                  ? const Text('Bookmarks')
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_headerTitle()),
                        if (_userName.isNotEmpty)
                          Text(
                            'Halo, $_userName',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textMuted,
                            ),
                          ),
                      ],
                    ),
              actions: [
                IconButton(
                  tooltip: 'Profil',
                  icon: const Icon(
                    Icons.person_outline_rounded,
                    color: AppColors.secondary,
                  ),
                  onPressed: _openProfileRoute,
                ),
                IconButton(
                  tooltip: 'Kelola Topik',
                  icon: const Icon(
                    Icons.category_outlined,
                    color: AppColors.secondary,
                  ),
                  onPressed: () async {
                    await Navigator.pushNamed(context, AppRouting.topics);
                    _loadBookmarks();
                  },
                ),
                IconButton(
                  tooltip: 'Logout',
                  icon: const Icon(Icons.logout_rounded, color: AppColors.primary),
                  onPressed: _handleLogout,
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

  Widget _buildPublicTab() {
    if (_loadingPublic) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadPublicPosts,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 88),
        itemCount: _publicPosts.length,
        itemBuilder: (context, index) {
          final post = _publicPosts[index];
          final List<dynamic> tags = post['tags'] ?? [];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
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
                    Text(
                      post['title'] ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: tags
                          .map((t) => Chip(
                                label: Text(
                                  '#$t',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                visualDensity: VisualDensity.compact,
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
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
          // Ilustrasi folder & pita bookmark bergaya editorial hangat
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