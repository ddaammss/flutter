import 'package:flutter/material.dart';

class ReviewCard extends StatelessWidget {
  final int index;

  const ReviewCard({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    final reviewData = _getReviewData(index);

    return Container(
      width: 200,
      margin: EdgeInsets.only(right: 12),
      padding: EdgeInsets.all(16),
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
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: _getAvatarColor(index),
                child: Text(
                  reviewData['name']![0],
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  reviewData['name']!,
                  style: TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            reviewData['content']!,
            style: TextStyle(fontSize: 12),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 8),
          Row(
            children: List.generate(
              5,
              (i) => Icon(
                Icons.star,
                color: i < reviewData['rating']!
                    ? Colors.amber
                    : Colors.grey[300],
                size: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getReviewData(int index) {
    final reviews = [
      {
        'name': '홍길동',
        'content': '정말 정확한 상담이었어요. 앞으로의 방향에 대해 많은 도움을 받았습니다.',
        'rating': 5,
      },
      {
        'name': '김영희',
        'content': '친절하고 자세한 설명 감사합니다. 마음이 한결 편해졌어요.',
        'rating': 5,
      },
      {
        'name': '박철수',
        'content': '예약부터 상담까지 모든 과정이 만족스러웠습니다. 추천해요!',
        'rating': 4,
      },
      {
        'name': '이미영',
        'content': '진심 어린 조언과 상담에 감동했습니다. 다시 방문할 예정이에요.',
        'rating': 5,
      },
      {
        'name': '최민수',
        'content': '전문적이고 정확한 상담이었습니다. 고민이 많이 해결되었어요.',
        'rating': 4,
      },
    ];
    return reviews[index % reviews.length];
  }

  Color _getAvatarColor(int index) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
    ];
    return colors[index % colors.length];
  }
}
