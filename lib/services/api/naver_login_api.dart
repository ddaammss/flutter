import 'dart:convert';

import 'package:flutter_naver_login/flutter_naver_login.dart';
//import 'package:flutter_naver_login/interface/types/naver_token.dart';
import 'package:flutter_naver_login/interface/types/naver_account_result.dart';
import 'package:flutter_naver_login/interface/types/naver_login_result.dart';
import 'package:flutter_naver_login/interface/types/naver_login_status.dart';
import 'package:sajunara_app/models/login.dart';
import 'package:sajunara_app/services/api/api_service.dart';

class NaverLoginService {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>?> login() async {
    try {
      final NaverLoginResult result = await FlutterNaverLogin.logIn();
      if (result.status == NaverLoginStatus.loggedIn) {
        final NaverAccountResult account = await FlutterNaverLogin.getCurrentAccount();
        // print('📧 이메일: ${account.email}');
        // print('👤 이름: ${account.name}');
        // print('🎂 나이: ${account.age}');
        // print('🎁 생년월일: ${account.birthday}');
        // print('📅 출생연도: ${account.birthYear}');
        // print('👤 성별: ${account.gender}');
        // print('📱 휴대폰: ${account.phone}');
        // print('🆔 ID: ${account.id}');
        // print('🖼️ 프로필 사진: ${account.profileImage}');
        final Login naver = Login.fromLoginAccount(account);
        Map<String, dynamic> requestBody = {
          'id': naver.id,
          'email': naver.email,
          'name': naver.name,
          'profileImage': naver.profileImage,
          'age': naver.age,
          'birthday': naver.birthday,
          'birthYear': naver.birthYear,
          'gender': naver.gender == 'M' ? '0' : '1',
          'phone': naver.phone,
        };
        final response = await _apiService.post('/app/api/naver_login', body: requestBody);

        if (response.statusCode == 200) {
          Map<String, dynamic> result = jsonDecode(response.body);
          //print('result[data]================= ${result['data']}');
          return result['data'];
        }
      } else {
        print('로그인 실패: ${result.errorMessage}');
        return null;
      }
    } catch (e) {
      print('네이버 로그인 오류: $e');
      return null;
    }
  }

  // 로그아웃
  Future<void> logout() async {
    try {
      await FlutterNaverLogin.logOut();
      print('로그아웃 성공');
    } catch (e) {
      print('로그아웃 실패: $e');
    }
  }
}
