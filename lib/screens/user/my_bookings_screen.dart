import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sajunara_app/providers/user_state.dart';

class MyBookingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('나의 예약'),
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
                  Icon(Icons.login, size: 80, color: Colors.grey),
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

          return ListView(
            padding: EdgeInsets.all(16),
            children: [
              _buildBookingItem(
                context,
                storeName: '운명을 설계하는 타로 마스터',
                service: '직업',
                date: '2025-04-22',
                status: '확정',
                statusColor: Colors.green,
              ),
              _buildBookingItem(
                context,
                storeName: '정통 사주명리학원',
                service: '재물',
                date: '2025-04-18',
                status: '이용완료',
                statusColor: Colors.grey,
              ),
              _buildBookingItem(
                context,
                storeName: '동양철학연구소',
                service: '합격',
                date: '2025-04-15',
                status: '이용완료',
                statusColor: Colors.grey,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBookingItem(
    BuildContext context, {
    required String storeName,
    required String service,
    required String date,
    required String status,
    required Color statusColor,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.store, color: Colors.grey[400]),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    storeName,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 4),
                  Text('서비스: $service'),
                  Text('예약일: $date'),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
