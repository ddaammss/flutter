import 'package:flutter/material.dart';

class AppColors {
  // 메인 앱 색상
  static const Color primary = Color(0xFF3F51B5); // 인디고
  static const Color primaryDark = Color(0xFF303F9F);
  static const Color accent = Color(0xFFFF9800); // 오렌지

  // 카테고리별 색상
  static const Color sinjeom = Color(0xFF2196F3); // 파랑 - 신점
  static const Color tarot = Color(0xFF4CAF50); // 초록 - 타로
  static const Color philosophy = Color(0xFF9C27B0); // 보라 - 철학관
  static const Color shopping = Color(0xFFFF9800); // 오렌지 - 쇼핑몰

  // 순위 색상
  static const Color gold = Color(0xFFFFD700); // 1위 금색
  static const Color silver = Color(0xFFC0C0C0); // 2위 은색
  static const Color bronze = Color(0xFFCD7F32); // 3위 동색

  // 상태 색상
  static const Color success = Color(0xFF4CAF50); // 성공
  static const Color warning = Color(0xFFFF9800); // 경고
  static const Color error = Color(0xFFF44336); // 오류
  static const Color info = Color(0xFF2196F3); // 정보

  // 그레이 색상
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);

  // 배경 색상
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFAFAFA);

  // 텍스트 색상
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);

  // 특별 색상
  static const Color star = Color(0xFFFFB300); // 별점 색상
  static const Color heart = Color(0xFFE91E63); // 하트 색상
  static const Color online = Color(0xFF4CAF50); // 온라인 상태
  static const Color offline = Color(0xFF9E9E9E); // 오프라인 상태

  /// 카테고리에 따른 색상 반환
  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case '신점':
        return sinjeom;
      case '타로':
        return tarot;
      case '철학관':
        return philosophy;
      case '쇼핑몰':
        return shopping;
      default:
        return grey500;
    }
  }

  /// 순위에 따른 색상 반환
  static Color getRankColor(int rank) {
    switch (rank) {
      case 1:
        return gold;
      case 2:
        return silver;
      case 3:
        return bronze;
      default:
        return primary;
    }
  }

  /// 평점에 따른 색상 반환
  static Color getRatingColor(double rating) {
    if (rating >= 4.5) {
      return success;
    } else if (rating >= 4.0) {
      return warning;
    } else if (rating >= 3.0) {
      return Colors.orange;
    } else {
      return error;
    }
  }

  /// 상태에 따른 색상 반환
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case '확정':
      case '완료':
      case '성공':
        return success;
      case '대기':
      case '진행중':
        return warning;
      case '취소':
      case '실패':
        return error;
      case '준비중':
        return info;
      default:
        return grey500;
    }
  }

  /// 그라데이션 색상들
  static const List<Color> primaryGradient = [
    Color(0xFF3F51B5),
    Color(0xFF9C27B0),
  ];

  static const List<Color> sunsetGradient = [
    Color(0xFFFF9800),
    Color(0xFFFF5722),
  ];

  static const List<Color> oceanGradient = [
    Color(0xFF2196F3),
    Color(0xFF00BCD4),
  ];

  static const List<Color> forestGradient = [
    Color(0xFF4CAF50),
    Color(0xFF8BC34A),
  ];

  /// 카테고리별 그라데이션 반환
  static List<Color> getCategoryGradient(String category) {
    switch (category.toLowerCase()) {
      case '신점':
        return oceanGradient;
      case '타로':
        return forestGradient;
      case '철학관':
        return primaryGradient;
      case '쇼핑몰':
        return sunsetGradient;
      default:
        return primaryGradient;
    }
  }

  /// 투명도가 적용된 색상 반환
  static Color withAlpha(Color color, int alpha) {
    return color.withAlpha(alpha);
  }

  /// 밝기 조절된 색상 반환
  static Color lighten(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslLight = hsl.withLightness(
      (hsl.lightness + amount).clamp(0.0, 1.0),
    );
    return hslLight.toColor();
  }

  /// 어둡게 조절된 색상 반환
  static Color darken(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}
