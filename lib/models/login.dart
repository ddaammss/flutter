import 'package:flutter_naver_login/interface/types/naver_account_result.dart';

class Login {
  final String? id;
  final String? email;
  final String? name;
  final String? nickname;
  final String? profileImage;
  final String? age;
  final String? birthday;
  final String? birthYear;
  final String? gender;
  final String? phone;

  Login({
    this.id,
    this.email,
    this.name,
    this.nickname,
    this.profileImage,
    this.age,
    this.birthday,
    this.birthYear,
    this.gender,
    this.phone,
  });

  // JSON으로 변환 (API 서버로 보낼 때)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'nickname': nickname,
      'profileImage': profileImage,
      'age': age,
      'birthday': birthday,
      'birthYear': birthYear,
      'gender': gender,
      'phone': phone,
    };
  }

  // JSON에서 객체 생성 (API 서버 응답 받을 때)
  factory Login.fromJson(Map<String, dynamic> json) {
    return Login(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      nickname: json['nickname'],
      profileImage: json['profileImage'],
      age: json['age'],
      birthday: json['birthday'],
      birthYear: json['birthYear'],
      gender: json['gender'],
      phone: json['phone'],
    );
  }

  factory Login.fromLoginAccount(NaverAccountResult account) {
    return Login(
      id: account.id,
      email: account.email,
      name: account.name,
      nickname: account.nickname,
      profileImage: account.profileImage,
      age: account.age,
      birthday: account.birthday,
      birthYear: account.birthYear,
      gender: account.gender,
      phone: account.mobile,
    );
  }
}
