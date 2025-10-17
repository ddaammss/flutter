import 'package:flutter/material.dart';
import '../models/review.dart';

class ReviewCard extends StatelessWidget {
  final Review review;

  const ReviewCard({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min, // ✅ 추가!
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단: 사용자 정보 & 별점
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  // ✅ Row 안의 Row를 Expanded로 감싸기
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.blue[100],
                        child: Text(
                          review.userNickname.isNotEmpty ? review.userNickname[0] : '?',
                          style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        // ✅ Column도 Expanded로 감싸기
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min, // ✅ 추가
                          children: [
                            Text(
                              review.userNickname,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              overflow: TextOverflow.ellipsis, // ✅ 이름도 긴 경우 대비
                            ),
                            Text(
                              review.storeName,
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              overflow: TextOverflow.ellipsis, // ✅ 가게명도 긴 경우 대비
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // 별점 표시 (주석 해제하려면)
                // Row(
                //   children: List.generate(
                //     5,
                //     (i) => Icon(
                //       i < review.rating.toInt() ? Icons.star : Icons.star_border,
                //       color: Colors.amber,
                //       size: 16,
                //     ),
                //   ),
                // ),
              ],
            ),

            SizedBox(height: 12),

            // 리뷰 내용 (2줄 제한)
            Text(
              review.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13, color: Colors.grey[800]),
            ),

            SizedBox(height: 8),

            // 작성일
            //Text(review.createdAt, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
          ],
        ),
      ),
    );
  }
}
