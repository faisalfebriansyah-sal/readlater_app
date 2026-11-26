import 'package:flutter/material.dart';
import '../pages/splash_page.dart';
import '../pages/login_page.dart';
import '../pages/register_page.dart';
import '../pages/home_page.dart';
import '../pages/public_post_detail_page.dart';
import '../pages/topic_page.dart';
import '../pages/bookmark_form_page.dart';
import '../pages/profile_page.dart';

class AppRouting {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String publicDetail = '/public-detail';
  static const String topics = '/topics';
  static const String bookmarkForm = '/bookmark-form';
  static const String profile = '/profile';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashPage());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterPage());
      case home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case publicDetail:
        final post = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => PublicPostDetailPage(post: post),
        );
      case topics:
        return MaterialPageRoute(builder: (_) => const TopicPage());
      case bookmarkForm:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => BookmarkFormPage(existingBookmark: args),
        );
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfilePage());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Halaman tidak ditemukan')),
          ),
        );
    }
  }
}