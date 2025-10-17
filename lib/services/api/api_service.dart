import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';

class ApiService {
  final http.Client client = http.Client();

  String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8080'; // Android 에뮬레이터
    } else if (Platform.isIOS) {
      return 'http://localhost:8080'; // iOS 시뮬레이터
    } else {
      return 'http://localhost:8080';
    }
  }

  // ✅ POST 메서드 추가
  Future<http.Response> post(String endpoint, {Map<String, dynamic>? body}) async {
    final url = Uri.parse('$baseUrl$endpoint');

    print('🌐 POST 요청: $url');
    print('📦 요청 본문: $body');

    try {
      final response = await client
          .post(
            url,
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: body != null ? json.encode(body) : null,
          )
          .timeout(
            Duration(seconds: 10),
            onTimeout: () {
              throw Exception('요청 시간 초과');
            },
          );

      print('✅ 응답 성공: ${response.statusCode}');
      return response;
    } catch (e) {
      print('❌ API 에러: $e');
      rethrow;
    }
  }
}
