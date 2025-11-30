import 'package:flutter/material.dart';
import 'package:sajunara_app/models/booking.dart';
import 'package:sajunara_app/models/store.dart';
import 'package:sajunara_app/services/api/store_api.dart';
import 'package:flutter_html/flutter_html.dart';
import 'dart:async';

class StoreDetailScreen extends StatefulWidget {
  final Store store;
  const StoreDetailScreen({super.key, required this.store});

  @override
  State<StoreDetailScreen> createState() => _StoreDetailScreenState();
}

class _StoreDetailScreenState extends State<StoreDetailScreen> {
  final StoreApi _storeApi = StoreApi();
  final String baseUrl = 'https://amita86tg.duckdns.org';

  Map<String, dynamic> _storeDetail = {};
  bool _isLoading = true;
  String? _errorMessage;

  final PageController _pageController = PageController();
  Timer? _autoSlideTimer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _loadStoreDetail();
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadStoreDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _storeApi.fetctStoreDetailData(requestBody: widget.store.toJson());

      setState(() {
        _storeDetail = data;
        _isLoading = false;
      });

      _startAutoSlide();
    } catch (e) {
      setState(() {
        _errorMessage = '데이터를 불러오는데 실패했습니다: $e';
        _isLoading = false;
      });
    }
  }

  void _startAutoSlide() {
    final images = _getImages();
    if (images.length <= 1) return;

    _autoSlideTimer?.cancel();
    _autoSlideTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        _currentPage = (_currentPage + 1) % images.length;
        _pageController.animateToPage(_currentPage, duration: Duration(milliseconds: 350), curve: Curves.easeInOut);
      }
    });
  }

  List<String> _getImages() {
    if (_storeDetail['imageDto'] != null) {
      final imageDto = _storeDetail['imageDto'] as List;
      return imageDto.map((img) => img['imagePath']?.toString() ?? '').where((path) => path.isNotEmpty).toList();
    }
    return [];
  }

  String? _getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return null;
    if (imagePath.startsWith('http')) return imagePath;
    if (!imagePath.startsWith('/')) imagePath = '/$imagePath';
    return '$baseUrl$imagePath';
  }

  Widget _buildImage(String? imagePath, {double? width, double? height, BoxFit? fit}) {
    final imageUrl = _getImageUrl(imagePath);

    if (imageUrl == null) {
      return Container(
        width: width,
        height: height,
        color: Colors.grey[200],
        child: Icon(Icons.store, size: width != null ? width / 2 : 80, color: Colors.grey[400]),
      );
    }

    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit ?? BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          width: width,
          height: height,
          color: Colors.grey[200],
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width,
          height: height,
          color: Colors.grey[200],
          child: Icon(Icons.store, size: width != null ? width / 2 : 80, color: Colors.grey[400]),
        );
      },
    );
  }

  Widget _buildImageSlider() {
    final images = _getImages();

    if (images.isEmpty) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          color: Colors.grey[200],
          child: Icon(Icons.store, size: 80, color: Colors.grey[400]),
        ),
      );
    }

    if (images.length == 1) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: _buildImage(images[0], fit: BoxFit.cover),
      );
    }

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: images.length,
            itemBuilder: (context, index) {
              return _buildImage(images[index], fit: BoxFit.cover);
            },
          ),
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                images.length,
                (index) => Container(
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index ? Colors.white : Colors.white.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(20)),
              child: Text(
                '${_currentPage + 1} / ${images.length}',
                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(_errorMessage!),
              SizedBox(height: 16),
              ElevatedButton(onPressed: _loadStoreDetail, child: Text('다시 시도')),
            ],
          ),
        ),
      );
    }
    final storeName = _storeDetail['storeName'] ?? widget.store.storeName;
    final description = _storeDetail['description'] ?? widget.store.description;
    final categoryName = _storeDetail['categoryName'] ?? widget.store.categoryName;
    final address = _storeDetail['address'] ?? widget.store.address;
    final operatingHours = _storeDetail['operatingHours'] ?? widget.store.operatingHours;
    final reviewCount = _storeDetail['reviewCount'] ?? widget.store.reviewCount;
    final rating = double.tryParse(_storeDetail['grade'] ?? '0');
    final memo = _storeDetail['memo'] ?? '안녕하세요. $storeName입니다.\n정확한 상담을 위해 예약 시간을 꼭 지켜주세요.';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(background: _buildImageSlider()),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(categoryName),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(categoryName, style: TextStyle(color: Colors.white, fontSize: 12)),
                      ),
                      SizedBox(height: 8),
                      Text(storeName, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text(description, style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber),
                          Text('$rating'),
                          SizedBox(width: 16),
                          Icon(Icons.chat_bubble_outline),
                          Text(reviewCount.toString()),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.grey),
                          Expanded(child: Text(address)),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.access_time, color: Colors.grey),
                          Text(operatingHours),
                        ],
                      ),
                      SizedBox(height: 16),
                      if (_storeDetail['services'] != null)
                        Wrap(
                          spacing: 8,
                          children: (_storeDetail['services'] as List)
                              .map(
                                (service) => Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(service.toString()),
                                ),
                              )
                              .toList(),
                        )
                      else
                        Wrap(
                          spacing: 8,
                          children: widget.store.services
                              .map(
                                (service) => Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(service),
                                ),
                              )
                              .toList(),
                        ),
                    ],
                  ),
                ),

                Divider(),

                // ✅ 공지사항 - HTML 파싱 적용
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('공지사항', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Html(
                        data: memo,
                        style: {
                          "body": Style(
                            margin: Margins.zero,
                            padding: HtmlPaddings.zero,
                            fontSize: FontSize(14),
                            color: Colors.grey[600],
                          ),
                          "p": Style(margin: Margins.zero, padding: HtmlPaddings.zero),
                        },
                      ),
                    ],
                  ),
                ),

                Divider(),

                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('예약 상품', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 16),
                      ...(_storeDetail['productDto'] as List?)?.map((product) => _buildServiceItem(context, product)) ??
                          widget.store.services.map((service) => _buildServiceItem(context, {'name': service})),
                    ],
                  ),
                ),

                Divider(),

                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('후기', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 16),
                      ...(_storeDetail['reviewDto'] as List?)?.map((review) => _buildReviewItem(context, review)) ??
                          List.generate(3, (index) => _buildReviewItem(context, {})),
                    ],
                  ),
                ),

                SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceItem(BuildContext context, dynamic service) {
    final serviceName = service['name'] ?? '서비스';
    final servicePrice = service['price'] ?? 0;

    final Booking booking = Booking();
    return GestureDetector(
      onTap: () {
        final booking = Booking(
          seq: widget.store.seq.toString(),
          serviceSeq: service['seq'],
          storeName: widget.store.storeName, // UI 표시용
          productName: serviceName, // UI 표시용
          productPrice: servicePrice.toString(), // UI 표시용
          categoryName: widget.store.categoryName,
          address: widget.store.address,
          // ... 나머지 필드들
        );

        Navigator.pushNamed(context, '/booking', arguments: booking);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(serviceName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(height: 4),
                  Text(
                    '${servicePrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원',
                    style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewItem(BuildContext context, dynamic review) {
    final userName = review['userNickname'] ?? '홍길동';
    final storeName = review['storeName'] ?? '';
    final content = review['content'] ?? '';
    final createdAt = review['createdAt'] ?? '';
    final reply = review['reply'];
    final imagePath = review['imagePath'] ?? '';
    final profileImage = review['profileImage'] ?? '';
    final gradeStr = review['grade']?.toString() ?? '5';
    final rating = int.tryParse(gradeStr) ?? 5;
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: profileImage != null && profileImage.isNotEmpty ? NetworkImage(profileImage) : null,
                backgroundColor: Colors.grey[300],
                // child: profileImage == null || profileImage.isEmpty
                //     ? Text(
                //         userName.isNotEmpty ? userName[0].toUpperCase() : '홍',
                //         style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                //       )
                //     : null,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$userName 님', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(createdAt, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  ],
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < (rating is int ? rating : (rating is double ? rating.toInt() : 5))
                        ? Icons.star
                        : Icons.star_border,
                    color: Colors.amber,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(content, style: TextStyle(color: Colors.grey[700])),

          // ✅ 리뷰 이미지 - imagePath가 있으면 표시
          if (imagePath != null && imagePath.toString().isNotEmpty) ...[
            SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _buildImage(imagePath, width: double.infinity, height: 200),
            ),
          ],

          // ✅ 입점사 답변
          if (reply != null && reply.toString().isNotEmpty) ...[
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end, // ← 오른쪽 정렬
              children: [
                Container(
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85), // ← 최대 너비 85%
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(4)),
                        child: Text(storeName, style: TextStyle(color: Colors.white, fontSize: 12)),
                      ),
                      SizedBox(height: 8),
                      Text(reply.toString(), style: TextStyle(color: Colors.grey[700])),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case '신점':
        return Colors.blue;
      case '타로':
        return Colors.green;
      case '철학관':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
