class Review {
  final String seq;
  final String storeCode;
  final String storeName;
  final String userNickname;
  final String content;
  final String grade;
  final String createdAt;
  final String? imagePath;

  Review({
    required this.seq,
    required this.storeCode,
    required this.storeName,
    required this.userNickname,
    required this.content,
    required this.grade,
    required this.createdAt,
    this.imagePath,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      seq: json['seq']?.toString() ?? '',
      storeCode: json['storeCode']?.toString() ?? '',
      storeName: json['storeName']?.toString() ?? '',
      userNickname: json['userNickname']?.toString() ?? '익명',
      content: json['content']?.toString() ?? '',
      grade: json['grade']?.toString() ?? '0',
      createdAt: json['createdAt']?.toString() ?? '',
      imagePath: json['imagePath']?.toString(),
    );
  }

  double get rating => double.tryParse(grade) ?? 0.0;
}