import 'package:flutter/material.dart';
import 'package:sajunara_app/models/store.dart';
import 'package:sajunara_app/services/api/store_api.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async';

class StoreListScreen extends StatefulWidget {
  final String categoryType;
  const StoreListScreen({super.key, required this.categoryType});

  @override
  State<StoreListScreen> createState() => _StoreListScreenState();
}

class _StoreListScreenState extends State<StoreListScreen> {
  final StoreApi _storeApi = StoreApi();
  final String baseUrl = 'https://amita86tg.duckdns.org';

  List<dynamic> _storeList = []; // ← Map에서 List로 변경
  List<String> _bannerImages = []; // ← 배너 이미지 분리
  bool _isLoading = true;
  String? _errorMessage;

  final PageController _pageController = PageController();
  Timer? _autoSlideTimer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _loadStoreList();
  }

  Future<void> _loadStoreList() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _storeApi.fetchStoreListData(requestBody: {'categoryType': widget.categoryType});

      setState(() {
        // 입점사 리스트 추출
        _storeList = (data['storeListDto'] as List<dynamic>?) ?? [];

        // 배너 이미지 추출
        _bannerImages = [];
        if (data['subBannerDto'] != null) {
          final subBannerDto = data['subBannerDto'] as List?;
          if (subBannerDto != null) {
            for (var banner in subBannerDto) {
              final imagePath = banner['imagePath']?.toString();
              if (imagePath != null && imagePath.isNotEmpty) {
                _bannerImages.add(imagePath);
              }
            }
          }
        }

        _isLoading = false;
      });

      // 데이터 로드 후 자동 슬라이드 시작
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startAutoSlide();
      });
    } catch (e) {
      print('❌ 입점사 검색 에러: $e');
      setState(() {
        _storeList = [];
        _bannerImages = [];
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('검색 중 오류가 발생했습니다'), backgroundColor: Colors.red, duration: Duration(seconds: 2)),
        );
      }
    }
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoSlide() {
    if (_bannerImages.length <= 1) return;

    _autoSlideTimer?.cancel();
    _autoSlideTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        _currentPage = (_currentPage + 1) % _bannerImages.length;
        _pageController.animateToPage(_currentPage, duration: Duration(milliseconds: 350), curve: Curves.easeInOut);
      }
    });
  }

  String? _getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return null;
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

    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit ?? BoxFit.cover,
      placeholder: (context, url) => Container(
        width: width,
        height: height,
        color: Colors.grey[200],
        child: Center(child: CircularProgressIndicator()),
      ),
      errorWidget: (context, url, error) {
        return Container(
          width: width,
          height: height,
          color: Colors.grey[200],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: width != null ? width / 3 : 60, color: Colors.red[300]),
              SizedBox(height: 8),
              Text('이미지 로드 실패', style: TextStyle(fontSize: 12, color: Colors.red[300])),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageSlider() {
    if (_bannerImages.isEmpty) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          color: Colors.grey[200],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.store, size: 80, color: Colors.grey[400]),
              SizedBox(height: 8),
              Text('배너 이미지 없음', style: TextStyle(color: Colors.grey[500])),
            ],
          ),
        ),
      );
    }

    if (_bannerImages.length == 1) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: _buildImage(_bannerImages[0], fit: BoxFit.cover),
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
            itemCount: _bannerImages.length,
            itemBuilder: (context, index) {
              return _buildImage(_bannerImages[index], fit: BoxFit.cover);
            },
          ),
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _bannerImages.length,
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
                '${_currentPage + 1} / ${_bannerImages.length}',
                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getTitle() {
    switch (widget.categoryType) {
      case '0':
        return '신점';
      case '1':
        return '철학관';
      case '2':
        return '타로';
      default:
        return '매장 목록';
    }
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
              ElevatedButton(onPressed: _loadStoreList, child: Text('다시 시도')),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: Row(
          children: [
            Icon(Icons.store, size: 24),
            SizedBox(width: 8),
            Text(_getTitle(), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // 정렬 기능 구현
            },
            child: Text('정렬', style: TextStyle(color: Colors.blue, fontSize: 16)),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildImageSlider(),
          SizedBox(height: 16),
          Expanded(
            child: _storeList.isEmpty
                ? Center(
                    child: Text('매장 정보가 없습니다', style: TextStyle(color: Colors.grey, fontSize: 16)),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _storeList.length,
                    itemBuilder: (context, index) {
                      final store = _storeList[index] as Map<String, dynamic>;
                      return _buildStoreCard(store);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreCard(Map<String, dynamic> store) {
    final name = store['storeName'] ?? '업소명';
    final rating = double.parse(store['grade'].toString()).toStringAsFixed(1);
    final reviewCount = store['reviewCount']?.toString() ?? '0.0';
    final address = store['address'] ?? '주소';
    final categoryName = store['categoryName'] ?? '카테고리';
    final imagePath = store['imagePath'];

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _buildImage(imagePath, width: 100, height: 100, fit: BoxFit.cover),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(4)),
                      child: Text(categoryName, style: TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                    SizedBox(width: 4),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(4)),
                      child: Text('상담', style: TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                  ],
                ),
                SizedBox(height: 6),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.star, color: Colors.amber, size: 16),
                    Text(rating, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    SizedBox(width: 4),
                    Icon(Icons.message, color: Colors.grey, size: 14),
                    Text(reviewCount, style: TextStyle(fontSize: 13, color: Colors.grey)),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  address,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 6),
              ],
            ),
          ),
          SizedBox(width: 8),
          SizedBox(
            width: 70,
            height: 100,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/store_detail', arguments: Store.fromJson(store));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: EdgeInsets.zero,
              ),
              child: Text(
                '예약\n신청',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
