import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/news_model.dart';

class NewsService {
  // Đọc API key từ file .env
  static String get apiKey => dotenv.env['NEWS_API_KEY'] ?? '';
  static const String baseUrl = 'https://newsapi.org/v2';
  static const String _cacheKey = 'cached_news_articles';
  static const String _cacheTimeKey = 'cached_news_time';

  /// Kiểm tra xem có kết nối mạng không
  static Future<bool> _hasInternetConnection() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } catch (e) {
      print('Error checking connectivity: $e');
      return false;
    }
  }

  /// Lưu dữ liệu vào SharedPreferences
  static Future<void> _cacheArticles(List<Article> articles) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonData = json.encode(
        articles.map((article) => article.toJson()).toList(),
      );
      await prefs.setString(_cacheKey, jsonData);
      await prefs.setInt(_cacheTimeKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print('Error caching articles: $e');
    }
  }

  /// Lấy dữ liệu từ cache
  static Future<List<Article>?> _getCachedArticles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonData = prefs.getString(_cacheKey);
      if (jsonData == null) return null;

      final List<dynamic> decoded = json.decode(jsonData);
      return decoded.map((article) => Article.fromJson(article)).toList();
    } catch (e) {
      print('Error retrieving cached articles: $e');
      return null;
    }
  }

  /// Kiểm tra xem cache còn hợp lệ không (5 giờ)
  static Future<bool> _isCacheValid() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheTime = prefs.getInt(_cacheTimeKey) ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      final fiveHoursInMs = 5 * 60 * 60 * 1000;
      return (now - cacheTime) < fiveHoursInMs;
    } catch (e) {
      return false;
    }
  }

  /// Lấy danh sách tin tức hàng đầu
  ///
  /// Trả về dữ liệu từ API nếu có mạng
  /// Nếu mất mạng, sẽ trả về dữ liệu từ cache (nếu có)
  static Future<List<Article>> getTopHeadlines({String country = 'us'}) async {
    final hasInternet = await _hasInternetConnection();

    if (!hasInternet) {
      // Mất mạng - thử lấy dữ liệu từ cache
      final cachedArticles = await _getCachedArticles();
      if (cachedArticles != null && cachedArticles.isNotEmpty) {
        return cachedArticles;
      } else {
        throw Exception(
          '❌ Không có kết nối mạng.\n\n'
          'Vui lòng kiểm tra:\n'
          '• Kết nối WiFi/4G\n'
          '• Dữ liệu di động\n\n'
          'hoặc tải lại dữ liệu đã lưu trước đó.',
        );
      }
    }

    try {
      final String url =
          '$baseUrl/top-headlines?country=$country&apiKey=$apiKey';

      final response = await http
          .get(Uri.parse(url))
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () =>
                throw Exception('⏱️ Kết nối timed out. Vui lòng thử lại.'),
          );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        // Kiểm tra status từ API
        if (jsonData['status'] != 'ok') {
          throw Exception(
            '⚠️ Lỗi từ NewsAPI:\n${jsonData['message'] ?? jsonData['status']}',
          );
        }

        final List<dynamic> articles = jsonData['articles'] ?? [];
        final result = articles
            .map((article) => Article.fromJson(article))
            .toList();

        // Lưu vào cache nếu thành công
        await _cacheArticles(result);

        return result;
      } else if (response.statusCode == 401) {
        throw Exception(
          '🔑 API Key không hợp lệ.\n\n'
          'Vui lòng kiểm tra lại API key của bạn từ NewsAPI.org',
        );
      } else if (response.statusCode == 429) {
        throw Exception(
          '⚡ Quá nhiều yêu cầu.\n\n'
          'Bạn đã gửi quá nhiều yêu cầu.\n'
          'Vui lòng thử lại sau ít phút.',
        );
      } else if (response.statusCode == 426 || response.statusCode == 404) {
        throw Exception(
          '🚫 Yêu cầu không hợp lệ.\n\n'
          'Vui lòng kiểm tra lại cài đặt.',
        );
      } else {
        throw Exception(
          '❌ Lỗi server: ${response.statusCode}\n\n'
          'Server NewsAPI đang gặp sự cố.\n'
          'Vui lòng thử lại sau.',
        );
      }
    } on http.ClientException catch (e) {
      // Lỗi kết nối - thử dùng cache
      final cachedArticles = await _getCachedArticles();
      if (cachedArticles != null && cachedArticles.isNotEmpty) {
        return cachedArticles;
      } else {
        throw Exception(
          '🌐 Lỗi kết nối mạng.\n\n'
          'Không thể kết nối đến NewsAPI.org.\n'
          'Vui lòng kiểm tra kết nối internet của bạn.',
        );
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// Xóa cache (tùy chọn)
  static Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKey);
      await prefs.remove(_cacheTimeKey);
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }
}
