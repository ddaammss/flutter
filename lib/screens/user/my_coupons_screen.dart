import 'package:flutter/material.dart';
import 'package:sajunara_app/services/api/user_api.dart';
import 'package:sajunara_app/utils/token_service.dart';

class MyCouponsScreen extends StatefulWidget {
  const MyCouponsScreen({super.key});

  @override
  State<MyCouponsScreen> createState() => _MyCouponsScreenState();
}

class _MyCouponsScreenState extends State<MyCouponsScreen> {
  final TokenService _tokenService = TokenService();
  final UserApi _api = UserApi();

  bool _isLoading = false;
  List<dynamic> _couponsList = [];

  @override
  void initState() {
    super.initState();
    _loadCouponsData();
  }

  Future<void> _loadCouponsData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userSeq = await _tokenService.getUserSeq();
      final data = await _api.fetchUserCoupon(requestBody: {'seq': userSeq});

      setState(() {
        _couponsList = data['couponsList'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      print('❌ 쿠폰 조회 에러: $e');
      setState(() {
        _couponsList = [];
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('쿠폰 내역을 불러오는 중 오류가 발생했습니다'),
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
      appBar: AppBar(title: Text('보유 쿠폰'), backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 1),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 쿠폰 개수 표시
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  color: Colors.blue[50],
                  child: Column(
                    children: [
                      Text('보유 쿠폰', style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                      SizedBox(height: 8),
                      Text(
                        '${_couponsList.length}장',
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue[700]),
                      ),
                    ],
                  ),
                ),

                // 쿠폰 받은 리스트 헤더
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  color: Colors.grey[100],
                  child: Text('쿠폰 받은 리스트', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),

                // 쿠폰 리스트
                Expanded(
                  child: _couponsList.isEmpty
                      ? Center(
                          child: Text('보유한 쿠폰이 없습니다', style: TextStyle(color: Colors.grey)),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.all(16),
                          itemCount: _couponsList.length,
                          itemBuilder: (context, index) {
                            final coupon = _couponsList[index];
                            return Container(
                              margin: EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.blue[300]!),
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.white,
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // 쿠폰명
                                    Text(
                                      coupon['couponName'] ?? '신규 회원가입 쿠폰',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 12),

                                    // 쿠폰 금액
                                    Row(
                                      children: [
                                        Icon(Icons.card_giftcard, size: 20, color: Colors.blue[700]),
                                        SizedBox(width: 8),
                                        Text(
                                          '${coupon['amount']?.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},') ?? '5,000'}원',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),

                                    // 사용 기간
                                    Row(
                                      children: [
                                        Icon(Icons.access_time, size: 18, color: Colors.grey[600]),
                                        SizedBox(width: 8),
                                        Text(
                                          '사용기간: ${coupon['expiryDate'] ?? '2025.12.31'}',
                                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
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
