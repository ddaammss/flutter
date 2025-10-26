import 'package:flutter/material.dart';
import '../models/review.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ReviewCard extends StatelessWidget {
  final Review review;

  const ReviewCard({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 리뷰 이미지
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            child: AspectRatio(
              aspectRatio: 1.5, // 이미지 비율 (가로:세로 = 1.5:1)
              child: Container(
                color: Colors.grey[300],
                child: CachedNetworkImage(
                  imageUrl: Uri.encodeFull('https://amita86tg.duckdns.org${review.imagePath}'),
                  width: double.infinity,
                  height: 50,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) =>
                      Center(child: Icon(Icons.store, size: 40, color: Colors.grey[400])),
                ),
              ),
            ),
          ),

          // 하단 정보 영역
          Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 회원명
                Text(
                  review.userNickname,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 0.3),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                SizedBox(height: 10),
                Text(
                  review.content,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.6, letterSpacing: 0.2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
