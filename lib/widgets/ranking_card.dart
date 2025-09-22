import 'package:flutter/material.dart';
import '../models/store.dart';
import '../utils/colors.dart';

class RankingCard extends StatelessWidget {
  final Store store;
  final int rank;

  const RankingCard({Key? key, required this.store, required this.rank})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/store_detail', arguments: store);
      },
      child: Container(
        width: 180,
        margin: EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                  child: Center(
                    child: Icon(Icons.store, size: 40, color: Colors.grey[400]),
                  ),
                ),
                // 순위 배지
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: _getRankColor(rank),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '$rank',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
                // 상승/하락 표시
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: rank <= 3 ? Colors.red : Colors.blue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          rank <= 3 ? Icons.arrow_upward : Icons.arrow_downward,
                          color: Colors.white,
                          size: 12,
                        ),
                        Text(
                          '${rank <= 3 ? '+' : '-'}${rank}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.getCategoryColor(store.category),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      store.category,
                      style: TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    store.name,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 14),
                      Text('${store.rating}', style: TextStyle(fontSize: 12)),
                      SizedBox(width: 4),
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 12,
                        color: Colors.grey,
                      ),
                      Text(
                        '${store.reviewCount}',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  SizedBox(height: 2),
                  Text(
                    store.location,
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber; // 금색
      case 2:
        return Colors.grey[400]!; // 은색
      case 3:
        return Colors.brown; // 동색
      default:
        return Colors.blue; // 기본색
    }
  }
}
