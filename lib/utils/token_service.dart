import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class TokenService {
  static const String _tokenKey = 'jwt_token';
  static const String _userSeq = 'user_seq';

  // 토큰 저장
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    print('✅ 토큰 저장 완료');
  }

  // 사용자 seq 저장
  Future<void> saveUserSeq(String seq) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userSeq, seq);
    print('✅ 토큰 저장 완료');
  }

  // 토큰 가져오기
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // 사용자 seq 가져오기
  Future<String?> getUserSeq() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userSeq);
  }

  // 토큰 삭제 (로그아웃)
  Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    print('✅ 토큰 삭제 완료');
  }

  // 토큰 존재 여부 확인
  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // 로그인 여부 확인 (토큰 존재 + 만료 체크)
  Future<bool> isLoggedIn() async {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      return false;
    }

    // 토큰 만료 여부 확인
    try {
      bool isExpired = JwtDecoder.isExpired(token);

      if (isExpired) {
        // 만료된 토큰은 자동 삭제
        print('⚠️ 토큰이 만료되었습니다');
        await deleteToken();
        return false;
      }

      return true;
    } catch (e) {
      print('❌ 토큰 검증 실패: $e');
      // 잘못된 토큰은 삭제
      await deleteToken();
      return false;
    }
  }

  // 토큰 만료 시간 확인 (남은 시간 반환)
  Future<Duration?> getTokenRemainingTime() async {
    final token = await getToken();

    if (token == null) {
      return null;
    }

    try {
      DateTime expirationDate = JwtDecoder.getExpirationDate(token);
      DateTime now = DateTime.now();

      if (expirationDate.isAfter(now)) {
        return expirationDate.difference(now);
      } else {
        return Duration.zero;
      }
    } catch (e) {
      print('❌ 토큰 만료 시간 확인 실패: $e');
      return null;
    }
  }

  // 토큰에서 사용자 정보 추출
  Future<Map<String, dynamic>?> getUserInfo() async {
    final token = await getToken();
    if (token == null) {
      return null;
    }

    try {
      // 만료 확인
      if (JwtDecoder.isExpired(token)) {
        print('⚠️ 토큰이 만료되었습니다');
        await deleteToken();
        return null;
      }

      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      return {
        'username': decodedToken['username'],
        'role': decodedToken['role'],
        'sub': decodedToken['sub'],
        'iat': decodedToken['iat'],
        'exp': decodedToken['exp'],
      };
    } catch (e) {
      print('❌ 토큰 디코딩 실패: $e');
      await deleteToken();
      return null;
    }
  }

  // 토큰이 곧 만료되는지 확인 (예: 1시간 이내)
  Future<bool> isTokenExpiringSoon({Duration threshold = const Duration(hours: 1)}) async {
    final remainingTime = await getTokenRemainingTime();

    if (remainingTime == null) {
      return true;
    }

    return remainingTime <= threshold;
  }
}
