import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:sajunara_app/services/api/event_api.dart';

class EventDetailScreen extends StatefulWidget {
  final dynamic event;

  const EventDetailScreen({super.key, required this.event});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  final String baseUrl = 'https://amita86tg.duckdns.org';
  final EventApi _eventApi = EventApi();

  Map<String, dynamic>? eventDetail;
  bool _isLoading = true;
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _loadEventDetail();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadEventDetail() async {
    try {
      final detail = await _eventApi.fetchEventDetail(eventDto: widget.event);

      setState(() {
        eventDetail = detail;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ 상세 정보 로드 에러: $e');
      setState(() {
        eventDetail = widget.event;
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

  List<String> _getImageUrls() {
    if (eventDetail == null) return [];

    if (eventDetail!['imageListDto'] != null && eventDetail!['imageListDto'] is List) {
      List<dynamic> imageList = eventDetail!['imageListDto'];

      return imageList
          .map((item) {
            if (item is Map<String, dynamic> && item['imagePath'] != null) {
              return _getImageUrl(item['imagePath']);
            } else if (item is String) {
              return _getImageUrl(item);
            }
            return null;
          })
          .where((url) => url != null)
          .cast<String>()
          .toList();
    }

    if (eventDetail!['imagePath'] != null) {
      final url = _getImageUrl(eventDetail!['imagePath']);
      return url != null ? [url] : [];
    }

    return [];
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('이벤트 상세'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (eventDetail == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('이벤트 상세'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        body: Center(
          child: Text('이벤트 정보를 불러올 수 없습니다', style: TextStyle(fontSize: 16, color: Colors.grey)),
        ),
      );
    }

    final imageUrls = _getImageUrls();

    return Scaffold(
      appBar: AppBar(title: Text('이벤트 상세'), backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ 이미지 슬라이더 + 인디케이터
            if (imageUrls.isNotEmpty)
              Column(
                children: [
                  // 큰 이미지 영역 + 인디케이터
                  Stack(
                    children: [
                      SizedBox(
                        height: 300,
                        child: PageView.builder(
                          controller: _pageController,
                          onPageChanged: (index) {
                            setState(() {
                              _currentImageIndex = index;
                            });
                          },
                          itemCount: imageUrls.length,
                          itemBuilder: (context, index) {
                            return Container(
                              width: double.infinity,
                              color: Colors.grey[200],
                              child: Image.network(
                                imageUrls[index],
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(child: CircularProgressIndicator());
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(child: Icon(Icons.event, size: 80, color: Colors.grey[400]));
                                },
                              ),
                            );
                          },
                        ),
                      ),

                      // ✅ 인디케이터 (하단 중앙)
                      if (imageUrls.length > 1)
                        Positioned(
                          bottom: 16,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(
                                imageUrls.length,
                                (index) => Container(
                                  width: 8,
                                  height: 8,
                                  margin: EdgeInsets.symmetric(horizontal: 4),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _currentImageIndex == index ? Colors.white : Colors.white.withOpacity(0.5),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              )
            else
              // 이미지가 없을 때
              Container(
                width: double.infinity,
                height: 300,
                color: Colors.grey[200],
                child: Center(child: Icon(Icons.event, size: 80, color: Colors.grey[400])),
              ),

            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 제목
                  Text(eventDetail!['eventName'] ?? '', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 12),

                  // 기간
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                        SizedBox(width: 8),
                        Text(
                          '${eventDetail!['eventDate'] ?? ''}',
                          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24),
                  Divider(),
                  SizedBox(height: 24),

                  // 내용 (HTML 파싱)
                  Html(
                    data: eventDetail!['content'] ?? '',
                    style: {
                      "body": Style(
                        fontSize: FontSize(16),
                        lineHeight: LineHeight(1.6),
                        color: Colors.grey[800],
                        margin: Margins.zero,
                        padding: HtmlPaddings.zero,
                      ),
                      "p": Style(margin: Margins.only(bottom: 16)),
                      "h1": Style(
                        fontSize: FontSize(22),
                        fontWeight: FontWeight.bold,
                        margin: Margins.only(top: 16, bottom: 12),
                      ),
                      "h2": Style(
                        fontSize: FontSize(20),
                        fontWeight: FontWeight.bold,
                        margin: Margins.only(top: 16, bottom: 12),
                      ),
                      "h3": Style(
                        fontSize: FontSize(18),
                        fontWeight: FontWeight.bold,
                        margin: Margins.only(top: 16, bottom: 12),
                      ),
                      "ul": Style(margin: Margins.only(left: 16, bottom: 12)),
                      "ol": Style(margin: Margins.only(left: 16, bottom: 12)),
                      "li": Style(margin: Margins.only(bottom: 8)),
                      "img": Style(width: Width(double.infinity), margin: Margins.symmetric(vertical: 12)),
                      "a": Style(color: Colors.blue, textDecoration: TextDecoration.underline),
                    },
                  ),

                  SizedBox(height: 40),

                  // 공유 버튼들
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // _buildActionButton(
                      //   icon: Icons.share,
                      //   label: '공유',
                      //   onPressed: () {
                      //     // TODO: 공유 기능
                      //   },
                      // ),
                      _buildActionButton(
                        icon: Icons.list, // ✅ 아이콘 변경
                        label: '목록',
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      _buildActionButton(
                        icon: Icons.next_plan,
                        label: '다음',
                        onPressed: () {
                          // TODO: 다운로드 기능
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required String label, required VoidCallback onPressed}) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(color: Colors.grey[200], shape: BoxShape.circle),
          child: IconButton(icon: Icon(icon), onPressed: onPressed, iconSize: 28),
        ),
        SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
      ],
    );
  }
}
