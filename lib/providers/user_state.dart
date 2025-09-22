import 'package:flutter/material.dart';

class UserState extends ChangeNotifier {
  bool _isLoggedIn = false;
  String _userName = '';
  String _userBirthDate = '';
  int _points = 0;
  List<String> _coupons = [];

  bool get isLoggedIn => _isLoggedIn;
  String get userName => _userName;
  String get userBirthDate => _userBirthDate;
  int get points => _points;
  List<String> get coupons => _coupons;

  void login(String name, String birthDate) {
    _isLoggedIn = true;
    _userName = name;
    _userBirthDate = birthDate;
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    _userName = '';
    _userBirthDate = '';
    _points = 0;
    _coupons.clear();
    notifyListeners();
  }
}
