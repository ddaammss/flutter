import 'package:flutter/material.dart';
import 'package:sajunara_app/services/api/api_service.dart';
import 'package:sajunara_app/services/api/user_api.dart';
import 'package:sajunara_app/utils/token_service.dart';

class MyPointsScreen extends StatefulWidget {
  const MyPointsScreen({super.key});

  @override
  State<MyPointsScreen> createState() => _MyPointsScreenState();
}

class _MyPointsScreenState extends State<MyPointsScreen> {
  final TokenService _tokenService = TokenService();
  final UserApi _api = UserApi();

  bool _isLoading = false;
  List<dynamic> _pointsList = [];
  int _totalPoints = 0;

  @override
  void initState() {
    super.initState();
    _loadPointsData();
  }

  Future<void> _loadPointsData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userSeq = await _tokenService.getUserSeq();
      final data = await _api.fetchUserPoint(requestBody: {'seq': userSeq});

      setState(() {
        _pointsList = data['pointResponseDtos'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      print('❌ 포인트 조회 에러: $e');
      setState(() {
        _pointsList = [];
        _totalPoints = 0;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('포인트 내역을 불러오는 중 오류가 발생했습니다'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('보유 포인트'), backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 1),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 총 포인트 표시
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  color: Colors.blue[50],
                  child: Column(
                    children: [
                      Text('보유 포인트', style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                      SizedBox(height: 8),
                      Text(
                        '${_pointsList[0]['point'].toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} P',
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue[700]),
                      ),
                    ],
                  ),
                ),

                // 포인트 받은 리스트 헤더
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  color: Colors.grey[100],
                  child: Text('포인트 받은 리스트', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),

                // 포인트 내역 리스트
                Expanded(
                  child: _pointsList.isEmpty
                      ? Center(
                          child: Text('포인트 내역이 없습니다', style: TextStyle(color: Colors.grey)),
                        )
                      : ListView.builder(
                          itemCount: _pointsList.length,
                          itemBuilder: (context, index) {
                            final item = _pointsList[index];
                            return Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '(${item['storeName'] ?? '입점사명'})',
                                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          '${item['reason'] ?? '이용 완료 포인트'}',
                                          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '+${item['point'] ?? 500} 포인트',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue[700],
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        '이용일: ${item['createdAt'] ?? '2025-11-11'}',
                                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
