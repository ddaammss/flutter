import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sajunara_app/providers/user_state.dart';
import 'package:sajunara_app/services/api/kakao_login_api.dart';
import 'package:sajunara_app/services/api/naver_login_api.dart';
import 'package:sajunara_app/utils/token_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _nameController = TextEditingController();
  final _birthDateController = TextEditingController();
  final NaverLoginService _naverLoginService = NaverLoginService();
  final KakaoLoginService _kakaoLoginService = KakaoLoginService();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.8),
      body: Center(
        child: Container(
          margin: EdgeInsets.all(20),
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.indigo,
                child: Icon(Icons.person, size: 40, color: Colors.white),
              ),
              SizedBox(height: 20),
              Text('무물', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 30),

              // 소셜 로그인 버튼들
              _buildSocialLoginButton('네이버로 시작하기', Colors.green, Icons.login, () => _naverLogin()),
              SizedBox(height: 12),
              _buildSocialLoginButton('카카오로 시작하기', Colors.yellow[700]!, Icons.login, () => _kakaoLogin()),
              SizedBox(height: 12),
              // _buildSocialLoginButton('구글로 시작하기', Colors.red, Icons.login, () => _socialLogin('구글')),
              SizedBox(height: 20),

              OutlinedButton(
                onPressed: () => _showManualLoginDialog(context),
                style: OutlinedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
                child: Text('일반 회원가입'),
              ),

              SizedBox(height: 20),
              Text(
                '회원가입 시 이용약관 및 이메일, 업데이트 수신에\n동의하며 모든 개인정보 처리방침 및 활용동의 내용을\n확인하였음을 인정하는 것으로 간주됩니다.',
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialLoginButton(String text, Color color, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: text.contains('카카오') ? Colors.black87 : Colors.white,
        minimumSize: Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // 네이버 로그인 처리
  Future<void> _naverLogin() async {
    setState(() {
      _isLoading = true;
    });

    try {
      Map<String, dynamic>? result = await _naverLoginService.login();

      if (result == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      } else {
        String token = result['jwtToken'];
        String seq = result['seq'];
        final tokenService = TokenService();
        await tokenService.saveToken(token);
        await tokenService.saveUserSeq(seq);
      }

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/main');
        //_showSuccessDialog('네이버 로그인 성공!');
      }
    } catch (e) {
      _showErrorDialog('로그인 중 오류가 발생했습니다: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 카카오 로그인 처리
  Future<void> _kakaoLogin() async {
    setState(() {
      _isLoading = true;
    });
    try {
      Map<String, dynamic>? result = await _kakaoLoginService.loginWithKakaoTalk();

      if (result == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      } else {
        String token = result['jwtToken'];
        String seq = result['seq'];
        final tokenService = TokenService();
        await tokenService.saveToken(token);
        await tokenService.saveUserSeq(seq);
      }

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/main');
        //_showSuccessDialog('네이버 로그인 성공!');
      }
    } catch (e) {
      _showErrorDialog('로그인 중 오류가 발생했습니다: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 성공 다이얼로그
  // void _showSuccessDialog(String message) {
  //   showDialog(
  //     context: context,
  //     barrierDismissible: true, // ← 추가: 바깥 클릭 시 닫힘
  //     builder: (context) => AlertDialog(
  //       title: Text('성공'),
  //       content: Text(message),
  //       actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('확인'))],
  //     ),
  //   );
  // }

  // 에러 다이얼로그
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: true, // ← 추가: 바깥 클릭 시 닫힘
      builder: (context) => AlertDialog(
        title: Text('오류'),
        content: Text(message),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('확인'))],
      ),
    );
  }

  // 일반 회원가입 다이얼로그
  void _showManualLoginDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true, // ← 추가: 바깥 클릭 시 닫힘
      builder: (context) => AlertDialog(
        title: Text('회원정보 입력'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: '이름', border: OutlineInputBorder()),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _birthDateController,
              decoration: InputDecoration(labelText: '생년월일 (YYYY.MM.DD)', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('취소')),
          ElevatedButton(
            onPressed: () {
              if (_nameController.text.isNotEmpty && _birthDateController.text.isNotEmpty) {
                context.read<UserState>().login(_nameController.text, _birthDateController.text);
                Navigator.pop(context);
                Navigator.pop(context);
              }
            },
            child: Text('가입하기'),
          ),
        ],
      ),
    );
  }
}
