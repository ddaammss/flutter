import 'package:flutter/material.dart';
import 'package:sajunara_app/services/api/store_api.dart';
import 'package:sajunara_app/models/store.dart';

class StoreSearchBottomSheet extends StatefulWidget {
  const StoreSearchBottomSheet({super.key});

  @override
  State<StoreSearchBottomSheet> createState() => _StoreSearchBottomSheetState();
}

class _StoreSearchBottomSheetState extends State<StoreSearchBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  final StoreApi _storeApi = StoreApi();
  bool _isLoading = false;
  Map<String, dynamic> _store = {};
  bool _hasSearched = false; // 검색을 실행했는지 여부

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch() async {
    final query = _searchController.text.trim();

    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('검색어를 입력하세요')));
      return;
    }

    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    try {
      final data = await _storeApi.fetchStoreListData(requestBody: {'storeName': query});
      setState(() {
        _store = data;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ 입점사 검색 에러: $e');
      setState(() {
        _store = {};
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('검색 중 오류가 발생했습니다'), backgroundColor: Colors.red, duration: Duration(seconds: 2)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Scaffold(
        backgroundColor: Colors.black54, // 딤 처리
        body: GestureDetector(
          onTap: () {}, // 내부 클릭 시 닫히지 않도록
          child: SafeArea(
            child: Column(
              children: [
                // 상단 여백 (검색창을 중앙으로 내리기 위해)
                Expanded(
                  flex: 2, // 상단 공간
                  child: Container(),
                ),

                // 검색 입력 영역
                Container(
                  color: Colors.transparent,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
                          child: Row(
                            children: [
                              SizedBox(width: 16),
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  autofocus: true,
                                  style: TextStyle(fontSize: 16),
                                  decoration: InputDecoration(
                                    hintText: '입점사를 검색하세요',
                                    border: InputBorder.none,
                                    hintStyle: TextStyle(color: Colors.grey[400]),
                                  ),
                                  textInputAction: TextInputAction.search,
                                  onSubmitted: (value) => _performSearch(),
                                ),
                              ),
                              if (_searchController.text.isNotEmpty)
                                IconButton(
                                  icon: Icon(Icons.clear, size: 20, color: Colors.grey[600]),
                                  onPressed: () {
                                    setState(() {
                                      _searchController.clear();
                                      _store = {};
                                      _hasSearched = false;
                                    });
                                  },
                                ),
                              IconButton(
                                icon: Icon(Icons.search, color: Colors.grey[700]),
                                onPressed: _performSearch,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          '취소',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),

                // 하단 여백 또는 검색 결과
                Expanded(
                  flex: 3, // 하단 공간
                  child: _hasSearched
                      ? Container(
                          margin: EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 16),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                          child: _buildSearchResults(),
                        )
                      : Container(), // 검색 전에는 빈 공간
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    // 로딩 중
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    // Map에서 리스트 추출 (data 키에 리스트가 들어있다고 가정)
    final storeList = (_store['storeListDto'] as List<dynamic>?) ?? [];

    // 검색 결과 없음
    if (storeList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
            SizedBox(height: 16),
            Text('검색 결과가 없습니다', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          ],
        ),
      );
    }

    // 검색 결과 리스트
    return ListView.separated(
      padding: EdgeInsets.symmetric(vertical: 8),
      itemCount: storeList.length,
      separatorBuilder: (context, index) => Divider(height: 1, indent: 72),
      itemBuilder: (context, index) {
        final store = storeList[index] as Map<String, dynamic>?;
        if (store == null) {
          return SizedBox.shrink(); // 빈 위젯 반환
        }
        return ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.store, color: Colors.grey[400], size: 28),
          ),
          title: Text(
            store['storeName'] ?? store['name'] ?? '',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          subtitle: Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              '${store['categoryName'] ?? store['category'] ?? ''} • ${store['address'] ?? ''}',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ),
          trailing: Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: Colors.amber[50], borderRadius: BorderRadius.circular(8)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star, color: Colors.amber, size: 16),
                SizedBox(width: 4),
                Text(
                  double.parse(store['grade'].toString()).toStringAsFixed(1),
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ],
            ),
          ),
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/store_detail', arguments: Store.fromJson(store));
          },
        );
      },
    );
  }
}
