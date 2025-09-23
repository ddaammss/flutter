import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sajunara_app/providers/user_state.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('내 정보'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Consumer<UserState>(
        builder: (context, userState, child) {
          if (!userState.isLoggedIn) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    '로그인이 필요한 서비스입니다',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    child: Text('로그인하기'),
                  ),
                ],
              ),
            );
          }

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
                        child: Text(
                          userState.userName.isNotEmpty
                              ? userState.userName[0]
                              : 'U',
                          style: TextStyle(fontSize: 24),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userState.userName.isNotEmpty
                                  ? userState.userName
                                  : '사용자',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              userState.userBirthDate.isNotEmpty
                                  ? userState.userBirthDate
                                  : '생년월일 미등록',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
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
                      child: Container(
                        margin: EdgeInsets.all(8),
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '보유 포인트',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '${userState.points}P',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.all(8),
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '보유 쿠폰',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '${userState.coupons.length}장',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // 메뉴 섹션
                _buildMenuSection(context, userState),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context, UserState userState) {
    final menuItems = [
      {'title': '내 정보', 'icon': Icons.person, 'onTap': () {}},
      {'title': '예약 기록', 'icon': Icons.calendar_today, 'onTap': () {}},
      {'title': '추천 관리', 'icon': Icons.favorite, 'onTap': () {}},
      {'title': '포인트 사용 기록', 'icon': Icons.monetization_on, 'onTap': () {}},
      {'title': '댓글 관리', 'icon': Icons.chat_bubble, 'onTap': () {}},
      {'title': '1:1 문의', 'icon': Icons.help, 'onTap': () {}},
    ];

    return Column(
      children: [
        ...menuItems
            .map(
              (item) => ListTile(
                leading: Icon(item['icon'] as IconData),
                title: Text(item['title'] as String),
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
                onTap: item['onTap'] as VoidCallback,
              ),
            )
            ,
        Divider(),
        ListTile(
          leading: Icon(Icons.logout, color: Colors.red),
          title: Text('로그아웃', style: TextStyle(color: Colors.red)),
          onTap: () {
            _showLogoutDialog(context, userState);
          },
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context, UserState userState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('로그아웃'),
        content: Text('정말 로그아웃 하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              userState.logout();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('로그아웃'),
          ),
        ],
      ),
    );
  }
}
