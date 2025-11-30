import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:sajunara_app/screens/event/event_detail_screen.dart';
import 'package:sajunara_app/services/api/event_api.dart';

class EventScreen extends StatefulWidget {
  const EventScreen({super.key});

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  final String baseUrl = 'https://amita86tg.duckdns.org';
  final EventApi _eventApi = EventApi();

  List<dynamic> eventList = []; // ← Map에서 List로 변경!
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    try {
      final data = await _eventApi.fetchEventList(requestBody: {});

      setState(() {
        eventList = (data['eventListDto'] as List<dynamic>?) ?? [];
        _isLoading = false;
      });

      print('✅ 이벤트 개수: ${eventList.length}');
    } catch (e) {
      print('❌ 이벤트 로드 에러: $e');
      setState(() {
        eventList = [];
        _isLoading = false;
      });
    }
  }

  String? _getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return null;
    if (imagePath.startsWith('http')) return imagePath;
    if (!imagePath.startsWith('/')) imagePath = '/$imagePath';
    return '$baseUrl$imagePath';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('이벤트', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : eventList.isEmpty
          ? Center(
              child: Text('등록된 이벤트가 없습니다', style: TextStyle(fontSize: 16, color: Colors.grey)),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: eventList.length,
              itemBuilder: (context, index) {
                final event = eventList[index];
                if (event == null) return SizedBox.shrink();
                return _buildEventCard(context, event);
              },
            ),
    );
  }

  Widget _buildEventCard(BuildContext context, dynamic event) {
    final isActive = (event['status']?.toString() ?? '') == 'active';

    return GestureDetector(
      onTap: isActive
          ? () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => EventDetailScreen(event: event)));
            }
          : null,
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isActive ? Colors.red : Colors.grey[700],
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Row(
                children: [
                  Icon(Icons.circle, color: Colors.white, size: 8),
                  SizedBox(width: 8),
                  Text(
                    isActive ? '진행 중 이벤트' : '종료 이벤트',
                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Stack(
              children: [
                ClipRRect(borderRadius: BorderRadius.zero, child: _buildEventImage(event['imagePath'], isActive)),
                if (!isActive)
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.zero,
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                        child: Container(
                          color: Colors.black.withOpacity(0.3),
                          child: Center(
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '종료된 이벤트',
                                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event['eventName']?.toString() ?? '이벤트',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isActive ? Colors.black : Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '이벤트 기간 : ${event['eventDate']?.toString() ?? '-'}',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 8),
                  if (isActive) ...[
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => EventDetailScreen(event: event)),
                            );
                          },
                          icon: Icon(Icons.arrow_forward, size: 16),
                          label: Text('자세히 보기'),
                          style: TextButton.styleFrom(foregroundColor: Colors.blue),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventImage(String? imagePath, bool isActive) {
    final imageUrl = _getImageUrl(imagePath);

    return Container(
      width: double.infinity,
      height: 200,
      color: Colors.grey[200],
      child: imageUrl != null
          ? Image.network(
              imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(child: CircularProgressIndicator());
              },
              errorBuilder: (context, error, stackTrace) {
                return Center(child: Icon(Icons.event, size: 60, color: Colors.grey[400]));
              },
            )
          : Center(child: Icon(Icons.event, size: 60, color: Colors.grey[400])),
    );
  }
}
