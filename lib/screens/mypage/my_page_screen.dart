import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sajunara_app/providers/app_state.dart';
import 'package:sajunara_app/services/api/user_api.dart';
import 'package:sajunara_app/utils/token_service.dart';

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  final TokenService _tokenService = TokenService();
  final UserApi _api = UserApi();
  bool _isLoggedIn = false;
  bool _isLoading = true;
  Map<String, dynamic>? _user;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final isLoggedIn = await _tokenService.isLoggedIn();
    if (isLoggedIn) {
      final userInfo = await _tokenService.getUserInfo();
      if (userInfo != null) {
        setState(() async {
          await _loadMyUserInfo();
          _isLoggedIn = true;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoggedIn = false;
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoggedIn = false;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMyUserInfo() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userSeq = await _tokenService.getUserSeq();
      final data = await _api.fetchUserData(requestBody: {'seq': userSeq});
      setState(() {
        // reverservationResponseDtos 리스트 추출
        _user = data;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ 예약 목록 조회 에러: $e');
      setState(() {
        _user = {};
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('예약 목록을 불러오는 중 오류가 발생했습니다'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _navigateToLogin() async {
    final result = await Navigator.pushNamed(context, '/login');

    if (result == true) {
      setState(() {
        _isLoading = true;
      });
      await _checkLoginStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('내 정보'), backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _isLoggedIn
          ? _buildUserInfo()
          : _buildLoginRequired(),
    );
  }

  Widget _buildLoginRequired() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            '로그인이 필요한 서비스입니다',
            style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 8),
          Text('내 정보를 확인하려면 로그인해주세요', style: TextStyle(fontSize: 14, color: Colors.grey[500])),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: _navigateToLogin,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('로그인하기', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo() {
    final userName = _user?['memberName']?.toString() ?? '사용자';
    final userEmail = _user?['email']?.toString() ?? '';
    final userBirthDate = _user?['birthYear']?.toString() ?? '';
    final userBirthday = _user?['birthday']?.toString() ?? '';
    final userBirthTime = _user?['birthTime']?.toString() ?? '';
    final profileImage = _user?['profileImage']?.toString();
    final point = _user?['point']?.toString();
    final coupon = _user?['coupon']?.toString();

    return SingleChildScrollView(
      child: Column(
        children: [
          // 프로필 섹션
          Container(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: profileImage != null && profileImage.isNotEmpty ? NetworkImage(profileImage) : null,
                  backgroundColor: Colors.grey[300],
                  child: profileImage == null || profileImage.isEmpty
                      ? Text(
                          userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                          style: TextStyle(fontSize: 24, color: Colors.white),
                        )
                      : null,
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(userName, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          if (userBirthDate.isNotEmpty || userBirthday.isNotEmpty) ...[
                            SizedBox(width: 8),
                            Icon(Icons.cake, size: 16, color: Colors.grey[600]),
                            SizedBox(width: 4),
                            Text(
                              '$userBirthDate${userBirthday.isNotEmpty ? "-$userBirthday" : ""}',
                              style: TextStyle(color: Colors.grey[600], fontSize: 14),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(userBirthTime, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 포인트 & 쿠폰
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/my_points');
                  },
                  child: Container(
                    margin: EdgeInsets.all(8),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
                    child: Column(
                      children: [
                        Text('보유 포인트', style: TextStyle(color: Colors.grey[600])),
                        SizedBox(height: 4),
                        Text(
                          '$point',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    //Navigator.push(context, MaterialPageRoute(builder: (context) => CouponDetailPage()));
                  },
                  child: Container(
                    margin: EdgeInsets.all(8),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.orange[50], borderRadius: BorderRadius.circular(8)),
                    child: Column(
                      children: [
                        Text('보유 쿠폰', style: TextStyle(color: Colors.grey[600])),
                        SizedBox(height: 4),
                        Text(
                          '$coupon장',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // 메뉴 섹션
          _buildMenuSection(),
        ],
      ),
    );
  }

  Widget _buildMenuSection() {
    final menuItems = [
      {
        'title': '내 정보',
        'icon': Icons.person,
        'onTap': () {
          Navigator.pushNamed(context, '/profile_edit');
        },
      },
      {
        'title': '예약 기록',
        'icon': Icons.calendar_today,
        'onTap': () {
          Navigator.pushNamed(context, '/my_booking');
        },
      },
      {
        'title': '추천 관리',
        'icon': Icons.favorite,
        'onTap': () {
          // TODO: 추천 관리 화면
        },
      },
      {
        'title': '포인트 사용 기록',
        'icon': Icons.monetization_on,
        'onTap': () {
          // TODO: 포인트 화면
        },
      },
      {
        'title': '댓글 관리',
        'icon': Icons.chat_bubble,
        'onTap': () {
          // TODO: 댓글 관리 화면
        },
      },
      {
        'title': '1:1 문의',
        'icon': Icons.help,
        'onTap': () {
          // TODO: 1:1 문의 화면
        },
      },
    ];

    return Column(
      children: [
        ...menuItems.map(
          (item) => ListTile(
            leading: Icon(item['icon'] as IconData),
            title: Text(item['title'] as String),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: item['onTap'] as VoidCallback,
          ),
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.logout, color: Colors.red),
          title: Text('로그아웃', style: TextStyle(color: Colors.red)),
          onTap: () async {
            await _tokenService.deleteToken();
            if (mounted) {
              context.read<AppState>().setCurrentIndex(0);
              Navigator.of(context).pushNamedAndRemoveUntil('/main', (route) => false);
            }
          },
        ),
      ],
    );
  }

  // void _showLogoutDialog() {
  //   showDialog(
  //     context: context,
  //     barrierDismissible: true,
  //     builder: (context) => AlertDialog(
  //       title: Text('로그아웃'),
  //       content: Text('정말 로그아웃 하시겠습니까?'),
  //       actions: [
  //         TextButton(onPressed: () => Navigator.pop(context), child: Text('취소')),
  //         ElevatedButton(
  //           onPressed: () async {
  //             Navigator.pop(context);
  //             await _handleLogout();
  //           },
  //           style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
  //           child: Text('로그아웃'),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
