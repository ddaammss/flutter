class Booking {
  final String seq;
  final String storeSeq;
  final String reservationCode;
  final String storeCode;
  final String storeName;
  final String categoryName;
  final String address;
  final String grade;
  final String reviewCount;
  final String productName;
  final String productPrice;
  final String startTime;
  final String endTime;
  final String imagePath;
  final List<String> reservedTimes;
  final String serviceSeq;
  final List<ReservationDetail>? reservations;

  Booking({
    this.seq = '',
    this.storeSeq = '',
    this.reservationCode = '',
    this.storeCode = '',
    this.storeName = '',
    this.categoryName = '',
    this.address = '',
    this.grade = '0',
    this.reviewCount = '0',
    this.productName = '',
    this.productPrice = '0',
    this.startTime = '',
    this.endTime = '',
    this.imagePath = '',
    this.reservedTimes = const [],
    this.serviceSeq = '',
    this.reservations,
  });

  Booking copyWith({
    String? seq,
    String? storeSeq,
    String? reservationCode,
    String? storeCode,
    String? storeName,
    String? categoryName,
    String? address,
    String? grade,
    String? reviewCount,
    String? productName,
    String? productPrice,
    String? startTime,
    String? endTime,
    String? imagePath,
    List<String>? reservedTimes,
    String? serviceSeq,
    List<ReservationDetail>? reservations,
  }) {
    return Booking(
      seq: seq ?? this.seq,
      storeSeq: storeSeq ?? this.storeSeq,
      reservationCode: reservationCode ?? this.reservationCode,
      storeCode: storeCode ?? this.storeCode,
      storeName: storeName ?? this.storeName,
      categoryName: categoryName ?? this.categoryName,
      address: address ?? this.address,
      grade: grade ?? this.grade,
      reviewCount: reviewCount ?? this.reviewCount,
      productName: productName ?? this.productName,
      productPrice: productPrice ?? this.productPrice,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      imagePath: imagePath ?? this.imagePath,
      reservedTimes: reservedTimes ?? this.reservedTimes,
      serviceSeq: serviceSeq ?? this.serviceSeq,
      reservations: reservations ?? this.reservations,
    );
  }

  factory Booking.fromJson(Map<String, dynamic> json) {
    List<String> parseReservedTimes(dynamic value) {
      if (value == null) return [];
      if (value is String) {
        if (value.isEmpty) return [];
        return value.split(',').map((e) => e.trim()).toList();
      }
      if (value is List) {
        return value.map((e) => e.toString()).toList();
      }
      return [];
    }

    return Booking(
      seq: json['seq']?.toString() ?? '',
      storeSeq: json['storeSeq']?.toString() ?? '',
      reservationCode: json['reservationCode']?.toString() ?? '',
      storeCode: json['storeCode']?.toString() ?? '',
      storeName: json['storeName']?.toString() ?? '',
      categoryName: json['categoryName']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      grade: json['grade']?.toString() ?? '0',
      reviewCount: json['reviewCount']?.toString() ?? '0',
      productName: json['productName']?.toString() ?? '',
      productPrice: json['productPrice']?.toString() ?? '0',
      startTime: json['startTime']?.toString() ?? '',
      endTime: json['endTime']?.toString() ?? '',
      imagePath: json['imagePath']?.toString() ?? '',
      reservedTimes: parseReservedTimes(json['reservedTimes']),
      serviceSeq: json['serviceSeq']?.toString() ?? '',
      reservations: json['reverservationResponseDtos'] != null
          ? (json['reverservationResponseDtos'] as List).map((item) => ReservationDetail.fromJson(item)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'seq': seq, 'storeCode': storeCode, 'serviceSeq': serviceSeq};
  }

  double get rating => double.tryParse(grade) ?? 0.0;
  int get reviews => int.tryParse(reviewCount) ?? 0;
  int get price => int.tryParse(productPrice) ?? 0;
}

class ReservationDetail {
  final String? seq;
  final String? storeSeq;
  final String? reservationCode;
  final String? reservationDate;
  final String? reservationTime;
  final String? storeCode;
  final String? storeName;
  final String? grade;
  final String? reviewCount;
  final String? productName;
  final String? productPrice;

  ReservationDetail({
    this.seq,
    this.storeSeq,
    this.reservationCode,
    this.reservationDate,
    this.reservationTime,
    this.storeCode,
    this.storeName,
    this.grade,
    this.reviewCount,
    this.productName,
    this.productPrice,
  });

  factory ReservationDetail.fromJson(Map<String, dynamic> json) {
    return ReservationDetail(
      seq: json['seq']?.toString(),
      storeSeq: json['storeSeq']?.toString(),
      reservationCode: json['reservationCode']?.toString(),
      reservationDate: json['reservationDate']?.toString(),
      reservationTime: json['reservationTime']?.toString(),
      storeCode: json['storeCode']?.toString(),
      storeName: json['storeName']?.toString(),
      grade: json['grade']?.toString(),
      reviewCount: json['reviewCount']?.toString(),
      productName: json['productName']?.toString(),
      productPrice: json['productPrice']?.toString(),
    );
  }

  double get rating => double.tryParse(grade ?? '0') ?? 0.0;
  int get reviews => int.tryParse(reviewCount ?? '0') ?? 0;
}
