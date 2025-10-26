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
  int _currentBannerIndex = 0;
  final PageController _bannerController = PageController();

  int _currentPopularIndex = 0;
  final PageController _popularRankingController = PageController(viewportFraction: 0.85);

  final PageController _allStoresController = PageController(viewportFraction: 0.85);

  final PageController _locationController = PageController(viewportFraction: 0.85);

  int _currentBanner2Index = 0;
  final PageController _banner2Controller = PageController();

  final PageController _productController = PageController(viewportFraction: 0.4);

  int _currentReviewIndex = 0;
  final PageController _reviewController = PageController(viewportFraction: 0.85);

  Position? _currentPosition;
  bool _isLoadingLocation = true;
  String _locationText = '위치를 불러오는 중...';

  final MainApi _mainApi = MainApi();

  // ✅ API 데이터를 저장할 변수 추가
  Map<String, dynamic> _mainData = {};

  //bool _isLoadingMainData = false;
  Timer? _popularAutoSlideTimer;
  Timer? _productAutoSlideTimer;
  Timer? _bannerAutoSlideTimer;
  Timer? _banner2AutoSlideTimer;
  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _checkAndLoadLocation();
    await _loadMainData();
  }

  Future<void> _loadMainData() async {
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
        //_isLoadingMainData = false;
      });
      _startPopularRankingAutoSlide();
      _startBannerAutoSlide();
      _startBanner2AutoSlide();
      // print('✅ 메인 데이터 로드 성공');
      // print('📦 전체 상점: ${(_mainData['allStoreDto'] as List?)?.length ?? 0}개');
      // print('📍 주변 상점: ${(_mainData['nearStoreDto'] as List?)?.length ?? 0}개');
      //print('🛍️  상품: ${(_mainData['productDto'] as List?)?.length ?? 0}개');
      // print('⭐ 리뷰: ${(_mainData['reviewDto'] as List?)?.length ?? 0}개');
      // print('⭐ 이용약관: ${_mainData['termDto'] != null ? '있음' : '없음'}');
      // print('⭐ 이용약관: ${_mainData['privacyDto'] != null ? '있음' : '없음'}');
      // print('⭐ 메인배너1: ${(_mainData['mainBannerDto'] as List?)?.length ?? 0}개');
      print('⭐ 메인배너2: ${(_mainData['mainBanner2Dto'] as List?)?.length ?? 0}개');
      // print('⭐ 인기순위: ${(_mainData['popularStoreDto'] as List?)?.length ?? 0}개');
    } catch (e) {
      print('❌ 메인 데이터 로드 실패: $e');
      setState(() {
        //_isLoadingMainData = false;
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
    _productAutoSlideTimer?.cancel();
    _bannerAutoSlideTimer?.cancel();
    _banner2AutoSlideTimer?.cancel();
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
              //_showEventDialog(context);
              Navigator.pushNamed(context, '/event');
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
            _buildMainBannerSection(context),
            SizedBox(height: 16), // ✅ 통일된 간격
            _buildPopularRankingSection(context),
            SizedBox(height: 16), // ✅ 통일된 간격
            _buildAllRankingSection(context),
            SizedBox(height: 16), // ✅ 통일된 간격
            _buildCategorySection(context),
            SizedBox(height: 16), // ✅ 통일된 간격
            _buildLocationRecommendationSection(context),
            SizedBox(height: 16), // ✅ 통일된 간격
            _buildBanner2Section(context),
            SizedBox(height: 16), // ✅ 통일된 간격
            _buildProductRecommendationSection(context),
            SizedBox(height: 16), // ✅ 통일된 간격
            _buildBestReviewSection(context),
            SizedBox(height: 16), // ✅ 통일된 간격
            _buildFooterSection(context),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  //-------------------------------- 메인 배너 --------------------------------
  Widget _buildMainBannerSection(BuildContext context) {
    List<dynamic> bannerList = _mainData['mainBannerDto'] ?? [];
    if (bannerList.isEmpty) {
      bannerList = [
        {'title': '운명을 만나는 특별한 순간', 'subtitle': '전문가들이 제공하는 정확한 상담', 'imagePath': null},
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
              return ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // ✅ 배경 이미지 (자동 리사이징)
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
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.black.withOpacity(0.2), Colors.black.withOpacity(0.4)],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
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

  void _startBannerAutoSlide() {
    _bannerAutoSlideTimer?.cancel();

    _bannerAutoSlideTimer = Timer.periodic(Duration(seconds: 4), (timer) {
      if (!mounted || !_bannerController.hasClients) {
        timer.cancel();
        return;
      }

      List<dynamic> bannerList = _mainData['mainBannerDto'] ?? [];

      if (bannerList.isEmpty) {
        bannerList = [
          {'title': '운명을 만나는 특별한 순간', 'subtitle': '전문가들이 제공하는 정확한 상담', 'imagePath': null},
          {'title': '신규 회원 50% 할인', 'subtitle': '지금 바로 상담 받아보세요', 'imagePath': null},
          {'title': '베스트 리뷰 이벤트', 'subtitle': '리뷰 작성하고 포인트 받으세요', 'imagePath': null},
        ];
      }

      if (bannerList.length <= 1) {
        return; // 배너가 1개 이하면 슬라이드 안 함
      }

      int nextPage = (_currentBannerIndex + 1) % bannerList.length;

      _bannerController.animateToPage(nextPage, duration: Duration(milliseconds: 400), curve: Curves.easeInOut);
    });
  }

  //-------------------------------- 인기급상승 --------------------------------
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
          popularList.isEmpty
              ? Center(
                  child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()),
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
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(builder: (context) => StoreDetailScreen(store: store)),
                          // );
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

  //-------------------------------- 전체 순위 --------------------------------
  Widget _buildAllRankingSection(BuildContext context) {
    List<dynamic> allStores = _mainData['allStoreDto'] ?? [];

    return _buildSection(
      context,
      title: '전체 순위',
      subtitle: '',
      showAll: true,
      onShowAll: () => _showAllRankingDialog(context, '전체 순위'),
      child: allStores.isEmpty
          ? Center(
              child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()),
            )
          : SizedBox(
              height: 190,
              child: PageView.builder(
                controller: _allStoresController,
                itemCount: allStores.length,
                itemBuilder: (context, index) {
                  final store = allStores[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 1),
                    child: StoreCard(
                      store: Store.fromJson(store), // JSON을 Store 객체로 변환
                    ),
                  );
                },
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
          );
        }).toList(),
      ),
    );
  }

  //-------------------------------- 내 위치 추천 --------------------------------
  Widget _buildLocationRecommendationSection(BuildContext context) {
    List<dynamic> nearStore = _mainData['nearStoreDto'] ?? [];
    return _buildSection(
      context,
      title: '내 위치 추천',
      subtitle: _locationText,
      showAll: true,
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

  //-------------------------------- 인기,신규 소개 --------------------------------
  Widget _buildBanner2Section(BuildContext context) {
    List<dynamic> banner2List = _mainData['mainBanner2Dto'] ?? [];
    if (banner2List.isEmpty) {
      banner2List = [
        {'title': '운명을 만나는 특별한 순간', 'subtitle': '전문가들이 제공하는 정확한 상담', 'imagePath': null},
      ];
    }

    return Container(
      height: 150,
      margin: EdgeInsets.all(16),
      child: Stack(
        children: [
          PageView.builder(
            controller: _banner2Controller,
            onPageChanged: (index) {
              setState(() {
                _currentBanner2Index = index;
              });
            },
            itemCount: banner2List.length,
            itemBuilder: (context, index) {
              final banner = banner2List[index] as Map<String, dynamic>;
              final imagePath = banner['imagePath'] as String?;
              return ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // ✅ 배경 이미지 (자동 리사이징)
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
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.black.withOpacity(0.2), Colors.black.withOpacity(0.4)],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                banner2List.length,
                (index) => Container(
                  width: 8,
                  height: 8,
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index == _currentBanner2Index ? Colors.white : Colors.white38,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _startBanner2AutoSlide() {
    _banner2AutoSlideTimer?.cancel();

    _banner2AutoSlideTimer = Timer.periodic(Duration(seconds: 4), (timer) {
      if (!mounted || !_banner2Controller.hasClients) {
        timer.cancel();
        return;
      }

      List<dynamic> mainBanner2List = _mainData['mainBanner2Dto'] ?? [];

      if (mainBanner2List.length <= 1) {
        return; // 배너가 1개 이하면 슬라이드 안 함
      }

      int nextPage = (_currentBanner2Index + 1) % mainBanner2List.length;

      _banner2Controller.animateToPage(nextPage, duration: Duration(milliseconds: 400), curve: Curves.easeInOut);
    });
  }

  //-------------------------------- 쇼핑몰 --------------------------------
  Widget _buildProductRecommendationSection(BuildContext context) {
    List<dynamic> products = _mainData['productDto'] ?? [];
    List<dynamic> displayProducts = products.length > 3 ? products.sublist(0, 3) : products;

    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.orange[100]!, Colors.orange[50]!]),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // 헤더
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.local_shipping, color: Colors.orange[700], size: 24),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '추천 상품, 총알 배송',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange[800]),
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
          SizedBox(height: 12),
          // 상품 리스트
          Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: displayProducts.map((product) {
                return Expanded(child: _buildProductCard(product));
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(dynamic product) {
    final imagePath = product['imagePath'];
    String? getImageUrl(String? path) {
      if (path == null || path.isEmpty) return null;
      if (path.startsWith('http')) return path;
      if (!path.startsWith('/')) path = '/$path';
      return 'https://amita86tg.duckdns.org$path';
    }

    final imageUrl = getImageUrl(imagePath);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 상품 이미지
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            child: imageUrl != null
                ? CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: double.infinity,
                    height: 130,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 130,
                      color: Colors.grey[300],
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) {
                      print('❌ Image load error: $error');
                      print('❌ Failed URL: $url');
                      return Container(
                        height: 130,
                        color: Colors.grey[300],
                        child: Center(child: Icon(Icons.shopping_bag, size: 40, color: Colors.grey[400])),
                      );
                    },
                  )
                : Container(
                    height: 130,
                    color: Colors.grey[300],
                    child: Center(child: Icon(Icons.shopping_bag, size: 40, color: Colors.grey[400])),
                  ),
          ),
          // 상품명
          Padding(
            padding: EdgeInsets.fromLTRB(8, 8, 8, 4),
            child: Text(
              product['name'] ?? '',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
          // 가격
          Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text(
              '${(product['price'])} 원',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red[700]),
            ),
          ),
        ],
      ),
    );
  }

  //-------------------------------- 베스트 리뷰 --------------------------------
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
            padding: EdgeInsets.all(10),
            child: Text('등록된 리뷰가 없습니다', style: TextStyle(color: Colors.grey[600])),
          ),
        ),
      );
    }
    return _buildSection(
      context,
      title: '베스트 리뷰',
      showAll: true,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          SizedBox(
            height: 350,
            child: PageView.builder(
              controller: _reviewController,
              onPageChanged: (index) {
                setState(() {
                  _currentReviewIndex = index;
                });
              },
              itemCount: reviewList.length,
              itemBuilder: (context, index) {
                final reviewJson = reviewList[index] as Map<String, dynamic>;
                final review = Review.fromJson(reviewJson);

                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: ReviewCard(review: review),
                );
              },
            ),
          ),
          Positioned(
            bottom: 8,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                reviewList.length,
                (index) => Container(
                  width: 6,
                  height: 19,
                  margin: EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
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

  //-------------------------------- footer --------------------------------
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
          Text('© 2025 무물. All rights reserved.', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
        ],
      ),
    );
  }

  //-------------------------------- 공통 --------------------------------
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
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))],
              ),
              if (subtitle != null)
                Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                ),
            ],
          ),
        ),
        SizedBox(height: 12),
        child,
      ],
    );
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
                    data: term['content'] ?? '<p>내용이 없습니다.</p>',
                    style: {
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
                    data: privacy['content'] ?? '<p>내용이 없습니다.</p>',
                    style: {
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
