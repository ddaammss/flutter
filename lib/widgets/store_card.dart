import 'package:flutter/material.dart';
import 'package:sajunara_app/models/store.dart';
import '../utils/colors.dart';
import 'package:cached_network_image/cached_network_image.dart';

class StoreCard extends StatelessWidget {
  final Store store;

  const StoreCard({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/store_detail', arguments: store);
      },

      child: Container(
        width: 160,
        margin: EdgeInsets.only(right: 12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                child: CachedNetworkImage(
                  imageUrl: Uri.encodeFull('https://amita86tg.duckdns.org${store.imagePath}'),
                  width: double.infinity,
                  height: 100,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) =>
                      Center(child: Icon(Icons.store, size: 40, color: Colors.grey[400])),
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.getCategoryColor(store.categoryName),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(store.categoryName, style: TextStyle(color: Colors.white, fontSize: 10)),
                  ),
                  SizedBox(height: 4),
                  Text(
                    store.storeName,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 12),
                      Text('${store.rating}', style: TextStyle(fontSize: 10)),
                      SizedBox(width: 4),
                      Text(store.reviewCount, style: TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                  Text(store.address, style: TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
