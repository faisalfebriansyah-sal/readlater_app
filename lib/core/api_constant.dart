class ApiConstant {
  static const String baseUrl = 'http://10.10.9.226:8000/api';

  // Auth Endpoints
  static const String register = '$baseUrl/register';
  static const String login = '$baseUrl/login';
  static const String logout = '$baseUrl/logout';

  // Laravel CRUD Endpoints
  static const String topics = '$baseUrl/topics';
  static const String bookmarks = '$baseUrl/bookmarks';

  // Public API Endpoint
  static const String dummyPosts = 'https://dummyjson.com/posts';
}