import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final String name;
  final int price;
  final int originalPrice;
  final int discount;
  final bool isNew;
  final bool isPopular;

  const ProductCard({
    super.key,
    required this.name,
    required this.price,
    required this.originalPrice,
    required this.discount,
    this.isNew = false,
    this.isPopular = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showProductDialog(context);
      },
      child: Container(
        width: 140,
        margin: EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(8),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      _getProductIcon(),
                      size: 40,
                      color: Colors.orange[300],
                    ),
                  ),
                ),
                // 할인율 배지
                if (discount > 0)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$discount%',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                // 새상품/인기 배지
                if (isNew || isPopular)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isNew ? Colors.green : Colors.blue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        isNew ? 'NEW' : '인기',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  if (discount > 0)
                    Text(
                      '${originalPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  Text(
                    '${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getProductIcon() {
    switch (name) {
      case '행운의 부적':
        return Icons.auto_awesome;
      case '수험생 합격 부적':
        return Icons.school;
      case '연애운 타로카드':
        return Icons.favorite;
      case '재물운 수정구슬':
        return Icons.monetization_on;
      case '액막이 팔찌':
        return Icons.security;
      default:
        return Icons.card_giftcard;
    }
  }

  void _showProductDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(
                  _getProductIcon(),
                  size: 60,
                  color: Colors.orange[300],
                ),
              ),
            ),
            SizedBox(height: 16),
            if (discount > 0) ...[
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '$discount% 할인',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    '${originalPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원',
                    style: TextStyle(
                      decoration: TextDecoration.lineThrough,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
            ],
            Text(
              '${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.orange[700],
              ),
            ),
            SizedBox(height: 12),
            Text(
              _getProductDescription(),
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.local_shipping, size: 16, color: Colors.green),
                SizedBox(width: 4),
                Text(
                  '총알 배송',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('닫기'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showPurchaseDialog(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: Text('구매하기'),
          ),
        ],
      ),
    );
  }

  String _getProductDescription() {
    switch (name) {
      case '행운의 부적':
        return '전통 방식으로 제작된 행운을 부르는 부적입니다. 일상생활에 행운과 복을 가져다 줍니다.';
      case '수험생 합격 부적':
        return '시험과 입시에 도움을 주는 합격 기원 부적입니다. 많은 수험생들이 선택한 베스트 상품입니다.';
      case '연애운 타로카드':
        return '연애운을 높여주는 특별한 타로카드 세트입니다. 사랑을 찾고 관계를 개선하는데 도움을 줍니다.';
      case '재물운 수정구슬':
        return '재물운과 금전운을 상승시켜주는 천연 수정구슬입니다. 사업과 투자에 도움을 줍니다.';
      case '액막이 팔찌':
        return '나쁜 기운을 막아주고 보호해주는 액막이 팔찌입니다. 일상의 안전과 평안을 지켜줍니다.';
      default:
        return '특별히 제작된 개운 상품입니다.';
    }
  }

  void _showPurchaseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('구매 확인'),
        content: Text('외부 쇼핑몰로 이동하여 구매를 진행하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // 실제로는 외부 브라우저나 쇼핑몰 앱으로 연결
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('쇼핑몰로 이동합니다...'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: Text('이동'),
          ),
        ],
      ),
    );
  }
}
