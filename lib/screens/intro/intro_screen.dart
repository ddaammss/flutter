import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:sajunara_app/providers/app_state.dart';

// 인트로 화면
class IntroScreen extends StatefulWidget {
  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        children: [
          _buildIntroPage(),
          _buildNotificationPermissionPage(),
          _buildPersonalInfoPermissionPage(),
          _buildLocationPermissionPage(),
        ],
      ),
    );
  }

  Widget _buildIntroPage() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.indigo[900]!, Colors.indigo[600]!],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '사주나라',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'serif',
              ),
            ),
            SizedBox(height: 20),
            Text(
              '운명을 만나는 특별한 공간',
              style: TextStyle(fontSize: 18, color: Colors.white70),
            ),
            SizedBox(height: 100),
            ElevatedButton(
              onPressed: () {
                _pageController.nextPage(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: Text('시작하기'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.indigo[900],
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationPermissionPage() {
    return _buildPermissionPage(
      title: '알림 허용',
      description: '예약 확정 및 중요한 소식을 받으시겠습니까?',
      icon: Icons.notifications,
      onAllow: () {
        context.read<AppState>().setNotificationPermission(true);
        _pageController.nextPage(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      onDeny: () {
        context.read<AppState>().setNotificationPermission(false);
        _pageController.nextPage(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
    );
  }

  Widget _buildPersonalInfoPermissionPage() {
    return _buildPermissionPage(
      title: '개인정보 이용 허용',
      description: '서비스 이용을 위해 개인정보 수집에 동의하시겠습니까?',
      icon: Icons.person,
      onAllow: () {
        _pageController.nextPage(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      onDeny: () {
        _pageController.nextPage(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
    );
  }

  Widget _buildLocationPermissionPage() {
    return _buildPermissionPage(
      title: '위치정보 이용 허용',
      description: '내 주변 추천 서비스를 위해 위치정보를 사용하시겠습니까?',
      icon: Icons.location_on,
      onAllow: () async {
        bool granted = await _requestLocationPermission();
        context.read<AppState>().setLocationPermission(granted);
        Navigator.pushReplacementNamed(context, '/main');
      },
      onDeny: () {
        context.read<AppState>().setLocationPermission(false);
        Navigator.pushReplacementNamed(context, '/main');
      },
    );
  }

  Widget _buildPermissionPage({
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onAllow,
    required VoidCallback onDeny,
  }) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.indigo),
          SizedBox(height: 30),
          Text(
            title,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          SizedBox(height: 50),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              OutlinedButton(
                onPressed: onDeny,
                child: Text('거부'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
              ),
              ElevatedButton(
                onPressed: onAllow,
                child: Text('허용'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<bool> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission != LocationPermission.denied;
  }
}
