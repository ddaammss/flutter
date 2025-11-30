class Store {
  final String seq;
  final String storeCode;
  final String storeName;
  final String description;
  final String categoryName;
  final String address;
  final String grade;
  final String reviewCount;
  final double latitude;
  final double longitude;
  final double distance;
  final List<String> services;

  final String operatingHours;
  final String imagePath;

  Store({
    this.seq = '',
    this.storeCode = '',
    this.storeName = '',
    this.description = '',
    this.categoryName = '',
    this.address = '',
    this.grade = '',
    this.reviewCount = '0',
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.distance = 0.0,
    this.services = const [],
    this.operatingHours = '',
    this.imagePath = '',
  });

  // ✅ JSON → Store 객체로 변환
  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      seq: json['seq']?.toString() ?? '',
      storeCode: json['storeCode']?.toString() ?? '',
      storeName: json['storeName']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      categoryName: json['categoryName']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      grade: json['grade']?.toString() ?? '',
      reviewCount: json['reviewCount']?.toString() ?? '0',

      operatingHours: json['operatingHours']?.toString() ?? '',
      imagePath: json['imagePath']?.toString() ?? '',

      // ✅ services 수정
      services: (json['services'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],

      latitude: (json['latitude'] is String)
          ? double.tryParse(json['latitude']) ?? 0.0
          : (json['latitude']?.toDouble() ?? 0.0),
      longitude: (json['longitude'] is String)
          ? double.tryParse(json['longitude']) ?? 0.0
          : (json['longitude']?.toDouble() ?? 0.0),
      distance: (json['distance'] is String)
          ? double.tryParse(json['distance']) ?? 0.0
          : (json['distance']?.toDouble() ?? 0.0),
    );
  }

  // ✅ Store 객체 → JSON으로 변환 (필요시)
  Map<String, dynamic> toJson() {
    return {
      'seq': seq,
      'storeCode': storeCode,
      'storeName': storeName,
      'description': description,
      'categoryName': categoryName,
      'address': address,
      'grade': grade,
      'reviewCount': reviewCount,
      'latitude': latitude,
      'longitude': longitude,
      'distance': distance,
      'services': services,
      'operatingHours': operatingHours,
      'imagePath': imagePath,
    };
  }

  // ✅ 평점을 double로 반환 (편의 메서드)
  double get rating => double.tryParse(grade ?? '0') ?? 0.0;

  void operator []=(String other, value) {}
}
