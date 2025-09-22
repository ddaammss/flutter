// 카테고리 화면
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sajunara_app/models/store.dart';
import 'package:sajunara_app/providers/store_state.dart';

class CategoryScreen extends StatelessWidget {
  final String category;

  CategoryScreen({required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(category),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {},
            itemBuilder: (context) => [
              PopupMenuItem(value: '거리순', child: Text('거리순')),
              PopupMenuItem(value: '인기순', child: Text('인기순')),
              PopupMenuItem(value: '리뷰순', child: Text('리뷰순')),
            ],
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('정렬', style: TextStyle(color: Colors.black)),
                  Icon(Icons.arrow_drop_down, color: Colors.black),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Consumer<StoreState>(
        builder: (context, storeState, child) {
          final filteredStores = storeState.stores
              .where((store) => store.category == category)
              .toList();

          return Column(
            children: [
              // 배너 이미지
              Container(
                height: 150,
                width: double.infinity,
                color: _getCategoryColor(category).withOpacity(0.1),
                child: Center(
                  child: Text(
                    '$category 전문가들',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _getCategoryColor(category),
                    ),
                  ),
                ),
              ),

              // 스토어 리스트
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: filteredStores.length,
                  itemBuilder: (context, index) {
                    final store = filteredStores[index];
                    return _buildStoreListItem(context, store);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStoreListItem(BuildContext context, Store store) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/store_detail', arguments: store);
      },
      child: Card(
        margin: EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.store, color: Colors.grey[400]),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(store.category),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        store.category,
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      store.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      store.description,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        Text('${store.rating}'),
                        SizedBox(width: 8),
                        Icon(Icons.chat_bubble_outline, size: 16),
                        Text('${store.reviewCount}'),
                        Spacer(),
                        Text(
                          store.location,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      children: store.services
                          .map(
                            (service) => Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                service,
                                style: TextStyle(fontSize: 10),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.yellow[600],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '예약신청',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case '신점':
        return Colors.blue;
      case '타로':
        return Colors.green;
      case '철학관':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
