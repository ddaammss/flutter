import 'package:flutter/material.dart';
import 'package:sajunara_app/models/booking.dart';
import 'package:sajunara_app/services/api/booking_api.dart';
import 'package:sajunara_app/utils/token_service.dart';

class BookingScreen extends StatefulWidget {
  final Booking booking;
  const BookingScreen({super.key, required this.booking});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final TokenService _tokenService = TokenService();
  final BookingApi _api = BookingApi();
  final String baseUrl = 'https://amita86tg.duckdns.org';

  Booking? _bookingDetail;
  bool _isLoggedIn = false;
  bool _isLoading = true;
  String? _errorMessage;

  DateTime? selectedDate;
  String? selectedTime;
  int quantity = 1;

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
          await _loadBookingDetail();
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

  Future<void> _loadBookingDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _api.fetctBookingDetailData(requestBody: widget.booking.toJson());

      setState(() {
        _bookingDetail = Booking.fromJson(data);
        _isLoading = false;
      });
    } catch (e) {
      print('❌ 예약 상세 조회 에러: $e');
      setState(() {
        _errorMessage = '데이터를 불러오는데 실패했습니다: $e';
        _isLoading = false;
      });
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

  List<String> _getTimeSlots() {
    final startTime = _bookingDetail?.startTime ?? widget.booking.startTime;
    final endTime = _bookingDetail?.endTime ?? widget.booking.endTime;

    if (startTime.isEmpty || endTime.isEmpty) return [];

    List<String> slots = [];
    DateTime now = DateTime.now();

    DateTime start = _parseTime(now, startTime);
    DateTime end = _parseTime(now, endTime);
    DateTime current = start;

    while (current.isBefore(end) || current.isAtSameMomentAs(end)) {
      String timeSlot = '${current.hour.toString().padLeft(2, '0')}:${current.minute.toString().padLeft(2, '0')}';
      slots.add(timeSlot);
      current = current.add(Duration(hours: 1));
    }

    return slots;
  }

  DateTime _parseTime(DateTime base, String time) {
    List<String> parts = time.split(':');
    return DateTime(base.year, base.month, base.day, int.parse(parts[0]), int.parse(parts[1]));
  }

  bool _isReservedTime(String time) {
    final reservedTimes = _bookingDetail?.reservedTimes ?? widget.booking.reservedTimes;
    return reservedTimes.contains(time);
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('예약하기'), backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _isLoggedIn
          ? _buildBookingContent()
          : _buildLoginRequired(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildLoginRequired() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            '로그인이 필요한 서비스입니다',
            style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 8),
          Text('예약을 하려면 로그인해주세요', style: TextStyle(fontSize: 14, color: Colors.grey[500])),
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

  Widget _buildBookingContent() {
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(_errorMessage!),
            SizedBox(height: 16),
            ElevatedButton(onPressed: _loadBookingDetail, child: Text('다시 시도')),
          ],
        ),
      );
    }

    // ✅ 데이터 바인딩
    final storeName = _bookingDetail?.storeName ?? widget.booking.storeName;
    final address = _bookingDetail?.address ?? widget.booking.address;
    final grade = _bookingDetail?.grade ?? widget.booking.grade;
    final reviewCount = _bookingDetail?.reviewCount ?? widget.booking.reviewCount;
    final productName = _bookingDetail?.productName ?? widget.booking.productName;
    final productPrice = _bookingDetail?.productPrice ?? widget.booking.productPrice;
    final imagePath = _bookingDetail?.imagePath ?? widget.booking.imagePath;

    final timeSlots = _getTimeSlots();

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 입점사 정보
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
                  child: imagePath.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            '$baseUrl$imagePath',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(Icons.store, color: Colors.grey[400]);
                            },
                          ),
                        )
                      : Icon(Icons.store, color: Colors.grey[400]),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(storeName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(
                        address,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 16),
                          Text((double.tryParse(grade) ?? 0.0).toStringAsFixed(1)),
                          SizedBox(width: 8),
                          Icon(Icons.message, color: Colors.grey, size: 14),
                          Text(reviewCount),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24),

          // 상품 정보
          _buildSection(
            title: '선택한 상품',
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(productName, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  Text(
                    '${_formatPrice(int.tryParse(productPrice) ?? 0)}원',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 24),

          // 날짜 선택
          _buildSection(
            title: '날짜 선택 *',
            child: GestureDetector(
              onTap: () async {
                final DateTime? date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(Duration(days: 30)),
                );
                if (date != null) {
                  setState(() {
                    selectedDate = date;
                    selectedTime = null;
                  });
                }
              },
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, color: Colors.grey),
                    SizedBox(width: 12),
                    Text(
                      selectedDate != null
                          ? '${selectedDate!.year}.${selectedDate!.month.toString().padLeft(2, '0')}.${selectedDate!.day.toString().padLeft(2, '0')}'
                          : '날짜를 선택하세요',
                      style: TextStyle(color: selectedDate != null ? Colors.black : Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 24),

          // 시간 선택
          _buildSection(
            title: '시간 선택 *',
            child: timeSlots.isEmpty
                ? Text('영업시간 정보가 없습니다', style: TextStyle(color: Colors.grey))
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: timeSlots.map((time) {
                      final isSelected = selectedTime == time;
                      final isReserved = _isReservedTime(time);

                      return Opacity(
                        opacity: isReserved ? 0.4 : 1.0,
                        child: GestureDetector(
                          onTap: isReserved
                              ? null
                              : () {
                                  setState(() {
                                    selectedTime = time;
                                  });
                                },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isReserved
                                  ? Colors.grey[300]
                                  : isSelected
                                  ? Colors.orange
                                  : Colors.white,
                              border: Border.all(
                                color: isReserved
                                    ? Colors.grey[400]!
                                    : isSelected
                                    ? Colors.orange
                                    : Colors.grey[300]!,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  time,
                                  style: TextStyle(
                                    color: isReserved
                                        ? Colors.grey[600]
                                        : isSelected
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                                if (isReserved) Text('예약완료', style: TextStyle(fontSize: 10, color: Colors.red[300])),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ),
          SizedBox(height: 24),

          // 인원 수
          _buildSection(
            title: '인원 수',
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    if (quantity > 1) {
                      setState(() {
                        quantity--;
                      });
                    }
                  },
                  icon: Icon(Icons.remove),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text('$quantity'),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      quantity++;
                    });
                  },
                  icon: Icon(Icons.add),
                ),
              ],
            ),
          ),
          SizedBox(height: 24),

          // 총 금액
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('총 $quantity개', style: TextStyle(fontSize: 16)),
                Text(
                  '총금액 ${_formatPrice((int.tryParse(productPrice) ?? 0) * quantity)}원',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange),
                ),
              ],
            ),
          ),
          SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 12),
        child,
      ],
    );
  }

  bool _isFormValid() {
    return selectedDate != null && selectedTime != null;
  }

  Widget? _buildBottomNavigationBar() {
    // 로그인하지 않았거나 로딩 중이면 bottomNavigationBar 표시 안 함
    if (!_isLoggedIn || _isLoading) return null;

    final productPrice = _bookingDetail?.productPrice ?? widget.booking.productPrice;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: _isFormValid() ? () => _showPaymentDialog(context) : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            disabledBackgroundColor: Colors.grey[300],
          ),
          child: Text('빠른 예약', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  void _showPaymentDialog(BuildContext context) {
    final productName = _bookingDetail?.productName ?? widget.booking.productName;
    final productPrice = _bookingDetail?.productPrice ?? widget.booking.productPrice;
    final storeName = _bookingDetail?.storeName ?? widget.booking.storeName;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('결제 확인'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('입점사: $storeName'),
            Text('상품: $productName'),
            Text(
              '날짜: ${selectedDate!.year}.${selectedDate!.month.toString().padLeft(2, '0')}.${selectedDate!.day.toString().padLeft(2, '0')}',
            ),
            Text('시간: $selectedTime'),
            Text('인원: $quantity명'),
            SizedBox(height: 16),
            Text(
              '총 결제금액: ${_formatPrice((int.tryParse(productPrice) ?? 0) * quantity)}원',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('취소')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // _submitBooking();
            },
            child: Text('결제하기'),
          ),
        ],
      ),
    );
  }

  void _showCompletionDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('예약이 완료되었습니다'),
        content: Text('예약 확정 시 알림 메시지를 보내드립니다.'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text('확인'),
          ),
        ],
      ),
    );
  }
}
