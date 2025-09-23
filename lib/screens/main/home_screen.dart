import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../providers/store_state.dart';
import '../../models/store.dart';
import '../search/search_delegate.dart';
import '../../widgets/store_card.dart';
import '../../widgets/review_card.dart';
import '../../widgets/ranking_card.dart';
import '../../widgets/product_card.dart';
import '../../utils/colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          '사주나라',
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
            // 메인 배너
            _buildMainBanner(context),

            // 인기 급상승 순위
            _buildPopularRankingSection(context),

            // 전체 순위 섹션 (새로 추가)
            _buildAllRankingSection(context),

            // 카테고리
            _buildCategorySection(context),

            // 내 위치 추천
            _buildLocationRecommendationSection(context),

            // 추천 상품, 총알 배송 섹션 (새로 추가)
            _buildProductRecommendationSection(context),

            // 베스트 리뷰
            _buildBestReviewSection(context),

            // 하단 링크
            _buildFooterSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildMainBanner(BuildContext context) {
    return Container(
      height: 200,
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [Colors.indigo[400]!, Colors.purple[400]!],
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '운명을 만나는 특별한 순간',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '전문가들이 제공하는 정확한 상담',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
          ),
          // 배너 인디케이터
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (index) => Container(
                  width: 8,
                  height: 8,
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index == 0 ? Colors.white : Colors.white38,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularRankingSection(BuildContext context) {
    return _buildSection(
      context,
      title: '인기 급상승 순위',
      subtitle: '타로 · 운명',
      showAll: true,
      onShowAll: () => _showAllRankingDialog(context, '인기 급상승'),
      child: Consumer<StoreState>(
        builder: (context, storeState, child) {
          return SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: storeState.popularStores.length,
              itemBuilder: (context, index) {
                final store = storeState.popularStores[index];
                return RankingCard(store: store, rank: index + 1);
              },
            ),
          );
        },
      ),
    );
  }

  // 새로 추가된 전체 순위 섹션
  Widget _buildAllRankingSection(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '전체 순위',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () => _showAllRankingDialog(context, '전체 순위'),
                child: Text('전체보기'),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildCategoryRankingButton(
                context,
                '신점',
                Colors.blue,
                Icons.star,
              ),
              _buildCategoryRankingButton(
                context,
                '타로',
                Colors.green,
                Icons.auto_awesome,
              ),
              _buildCategoryRankingButton(
                context,
                '철학관',
                Colors.purple,
                Icons.school,
              ),
              _buildCategoryRankingButton(
                context,
                '쇼핑몰',
                Colors.orange,
                Icons.shopping_bag,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryRankingButton(
    BuildContext context,
    String category,
    Color color,
    IconData icon,
  ) {
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
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
            Text(
              '전체 순위',
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection(BuildContext context) {
    final categories = [
      //{'name': '신점', 'icon': Icons.star, 'color': Colors.blue},
      //{'name': '타로', 'icon': Icons.auto_awesome, 'color': Colors.green},
      //{'name': '철학관', 'icon': Icons.school, 'color': Colors.purple},
      //{'name': '쇼핑몰', 'icon': Icons.shopping_bag, 'color': Colors.orange},
    ];

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
                  child: Icon(
                    category['icon'] as IconData,
                    color: category['color'] as Color,
                    size: 30,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  category['name'] as String,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLocationRecommendationSection(BuildContext context) {
    return _buildSection(
      context,
      title: '내 위치 추천',
      subtitle: '서울 > 은평구',
      showAll: true,
      onShowAll: () => _showLocationRecommendationDialog(context),
      child: Consumer<StoreState>(
        builder: (context, storeState, child) {
          return SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: storeState.nearbyStores.length,
              itemBuilder: (context, index) {
                final store = storeState.nearbyStores[index];
                return StoreCard(store: store);
              },
            ),
          );
        },
      ),
    );
  }

  // 새로 추가된 추천 상품 섹션
  Widget _buildProductRecommendationSection(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange[100]!, Colors.orange[50]!],
        ),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '추천 상품, 총알 배송',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[800],
                        ),
                      ),
                      Text(
                        '인기, 신규 소개',
                        style: TextStyle(
                          color: Colors.orange[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _showShoppingMallDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text('전체보기'),
                ),
              ],
            ),
          ),
          // 상품 목록
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: 5,
              itemBuilder: (context, index) {
                return ProductCard(
                  name: _getProductName(index),
                  price: _getProductPrice(index),
                  originalPrice: _getOriginalPrice(index),
                  discount: _getDiscount(index),
                  isNew: index < 2,
                  isPopular: index % 2 == 0,
                );
              },
            ),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildBestReviewSection(BuildContext context) {
    return _buildSection(
      context,
      title: '베스트 리뷰',
      showAll: true,
      onShowAll: () => _showBestReviewDialog(context),
      child: SizedBox(
        height: 150,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 16),
          itemCount: 5,
          itemBuilder: (context, index) {
            return ReviewCard(index: index);
          },
        ),
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
                child: Text(
                  '개인정보 처리방침',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            '© 2024 사주나라. All rights reserved.',
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
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
                  Text(
                    title,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  if (showAll)
                    TextButton(onPressed: onShowAll, child: Text('전체보기')),
                ],
              ),
              if (subtitle != null)
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
            ],
          ),
        ),
        child,
      ],
    );
  }

  // 상품 데이터 생성 함수들
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

  // 다이얼로그 함수들
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
              leading: Icon(Icons.star, color: Colors.green), // 원래는 gold 였음
              title: Text('리뷰 작성 이벤트'),
              subtitle: Text('리뷰 작성시 포인트 적립'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('확인'),
          ),
        ],
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
                      backgroundColor: index < 3
                          ? Colors.orange
                          : Colors.grey[300],
                      child: Text('${index + 1}'),
                    ),
                    title: Text(store.name),
                    subtitle: Text(store.category),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        Text('${store.rating}'),
                      ],
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(
                        context,
                        '/store_detail',
                        arguments: store,
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('닫기'),
          ),
        ],
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
              final filteredStores = storeState.stores
                  .where((store) => store.category == category)
                  .toList();

              return ListView.builder(
                itemCount: filteredStores.length,
                itemBuilder: (context, index) {
                  final store = filteredStores[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.getCategoryColor(category),
                      child: Text('${index + 1}'),
                    ),
                    title: Text(store.name),
                    subtitle: Text(store.location),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        Text('${store.rating}'),
                      ],
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(
                        context,
                        '/store_detail',
                        arguments: store,
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('닫기'),
          ),
        ],
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
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // 외부 브라우저 연결 로직
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
        content: Text('위치 기반 추천 서비스입니다.\n현재 위치: 서울 > 은평구'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('확인'),
          ),
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
                    children: List.generate(
                      5,
                      (i) => Icon(Icons.star, color: Colors.amber, size: 12),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('닫기'),
          ),
        ],
      ),
    );
  }

  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('이용약관'),
        content: Text('사주나라 서비스 이용약관 내용...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('개인정보 처리방침'),
        content: Text('개인정보 처리방침 내용...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('확인'),
          ),
        ],
      ),
    );
  }
}
