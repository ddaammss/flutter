import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/store_state.dart';

class StoreSearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return Center(child: Text('검색어를 입력하세요'));
    }
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    return Consumer<StoreState>(
      builder: (context, storeState, child) {
        final filteredStores = storeState.stores
            .where(
              (store) =>
                  store.storeName.toLowerCase().contains(query.toLowerCase()) ||
                  store.categoryName.toLowerCase().contains(query.toLowerCase()) //||
                  //store.services.any((service) => service.toLowerCase().contains(query.toLowerCase())),
            )
            .toList();

        if (filteredStores.isEmpty) {
          return Center(child: Text('검색 결과가 없습니다'));
        }

        return ListView.builder(
          itemCount: filteredStores.length,
          itemBuilder: (context, index) {
            final store = filteredStores[index];
            return ListTile(
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
                child: Icon(Icons.store, color: Colors.grey[400]),
              ),
              title: Text(store.storeName),
              subtitle: Text('${store.categoryName} • ${store.address}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 16),
                  Text('${store.rating}'),
                ],
              ),
              onTap: () {
                close(context, store.storeName);
                Navigator.pushNamed(context, '/store_detail', arguments: store);
              },
            );
          },
        );
      },
    );
  }
}
