import 'package:flutter/material.dart';
import 'package:sajunara_app/models/store.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime? selectedDate;
  String? selectedTime;
  String? selectedService;
  int quantity = 1;

  final List<String> timeSlots = [
    '10:00',
    '11:00',
    '12:00',
    '13:00',
    '14:00',
    '15:00',
    '16:00',
    '17:00',
    '18:00',
  ];

  @override
  Widget build(BuildContext context) {
    final Store store = ModalRoute.of(context)?.settings.arguments as Store;

    return Scaffold(
      appBar: AppBar(
        title: Text('예약하기'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 입점사 정보
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
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
                          store.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          store.location,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 16),
                            Text('${store.rating}'),
                            SizedBox(width: 8),
                            Text('${store.reviewCount}'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // 상품 선택
            _buildSection(
              title: '상품 선택 *',
              child: Column(
                children: store.services.map((service) {
                  return RadioListTile<String>(
                    title: Text(service),
                    subtitle: Text(
                      '${store.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원',
                    ),
                    value: service,
                    groupValue: selectedService,
                    onChanged: (value) {
                      setState(() {
                        selectedService = value;
                      });
                    },
                  );
                }).toList(),
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
                        style: TextStyle(
                          color: selectedDate != null
                              ? Colors.black
                              : Colors.grey,
                        ),
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
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: timeSlots.map((time) {
                  final isSelected = selectedTime == time;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedTime = time;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.orange : Colors.white,
                        border: Border.all(
                          color: isSelected ? Colors.orange : Colors.grey[300]!,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        time,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
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
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('총 1개', style: TextStyle(fontSize: 16)),
                  Text(
                    '총금액 ${(store.price * quantity).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: _isFormValid()
              ? () {
                  _showPaymentDialog(context, store);
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: _isFormValid() ? Colors.orange : Colors.grey,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            '${(store.price * quantity).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원 결제하기',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12),
        child,
      ],
    );
  }

  bool _isFormValid() {
    return selectedService != null &&
        selectedDate != null &&
        selectedTime != null;
  }

  void _showPaymentDialog(BuildContext context, Store store) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('결제 확인'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('입점사: ${store.name}'),
            Text('서비스: $selectedService'),
            Text(
              '날짜: ${selectedDate!.year}.${selectedDate!.month.toString().padLeft(2, '0')}.${selectedDate!.day.toString().padLeft(2, '0')}',
            ),
            Text('시간: $selectedTime'),
            Text('인원: $quantity명'),
            SizedBox(height: 16),
            Text(
              '총 결제금액: ${(store.price * quantity).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showCompletionDialog(context);
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
