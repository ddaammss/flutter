class AppConstants {
  // 앱 정보
  static const String appName = '무물';
  static const String appVersion = '1.0.0';
  static const String appDescription = '운명을 만나는 특별한 공간';

  // 크기 상수
  static const double borderRadius = 12.0;
  static const double cardElevation = 2.0;
  static const double iconSize = 24.0;
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;

  // 폰트 크기
  static const double fontSizeSmall = 12.0;
  static const double fontSizeMedium = 14.0;
  static const double fontSizeLarge = 16.0;
  static const double fontSizeTitle = 18.0;
  static const double fontSizeHeading = 20.0;

  // 애니메이션 시간
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationMedium = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // API 관련
  static const int timeoutSeconds = 30;
  static const int maxRetryCount = 3;

  // 카테고리 목록
  static const List<String> categories = ['신점', '타로', '철학관'];

  // 시간대 목록
  static const List<String> timeSlots = [
    '09:00',
    '10:00',
    '11:00',
    '12:00',
    '13:00',
    '14:00',
    '15:00',
    '16:00',
    '17:00',
    '18:00',
    '19:00',
    '20:00',
    '21:00',
  ];

  // 평점 옵션
  static const List<int> ratingOptions = [1, 2, 3, 4, 5];

  // 정렬 옵션
  static const List<String> sortOptions = ['거리순', '인기순', '리뷰순', '가격순'];

  // 가격 범위
  static const List<Map<String, dynamic>> priceRanges = [
    {'label': '1만원 미만', 'min': 0, 'max': 10000},
    {'label': '1만원 ~ 3만원', 'min': 10000, 'max': 30000},
    {'label': '3만원 ~ 5만원', 'min': 30000, 'max': 50000},
    {'label': '5만원 이상', 'min': 50000, 'max': 999999},
  ];

  // 에러 메시지
  static const String errorNetwork = '네트워크 연결을 확인해주세요.';
  static const String errorServer = '서버에 문제가 발생했습니다.';
  static const String errorTimeout = '요청 시간이 초과되었습니다.';
  static const String errorUnknown = '알 수 없는 오류가 발생했습니다.';

  // 성공 메시지
  static const String successBooking = '예약이 완료되었습니다.';
  static const String successReview = '리뷰가 등록되었습니다.';
  static const String successLogin = '로그인되었습니다.';
  static const String successLogout = '로그아웃되었습니다.';
}
