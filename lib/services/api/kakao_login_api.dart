import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:sajunara_app/services/api/api_service.dart';

class KakaoLoginService {
  final ApiService _apiService = ApiService();
  // 카카오톡 앱으로 로그인
  Future<Map<String, dynamic>?> loginWithKakaoTalk() async {
    try {
      OAuthToken token = await UserApi.instance.loginWithKakaoTalk();
      print('카카오톡 로그인 성공 ${token.accessToken}');

      User user = await UserApi.instance.me();
      //print('===== 카카오 사용자 정보 =====');
      // print('회원번호: ${user.id}');
      // print('닉네임: ${user.kakaoAccount?.profile?.nickname}');
      // print('프로필 이미지: ${user.kakaoAccount?.profile?.profileImageUrl}');
      // print('썸네일 이미지: ${user.kakaoAccount?.profile?.thumbnailImageUrl}');
      // print('이메일: ${user.kakaoAccount?.email}');
      // print('이메일 인증 여부: ${user.kakaoAccount?.isEmailVerified}');
      // print('이메일 수신 동의: ${user.kakaoAccount?.isEmailValid}');
      // print('연령대: ${user.kakaoAccount?.ageRange}');
      // print('생일: ${user.kakaoAccount?.birthday}');
      // print('성별: ${user.kakaoAccount?.gender}');
      // print('전화번호: ${user.kakaoAccount?.phoneNumber}');
      //print('CI: ${user.kakaoAccount?.ci}');
      //print('연결 시간: ${user.connectedAt}');
      //print('==========================');
    } catch (error) {
      print('카카오톡 로그인 실패 $error');

      // 사용자가 명시적으로 취소한 경우만 중단
      // if (error is PlatformException && error.code == 'CANCELED') {
      //   print('사용자가 로그인을 취소했습니다');
      //   return;
      // }

      // 그 외 모든 경우 (카카오톡 미설치 등) 웹 로그인 시도
      print('웹 로그인 시도 시작');
      try {
        Map<String, dynamic>? result = await loginWithKakaoAccount();
        return result;
      } catch (error) {
        print('웹 로그인도 실패 $error');
      }
    }
  }

  // 카카오 계정으로 로그인 (웹)
  Future<Map<String, dynamic>?> loginWithKakaoAccount() async {
    try {
      OAuthToken token = await UserApi.instance.loginWithKakaoAccount();
      print('카카오계정 로그인 성공 ${token.accessToken}');

      User user = await UserApi.instance.me();
      // print('사용자 정보: ${user.kakaoAccount?.profile?.nickname}');
      // print('===== 카카오 사용자 정보 =====');
      // print('회원번호: ${user.id}');
      // print('닉네임: ${user.kakaoAccount?.profile?.nickname}');
      // print('프로필 이미지: ${user.kakaoAccount?.profile?.profileImageUrl}');
      // print('썸네일 이미지: ${user.kakaoAccount?.profile?.thumbnailImageUrl}');
      // print('이메일: ${user.kakaoAccount?.email}');
      // print('이메일 인증 여부: ${user.kakaoAccount?.isEmailVerified}');
      // print('이메일 수신 동의: ${user.kakaoAccount?.isEmailValid}');
      // print('연령대: ${user.kakaoAccount?.ageRange}');
      // print('생일: ${user.kakaoAccount?.birthday}');
      // print('성별: ${user.kakaoAccount?.gender}');
      // print('전화번호: ${user.kakaoAccount?.phoneNumber}');
      // //print('CI: ${user.kakaoAccount?.ci}');
      // print('연결 시간: ${user.connectedAt}');
      // print('==========================');
      Map<String, dynamic> requestBody = {
        'id': user.id.toString(),
        'email': user.kakaoAccount?.email ?? '',
        'name': user.kakaoAccount?.name ?? user.kakaoAccount?.profile?.nickname ?? '',
        'profileImage': user.kakaoAccount?.profile?.profileImageUrl ?? '',
        'age': user.kakaoAccount?.ageRange ?? '',
        'birthday': user.kakaoAccount?.birthday ?? '',
        'birthYear': user.kakaoAccount?.birthyear ?? '',
        'gender': user.kakaoAccount?.gender == 'male' ? '0' : '1',
        'phone': user.kakaoAccount?.phoneNumber ?? '',
      };
      final response = await _apiService.post('/app/api/kakao_login', body: requestBody);

      if (response.statusCode == 200) {
        Map<String, dynamic> result = jsonDecode(response.body);
        //print('result[data]================= ${result['data']}');
        return result['data'];
      }
    } catch (error) {
      print('카카오계정 로그인 실패 $error');
    }
  }

  // 로그인 여부 확인
  Future<bool> isLoggedIn() async {
    if (await AuthApi.instance.hasToken()) {
      try {
        AccessTokenInfo tokenInfo = await UserApi.instance.accessTokenInfo();
        return true;
      } catch (error) {
        return false;
      }
    }
    return false;
  }

  // 로그아웃
  Future<void> logout() async {
    try {
      await UserApi.instance.logout();
      print('로그아웃 성공');
    } catch (error) {
      print('로그아웃 실패 $error');
    }
  }

  // 연결 끊기 (회원 탈퇴)
  Future<void> unlink() async {
    try {
      await UserApi.instance.unlink();
      print('연결 끊기 성공');
    } catch (error) {
      print('연결 끊기 실패 $error');
    }
  }

  // 사용자 정보 가져오기
  Future<User?> getUserInfo() async {
    try {
      User user = await UserApi.instance.me();
      return user;
    } catch (error) {
      print('사용자 정보 요청 실패 $error');
      return null;
    }
  }
}
