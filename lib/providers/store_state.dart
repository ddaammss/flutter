import 'package:flutter/material.dart';
import 'package:sajunara_app/models/store.dart';

class StoreState extends ChangeNotifier {
  List<Store> _stores = [];
  List<Store> _popularStores = [];
  List<Store> _nearbyStores = [];

  List<Store> get stores => _stores;
  List<Store> get popularStores => _popularStores;
  List<Store> get nearbyStores => _nearbyStores;

  void loadStores() {
    // 더미 데이터
    _stores = [
      Store(
        id: '1',
        name: '운명을 설계하는 타로 마스터',
        category: '타로',
        rating: 5.0,
        reviewCount: 1234,
        location: '서울 · 은평',
        description: '타로로 운명을 설계하는 마스터입니다.',
        services: ['직업', '사업', '재물', '합격'],
        operatingHours: '12:00 ~ 18:00',
        price: 30000,
      ),
      Store(
        id: '2',
        name: '정통 사주명리학원',
        category: '신점',
        rating: 4.8,
        reviewCount: 987,
        location: '서울 · 강남',
        description: '30년 경력의 정통 사주명리학원입니다.',
        services: ['사주', '궁합', '택일', '개명'],
        operatingHours: '09:00 ~ 22:00',
        price: 50000,
      ),
      Store(
        id: '3',
        name: '동양철학연구소',
        category: '철학관',
        rating: 4.9,
        reviewCount: 756,
        location: '서울 · 종로',
        description: '동양철학을 바탕으로 한 상담을 제공합니다.',
        services: ['철학상담', '인생상담', '진로상담'],
        operatingHours: '10:00 ~ 20:00',
        price: 40000,
      ),
    ];

    _popularStores = List.from(_stores);
    _nearbyStores = List.from(_stores);
    notifyListeners();
  }
}
