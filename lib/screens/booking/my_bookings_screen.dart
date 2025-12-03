import 'package:flutter/material.dart';
import 'package:sajunara_app/models/store.dart';
import 'package:sajunara_app/services/api/booking_api.dart';
import 'package:sajunara_app/utils/token_service.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  final TokenService _tokenService = TokenService();
  final BookingApi _api = BookingApi();

  bool _isLoggedIn = false;
  bool _isLoading = true;
  List<dynamic> _reservationList = []; // ← Map에서 List로 변경!

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
        await _loadMyBookingList();
      } else {
        setState(() {
          _isLoggedIn = false;
          _isLoading = false;
        });
        return;
      }
    }

    setState(() {
      _isLoggedIn = isLoggedIn;
      _isLoading = false;
    });
  }

  Future<void> _loadMyBookingList() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userSeq = await _tokenService.getUserSeq();
      final data = await _api.fetctMyBookingDetailData(requestBody: {'seq': userSeq});

      setState(() {
        // reverservationResponseDtos 리스트 추출
        _reservationList = (data['reverservationResponseDtos'] as List<dynamic>?) ?? [];
        _isLoading = false;
      });

      print('✅ 예약 개수: ${_reservationList.length}');
    } catch (e) {
      print('❌ 예약 목록 조회 에러: $e');
      setState(() {
        _reservationList = [];
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
      appBar: AppBar(title: Text('나의 예약'), backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _isLoggedIn
          ? _buildBookingList()
          : _buildLoginRequired(context),
    );
  }

  Widget _buildLoginRequired(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.login, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            '로그인이 필요한 서비스입니다',
            style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 8),
          Text('예약 내역을 확인하려면 로그인해주세요', style: TextStyle(fontSize: 14, color: Colors.grey[500])),
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

  Widget _buildBookingList() {
    if (_reservationList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text('예약 내역이 없습니다', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshBookings,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _reservationList.length,
        itemBuilder: (context, index) {
          final reservation = _reservationList[index];
          if (reservation == null) return SizedBox.shrink();
          return _buildBookingItem(context, reservation: reservation);
        },
      ),
    );
  }

  Future<void> _refreshBookings() async {
    final isLoggedIn = await _tokenService.isLoggedIn();

    if (!isLoggedIn) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('세션이 만료되었습니다. 다시 로그인해주세요.'),
            action: SnackBarAction(label: '로그인', onPressed: _navigateToLogin),
          ),
        );

        setState(() {
          _isLoggedIn = false;
        });
      }
      return;
    }

    await _loadMyBookingList();

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('✅ 예약 목록 새로고침 완료'), duration: Duration(seconds: 1)));
    }
  }

  String _formatPrice(String? price) {
    if (price == null || price.isEmpty) return '0';
    final priceInt = int.tryParse(price) ?? 0;
    return priceInt.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
  }

  Widget _buildBookingItem(BuildContext context, {required dynamic reservation}) {
    // null 체크 및 데이터 추출
    final storeSeq = reservation['storeSeq']?.toString();
    final storeName = reservation['storeName']?.toString() ?? '상점명 없음';
    final productName = reservation['productName']?.toString() ?? '-';
    final reservationDate = reservation['reservationDate']?.toString() ?? '-';
    final reservationTime = reservation['reservationTime']?.toString() ?? '';
    final productPrice = reservation['productPrice']?.toString();
    final reservationCode = reservation['reservationCode']?.toString() ?? '-';
    return GestureDetector(
      onTap: () {
        if (storeSeq != null && storeSeq.isNotEmpty) {
          final store = Store(
            seq: storeSeq,
            storeCode: reservation['storeCode']?.toString() ?? '',
            storeName: storeName,
            grade: reservation['grade']?.toString() ?? '0',
            reviewCount: reservation['reviewCount']?.toString() ?? '0',
          );

          Navigator.pushNamed(context, '/store_detail', arguments: store);
        }
      },
      child: Card(
        margin: EdgeInsets.only(bottom: 16),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 입점사명
              Row(
                children: [
                  Icon(Icons.store, size: 20, color: Colors.orange),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(storeName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      '예약완료',
                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),

              Divider(height: 24, thickness: 1),

              // 예약 상품
              Row(
                children: [
                  Icon(Icons.shopping_bag, size: 18, color: Colors.grey[600]),
                  SizedBox(width: 8),
                  Text('예약상품: ', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                  Expanded(
                    child: Text(productName, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  ),
                ],
              ),
              SizedBox(height: 4),

              // 예약일
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 18, color: Colors.grey[600]),
                  SizedBox(width: 8),
                  Text('예약일: ', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                  Text(
                    '$reservationDate ($reservationTime)',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                ],
              ),
              SizedBox(height: 4),

              // 가격
              Row(
                children: [
                  Icon(Icons.attach_money, size: 18, color: Colors.grey[600]),
                  SizedBox(width: 8),
                  Text('금액: ', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                  Text(
                    '${_formatPrice(productPrice)}원',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.orange),
                  ),
                  Spacer(),
                  Text('예약번호: $reservationCode', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
