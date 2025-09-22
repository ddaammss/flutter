import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  int _currentIndex = 0;
  bool _isLocationPermissionGranted = false;
  bool _isNotificationPermissionGranted = false;

  int get currentIndex => _currentIndex;
  bool get isLocationPermissionGranted => _isLocationPermissionGranted;
  bool get isNotificationPermissionGranted => _isNotificationPermissionGranted;

  void setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void setLocationPermission(bool granted) {
    _isLocationPermissionGranted = granted;
    notifyListeners();
  }

  void setNotificationPermission(bool granted) {
    _isNotificationPermissionGranted = granted;
    notifyListeners();
  }
}
