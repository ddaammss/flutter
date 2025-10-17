import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';
import 'package:sajunara_app/models/review.dart';
import 'package:sajunara_app/models/store.dart';
import '../../providers/app_state.dart';
import '../../providers/store_state.dart';
import '../search/search_delegate.dart';
import '../../widgets/store_card.dart';
import '../../widgets/review_card.dart';
import '../../widgets/product_card.dart';
import '../../utils/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sajunara_app/services/api/main_api.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 배너 슬라이드 관련
  int _currentBannerIndex = 0;
  final PageController _bannerController = PageController();

  // 인기 급상승 슬라이드
  int _currentPopularIndex = 0;
  final PageController _popularRankingController = PageController(viewportFraction: 0.85);

  // 전체 순위 슬라이드
  final PageController _allStoresController = PageController(viewportFraction: 0.85);

  // 내 위치 추천 슬라이드
  final PageController _locationController = PageController(viewportFraction: 0.85);

  // 추천 상품 슬라이드
  int _currentProductIndex = 0;
  final PageController _productController = PageController(viewportFraction: 0.4);

  // 베스트 리뷰 슬라이드
  int _currentReviewIndex = 0;
  final PageController _reviewController = PageController(viewportFraction: 0.85);

  // 위치 정보 관련
  Position? _currentPosition;
  bool _isLoadingLocation = true;
  String _locationText = '위치를 불러오는 중...';

  // ✅ MainApi 인스턴스 추가
  final MainApi _mainApi = MainApi();

  // ✅ API 데이터를 저장할 변수 추가
  Map<String, dynamic> _mainData = {};
  bool _isLoadingMainData = false;
  Timer? _popularAutoSlideTimer;

  @override
  void initState() {
    super.initState();
    _initializeData();
    //_startPopularRankingAutoSlide();
  }

  Future<void> _initializeData() async {
    await _checkAndLoadLocation();
    await _loadMainData();
  }

  Future<void> _loadMainData() async {
    setState(() {
      _isLoadingMainData = true;
    });

    try {
      final data = await _mainApi.fetMainData(
        requestBody: {
          'latitude': _currentPosition?.latitude.toString() ?? '',
          'longitude': _currentPosition?.longitude.toString() ?? '',
          'distance': 5,
        },
      );
      setState(() {
        _mainData = data;
        _isLoadingMainData = false;
      });
      _startPopularRankingAutoSlide();
      // print('✅ 메인 데이터 로드 성공');
      // print('📦 전체 상점: ${(_mainData['allStoreDto'] as List?)?.length ?? 0}개');
      // print('📍 주변 상점: ${(_mainData['nearStoreDto'] as List?)?.length ?? 0}개');
      // print('🛍️  상품: ${(_mainData['productDto'] as List?)?.length ?? 0}개');
      // print('⭐ 리뷰: ${(_mainData['reviewDto'] as List?)?.length ?? 0}개');
      // print('⭐ 이용약관: ${_mainData['termDto'] != null ? '있음' : '없음'}');
      // print('⭐ 이용약관: ${_mainData['privacyDto'] != null ? '있음' : '없음'}');
      // print('⭐ 메인배너1: ${(_mainData['mainBannerDto'] as List?)?.length ?? 0}개');
      // print('⭐ 메인배너2: ${(_mainData['mainBanner2Dto'] as List?)?.length ?? 0}개');
      // print('⭐ 인기순위: ${(_mainData['popularStoreDto'] as List?)?.length ?? 0}개');
    } catch (e) {
      print('❌ 메인 데이터 로드 실패: $e');
      setState(() {
        _isLoadingMainData = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('데이터를 불러오는데 실패했습니다: $e')));
      }
    }
  }

  @override
  void dispose() {
    _bannerController.dispose();
    _popularRankingController.dispose();
    _allStoresController.dispose();
    _locationController.dispose();
    _productController.dispose();
    _reviewController.dispose();
    _popularAutoSlideTimer?.cancel();
    super.dispose();
  }

  // ✅ 권한 체크 후 위치 가져오기
  Future<void> _checkAndLoadLocation() async {
    final prefs = await SharedPreferences.getInstance();
    bool hasLocationPermission = prefs.getBool('has_asked_location') ?? false;

    LocationPermission permission = await Geolocator.checkPermission();

    if (hasLocationPermission &&
        (permission == LocationPermission.whileInUse || permission == LocationPermission.always)) {
      await _getCurrentLocation(); // ✅ await 추가 (기다림!)
    } else {
      setState(() {
        _locationText = '위치 권한을 허용해주세요';
        _isLoadingLocation = false;
      });
    }
  }

  // 위치 가져오기 with Geocoding
  Future<void> _getCurrentLocation() async {
    try {
      // 권한 확인만 (요청 안 함!)
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        setState(() {
          _locationText = '위치 권한을 허용해주세요';
          _isLoadingLocation = false;
        });
        return;
      }

      // 현재 위치 가져오기
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      // 역지오코딩: 위경도 -> 주소
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        String locality = place.locality ?? '';
        String subLocality = place.subLocality ?? '';
        String administrativeArea = place.administrativeArea ?? '';

        String locationText;
        if (locality.isNotEmpty && subLocality.isNotEmpty) {
          locationText = '$locality > $subLocality';
        } else if (administrativeArea.isNotEmpty && subLocality.isNotEmpty) {
          locationText = '$administrativeArea > $subLocality';
        } else if (locality.isNotEmpty) {
          locationText = locality;
        } else if (administrativeArea.isNotEmpty) {
          locationText = administrativeArea;
        } else {
          locationText = '위치 확인 완료';
        }

        setState(() {
          _currentPosition = position;
          _locationText = locationText;
          _isLoadingLocation = false;
        });

        print('현재 위치: ${position.latitude}, ${position.longitude}');
        print('주소: $locationText');
      }
    } catch (e) {
      setState(() {
        _locationText = '위치를 가져올 수 없습니다';
        _isLoadingLocation = false;
      });
    }
  }

  // 배너 자동 슬라이드
  // void _startBannerAutoSlide() {
  //   Future.delayed(Duration(seconds: 3), () {
  //     if (mounted && _bannerController.hasClients) {
  //       int nextPage = (_currentBannerIndex + 1) % 3;
  //       _bannerController.animateToPage(nextPage, duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
  //       _startBannerAutoSlide();
  //     }
  //   });
  // }

  // 추천 상품 자동 슬라이드
  // void _startProductAutoSlide() {
  //   Future.delayed(Duration(seconds: 4), () {
  //     if (mounted && _productController.hasClients) {
  //       int nextPage = (_currentProductIndex + 1) % 5;
  //       _productController.animateToPage(nextPage, duration: Duration(milliseconds: 400), curve: Curves.easeInOut);
  //       _startProductAutoSlide();
  //     }
  //   });
  // }

  // 베스트 리뷰 자동 슬라이드
  // void _startReviewAutoSlide() {
  //   Future.delayed(Duration(seconds: 5), () {
  //     if (mounted && _reviewController.hasClients) {
  //       int nextPage = (_currentReviewIndex + 1) % 5;
  //       _reviewController.animateToPage(nextPage, duration: Duration(milliseconds: 400), curve: Curves.easeInOut);
  //       _startReviewAutoSlide();
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          '무물',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.event, color: Colors.black),
            onPressed: () {
              _showEventDialog(context);
            },
          ),
          IconButton(
            icon: Icon(Icons.search, color: Colors.black),
            onPressed: () {
              showSearch(context: context, delegate: StoreSearchDelegate());
            },
          ),
          IconButton(
            icon: Icon(Icons.person_add, color: Colors.black),
            onPressed: () {
              Navigator.pushNamed(context, '/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMainBanner(context),
            _buildPopularRankingSection(context),
            _buildAllRankingSection(context),
            _buildCategorySection(context),
            _buildLocationRecommendationSection(context),
            _buildProductRecommendationSection(context),
            _buildBestReviewSection(context),
            _buildFooterSection(context),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // 메인 배너 (슬라이드)
  Widget _buildMainBanner(BuildContext context) {
    List<dynamic> bannerList = _mainData['mainBannerDto'] ?? [];
    if (bannerList.isEmpty) {
      bannerList = [
        {'title': '운명을 만나는 특별한 순간', 'subtitle': '전문가들이 제공하는 정확한 상담', 'imagePath': null},
        {'title': '신규 회원 50% 할인', 'subtitle': '지금 바로 상담 받아보세요', 'imagePath': null},
        {'title': '베스트 리뷰 이벤트', 'subtitle': '리뷰 작성하고 포인트 받으세요', 'imagePath': null},
      ];
    }

    return Container(
      height: 200,
      margin: EdgeInsets.all(16),
      child: Stack(
        children: [
          PageView.builder(
            controller: _bannerController,
            onPageChanged: (index) {
              setState(() {
                _currentBannerIndex = index;
              });
            },
            itemCount: bannerList.length,
            itemBuilder: (context, index) {
              final banner = bannerList[index] as Map<String, dynamic>;
              final imagePath = banner['imagePath'] as String?;
              final title = banner['title'] ?? '제목 없음';
              final subtitle = banner['subtitle'] ?? '';
              return ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // ✅ 배경 이미지 (자동 리사이징)
                    if (imagePath != null && imagePath.isNotEmpty)
                      CachedNetworkImage(
                        imageUrl: Uri.encodeFull('https://amita86tg.duckdns.org$imagePath'),
                        fit: BoxFit.cover, // ✅ 핵심: 어떤 사이즈든 영역에 맞게 조정
                        width: double.infinity,
                        height: double.infinity,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[300],
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        errorWidget: (context, url, error) => Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [Colors.indigo[400]!, Colors.purple[400]!]),
                          ),
                        ),
                      ),
                    //else
                    // ✅ 이미지 없으면 그라데이션
                    // Container(
                    //   decoration: BoxDecoration(gradient: LinearGradient(colors: _getBannerGradientColors(index))),
                    // ),
                    // ✅ 반투명 오버레이
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.black.withOpacity(0.2), Colors.black.withOpacity(0.4)],
                        ),
                      ),
                    ),

                    // ✅ 텍스트
                    Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(color: Colors.black.withOpacity(0.7), offset: Offset(2, 2), blurRadius: 4),
                                ],
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (subtitle.isNotEmpty) ...[
                              SizedBox(height: 8),
                              Text(
                                subtitle,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  shadows: [
                                    Shadow(color: Colors.black.withOpacity(0.7), offset: Offset(1, 1), blurRadius: 3),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // 인디케이터
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                bannerList.length,
                (index) => Container(
                  width: 8,
                  height: 8,
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index == _currentBannerIndex ? Colors.white : Colors.white38,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 인기 급상승 순위 (슬라이드)
  Widget _buildPopularRankingSection(BuildContext context) {
    List<dynamic> popularList = _mainData['popularStoreDto'] ?? [];
    return _buildSection(
      context,
      title: '인기 급상승 순위',
      subtitle: '',
      showAll: true,
      onShowAll: () => _showAllRankingDialog(context, '인기 급상승'),
      child: Column(
        children: [
          // ✅ 입점사 카드 (세로 슬라이드)
          popularList.isEmpty
              ? Center(
                  child: Padding(padding: EdgeInsets.all(20), child: Text('인기 상점이 없습니다')),
                )
              : SizedBox(
                  height: 90,
                  child: PageView.builder(
                    controller: _popularRankingController,
                    scrollDirection: Axis.vertical,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPopularIndex = index;
                      });
                    },
                    itemCount: popularList.length,
                    itemBuilder: (context, index) {
                      final storeData = popularList[index] as Map<String, dynamic>;
                      final store = Store.fromJson(storeData); // ✅ JSON → Store 변환

                      return GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/store_detail', arguments: store);
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: Offset(0, 2)),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(25),
                                  child: Icon(Icons.store, size: 28, color: Colors.grey[600]),
                                ),
                              ),
                              SizedBox(width: 12),

                              // 중앙: 입점사명
                              Expanded(
                                child: Text(
                                  store.storeName,
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),

                              // 오른쪽: 인기 아이콘 (리뷰 개수)
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.orange[50],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.local_fire_department, color: Colors.orange[700], size: 20),
                                    SizedBox(width: 4),
                                    Text(
                                      '${store.reviewCount}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 8),

                              // // 리뷰 버튼
                              // Container(
                              //   width: 36,
                              //   height: 36,
                              //   decoration: BoxDecoration(
                              //     color: Colors.grey[100],
                              //     borderRadius: BorderRadius.circular(18),
                              //   ),
                              //   child: Icon(Icons.chat_bubble_outline, size: 18, color: Colors.grey[700]),
                              // ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

          SizedBox(height: 16),

          // ✅ 카테고리 버튼 4개
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildCategoryButton(
                  context,
                  '신점',
                  Colors.purple[400]!,
                  Icons.auto_awesome,
                  () => context.read<AppState>().setCurrentIndex(1),
                ),
                SizedBox(width: 8),
                _buildCategoryButton(
                  context,
                  '타로',
                  Colors.blue[400]!,
                  Icons.style,
                  () => context.read<AppState>().setCurrentIndex(2),
                ),
                SizedBox(width: 8),
                _buildCategoryButton(
                  context,
                  '철학관',
                  Colors.green[400]!,
                  Icons.account_balance,
                  () => context.read<AppState>().setCurrentIndex(3),
                ),
                SizedBox(width: 8),
                _buildCategoryButton(
                  context,
                  '쇼핑몰',
                  Colors.orange[400]!,
                  Icons.shopping_bag,
                  () => _showShoppingMallDialog(context),
                ),
              ],
            ),
          ),

          SizedBox(height: 8),
        ],
      ),
    );
  }

  void _startPopularRankingAutoSlide() {
    // 기존 타이머 취소
    _popularAutoSlideTimer?.cancel();

    _popularAutoSlideTimer = Timer.periodic(Duration(seconds: 2), (timer) {
      if (!mounted || !_popularRankingController.hasClients) {
        timer.cancel();
        return;
      }

      List<dynamic> popularList = _mainData['popularStoreDto'] ?? [];

      if (popularList.isEmpty) {
        return;
      }

      int nextPage = (_currentPopularIndex + 1) % popularList.length;

      _popularRankingController.animateToPage(nextPage, duration: Duration(milliseconds: 400), curve: Curves.easeInOut);
    });
  }

  // ✅ 카테고리 버튼
  Widget _buildCategoryButton(BuildContext context, String label, Color color, IconData icon, VoidCallback onTap) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withOpacity(0.3), width: 1),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 24),
                SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 전체 순위 (슬라이드)
  Widget _buildAllRankingSection(BuildContext context) {
    List<dynamic> allStores = _mainData['allStoreDto'] ?? [];

    return _buildSection(
      context,
      title: '전체 순위',
      subtitle: '',
      showAll: true,
      onShowAll: () => _showAllRankingDialog(context, '전체 순위'),
      child: allStores.isEmpty
          ? Center(child: Text('데이터를 조회중입니다...'))
          : SizedBox(
              height: 200,
              child: PageView.builder(
                controller: _allStoresController,
                itemCount: allStores.length,
                itemBuilder: (context, index) {
                  final store = allStores[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: StoreCard(
                      store: Store.fromJson(store), // JSON을 Store 객체로 변환
                    ),
                  );
                },
              ),
            ),
    );
  }

  Widget _buildCategoryRankingButton(BuildContext context, String category, Color color, IconData icon) {
    return GestureDetector(
      onTap: () {
        if (category == '쇼핑몰') {
          _showShoppingMallDialog(context);
        } else {
          _showCategoryRankingDialog(context, category);
        }
      },
      child: SizedBox(
        width: 70,
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            SizedBox(height: 8),
            Text(
              category,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: color),
            ),
            Text('전체 순위', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection(BuildContext context) {
    final categories = [];

    return Container(
      margin: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: categories.map((category) {
          return GestureDetector(
            onTap: () {
              if (category['name'] == '쇼핑몰') {
                _showShoppingMallDialog(context);
              } else {
                context.read<AppState>().setCurrentIndex(
                  category['name'] == '신점'
                      ? 1
                      : category['name'] == '타로'
                      ? 2
                      : 3,
                );
              }
            },
            child: Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: (category['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Icon(category['icon'] as IconData, color: category['color'] as Color, size: 30),
                ),
                SizedBox(height: 8),
                Text(category['name'] as String, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // 내 위치 추천 (슬라이드) - Geocoding 적용
  Widget _buildLocationRecommendationSection(BuildContext context) {
    List<dynamic> nearStore = _mainData['nearStoreDto'] ?? [];
    return _buildSection(
      context,
      title: '내 위치 추천',
      subtitle: _locationText,
      showAll: true,
      onShowAll: () => _showLocationRecommendationDialog(context),
      child: _isLoadingLocation
          ? Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('위치를 불러오는 중...', style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              ),
            )
          : Consumer<StoreState>(
              builder: (context, storeState, child) {
                return SizedBox(
                  height: 200,
                  child: PageView.builder(
                    controller: _locationController,
                    itemCount: nearStore.length,
                    itemBuilder: (context, index) {
                      final store = nearStore[index];
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: StoreCard(
                          store: Store.fromJson(store), // JSON을 Store 객체로 변환
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }

  // 추천 상품, 총알 배송 (슬라이드)
  Widget _buildProductRecommendationSection(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.orange[100]!, Colors.orange[50]!]),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.local_shipping, color: Colors.orange[700], size: 24),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '추천 상품, 총알 배송',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange[800]),
                      ),
                      Text('인기, 신규 소개', style: TextStyle(color: Colors.orange[600], fontSize: 14)),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _showShoppingMallDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: Text('전체보기'),
                ),
              ],
            ),
          ),
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              SizedBox(
                height: 180,
                child: PageView.builder(
                  controller: _productController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentProductIndex = index;
                    });
                  },
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: ProductCard(
                        name: _getProductName(index),
                        price: _getProductPrice(index),
                        originalPrice: _getOriginalPrice(index),
                        discount: _getDiscount(index),
                        isNew: index < 2,
                        isPopular: index % 2 == 0,
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                bottom: 8,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    5,
                    (index) => Container(
                      width: 6,
                      height: 6,
                      margin: EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index == _currentProductIndex ? Colors.orange : Colors.grey[400],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  // 베스트 리뷰 (슬라이드)
  Widget _buildBestReviewSection(BuildContext context) {
    List<dynamic> reviewList = _mainData['reviewDto'] ?? [];

    // ✅ 데이터가 없으면 기본 메시지
    if (reviewList.isEmpty) {
      return _buildSection(
        context,
        title: '베스트 리뷰',
        showAll: false,
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(40),
            child: Text('등록된 리뷰가 없습니다', style: TextStyle(color: Colors.grey[600])),
          ),
        ),
      );
    }

    return _buildSection(
      context,
      title: '베스트 리뷰',
      showAll: true,
      onShowAll: () => _showBestReviewDialog(context),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          SizedBox(
            height: 150,
            child: PageView.builder(
              controller: _reviewController,
              onPageChanged: (index) {
                setState(() {
                  _currentReviewIndex = index;
                });
              },
              itemCount: reviewList.length, // ✅ 실제 리뷰 개수
              itemBuilder: (context, index) {
                final reviewJson = reviewList[index] as Map<String, dynamic>;
                final review = Review.fromJson(reviewJson); // ✅ JSON → Review 변환

                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: ReviewCard(review: review), // ✅ review 객체 전달
                );
              },
            ),
          ),
          Positioned(
            bottom: 8,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                reviewList.length, // ✅ 실제 리뷰 개수
                (index) => Container(
                  width: 6,
                  height: 6,
                  margin: EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle, // ✅ 원형으로 수정
                    color: index == _currentReviewIndex ? Colors.blue : Colors.grey[400],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterSection(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () => _showTermsDialog(context),
                child: Text('이용약관', style: TextStyle(color: Colors.grey[600])),
              ),
              Text('|', style: TextStyle(color: Colors.grey[400])),
              TextButton(
                onPressed: () => _showPrivacyDialog(context),
                child: Text('개인정보 처리방침', style: TextStyle(color: Colors.grey[600])),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text('© 2025 사주나라. All rights reserved.', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    String? subtitle,
    required Widget child,
    bool showAll = false,
    VoidCallback? onShowAll,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  if (showAll) TextButton(onPressed: onShowAll, child: Text('전체보기')),
                ],
              ),
              if (subtitle != null) Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
            ],
          ),
        ),
        child,
      ],
    );
  }

  String _getProductName(int index) {
    final products = ['행운의 부적', '수험생 합격 부적', '연애운 타로카드', '재물운 수정구슬', '액막이 팔찌'];
    return products[index % products.length];
  }

  int _getProductPrice(int index) {
    final prices = [15000, 25000, 35000, 45000, 20000];
    return prices[index % prices.length];
  }

  int _getOriginalPrice(int index) {
    return (_getProductPrice(index) * 1.3).round();
  }

  int _getDiscount(int index) {
    final discounts = [20, 30, 15, 25, 35];
    return discounts[index % discounts.length];
  }

  void _showEventDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('진행중인 이벤트'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.card_giftcard, color: Colors.red),
              title: Text('신규 회원 할인 이벤트'),
              subtitle: Text('첫 상담 50% 할인'),
            ),
            ListTile(
              leading: Icon(Icons.star, color: Colors.green),
              title: Text('리뷰 작성 이벤트'),
              subtitle: Text('리뷰 작성시 포인트 적립'),
            ),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('확인'))],
      ),
    );
  }

  void _showAllRankingDialog(BuildContext context, String type) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(type),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: Consumer<StoreState>(
            builder: (context, storeState, child) {
              return ListView.builder(
                itemCount: storeState.stores.length,
                itemBuilder: (context, index) {
                  final store = storeState.stores[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: index < 3 ? Colors.orange : Colors.grey[300],
                      child: Text('${index + 1}'),
                    ),
                    title: Text(store.storeName),
                    subtitle: Text(store.categoryName),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        Text('${store.rating}'),
                      ],
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/store_detail', arguments: store);
                    },
                  );
                },
              );
            },
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('닫기'))],
      ),
    );
  }

  void _showCategoryRankingDialog(BuildContext context, String category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$category 순위'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: Consumer<StoreState>(
            builder: (context, storeState, child) {
              final filteredStores = storeState.stores.where((store) => store.categoryName == category).toList();

              return ListView.builder(
                itemCount: filteredStores.length,
                itemBuilder: (context, index) {
                  final store = filteredStores[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.getCategoryColor(category),
                      child: Text('${index + 1}'),
                    ),
                    title: Text(store.storeName),
                    subtitle: Text(store.address),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        Text('${store.rating}'),
                      ],
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/store_detail', arguments: store);
                    },
                  );
                },
              );
            },
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('닫기'))],
      ),
    );
  }

  void _showShoppingMallDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('쇼핑몰'),
        content: Text('외부 쇼핑몰로 연결됩니다.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('취소')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('이동'),
          ),
        ],
      ),
    );
  }

  void _showLocationRecommendationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('내 위치 추천'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('위치 기반 추천 서비스입니다.'),
            SizedBox(height: 8),
            Text(
              '현재 위치: $_locationText',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            if (_currentPosition != null) ...[
              SizedBox(height: 8),
              Text(
                '위도: ${_currentPosition!.latitude.toStringAsFixed(6)}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Text(
                '경도: ${_currentPosition!.longitude.toStringAsFixed(6)}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _getCurrentLocation(); // 위치 새로고침
            },
            child: Text('새로고침'),
          ),
          TextButton(onPressed: () => Navigator.pop(context), child: Text('확인')),
        ],
      ),
    );
  }

  void _showBestReviewDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('베스트 리뷰'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: 10,
            itemBuilder: (context, index) {
              return Card(
                child: ListTile(
                  leading: CircleAvatar(child: Text('${index + 1}')),
                  title: Text('홍길동 님'),
                  subtitle: Text('정말 정확한 상담이었어요! 추천합니다.'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(5, (i) => Icon(Icons.star, color: Colors.amber, size: 12)),
                  ),
                ),
              );
            },
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('닫기'))],
      ),
    );
  }

  Map<String, dynamic>? get termDto => _mainData['termDto'] as Map<String, dynamic>?;
  Map<String, dynamic>? get privacyDto => _mainData['privacyDto'] as Map<String, dynamic>?;

  void _showTermsDialog(BuildContext context) {
    final term = termDto;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('이용약관'),
        content: SizedBox(
          width: double.maxFinite,
          height: MediaQuery.of(context).size.height * 0.6,
          child: term != null
              ? SingleChildScrollView(
                  child: Html(
                    // ✅ Text 대신 Html 위젯 사용
                    data: term['content'] ?? '<p>내용이 없습니다.</p>',
                    style: {
                      // ✅ 스타일 커스터마이징 (선택사항)
                      "body": Style(fontSize: FontSize(14), lineHeight: LineHeight(1.6)),
                      "p": Style(margin: Margins.only(bottom: 12)),
                      "h1": Style(fontSize: FontSize(18), fontWeight: FontWeight.bold),
                      "h2": Style(fontSize: FontSize(16), fontWeight: FontWeight.bold),
                      "ul": Style(margin: Margins.only(left: 16, bottom: 12)),
                      "li": Style(margin: Margins.only(bottom: 4)),
                    },
                  ),
                )
              : Center(child: Text('이용약관을 불러올 수 없습니다.')),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('확인'))],
      ),
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    final privacy = privacyDto;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('개인정보 처리방침'),
        content: SizedBox(
          width: double.maxFinite,
          height: MediaQuery.of(context).size.height * 0.6,
          child: privacy != null
              ? SingleChildScrollView(
                  child: Html(
                    // ✅ Text 대신 Html 위젯 사용
                    data: privacy['content'] ?? '<p>내용이 없습니다.</p>',
                    style: {
                      // ✅ 스타일 커스터마이징 (선택사항)
                      "body": Style(fontSize: FontSize(14), lineHeight: LineHeight(1.6)),
                      "p": Style(margin: Margins.only(bottom: 12)),
                      "h1": Style(fontSize: FontSize(18), fontWeight: FontWeight.bold),
                      "h2": Style(fontSize: FontSize(16), fontWeight: FontWeight.bold),
                      "ul": Style(margin: Margins.only(left: 16, bottom: 12)),
                      "li": Style(margin: Margins.only(bottom: 4)),
                    },
                  ),
                )
              : Center(child: Text('이용약관을 불러올 수 없습니다.')),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('확인'))],
      ),
    );
  }
}
