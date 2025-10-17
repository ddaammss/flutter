import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:sajunara_app/providers/app_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart'; // ✅ 추가

// 인트로 화면
class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  late PageController _pageController;
  List<Widget> _pages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    //await _clearAllData(); // ⚠️ 테스트 후 주석 처리할 것!
    // if (kDebugMode) {
    //   await _checkAllPermissions();
    // }
    await _initializePages();
  }

  Future<void> _clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    //print('✅ SharedPreferences 초기화 완료');
  }

  Future<void> _checkAllPermissions() async {
    if (!kDebugMode) return; // ⬅️ 추가!
    final prefs = await SharedPreferences.getInstance();

    print('========== 권한 상태 확인 ==========');

    // SharedPreferences 체크
    print('📱 앱 내부 저장 데이터:');
    print('  - 첫 실행: ${prefs.getBool('is_first_run') ?? true}');
    print('  - 알림 물어봄: ${prefs.getBool('has_asked_notification') ?? false}');
    print('  - 개인정보 동의: ${prefs.getBool('personal_info_agreed') ?? false}');
    print('  - 위치 물어봄: ${prefs.getBool('has_asked_location') ?? false}');

    // 시스템 위치 권한 체크
    LocationPermission permission = await Geolocator.checkPermission();
    print('\n📍 시스템 위치 권한:');
    print('  - 상태: $permission');

    switch (permission) {
      case LocationPermission.denied:
        print('  - 설명: 아직 안 물어봄');
        break;
      case LocationPermission.deniedForever:
        print('  - 설명: 영구 거부됨');
        break;
      case LocationPermission.whileInUse:
        print('  - 설명: 앱 사용 중 허용됨 ✅');
        break;
      case LocationPermission.always:
        print('  - 설명: 항상 허용됨 ✅');
        break;
      default:
        print('  - 설명: 알 수 없음');
    }

    print('===================================');
  }

  Future<void> _initializePages() async {
    List<Widget> pages = [];

    final prefs = await SharedPreferences.getInstance();
    bool isFirstRun = prefs.getBool('is_first_run') ?? true;

    // 1. 첫 실행이면 인트로 페이지 추가
    if (isFirstRun) {
      pages.add(_buildIntroPage());
    }

    // 2. 알림 권한 체크 (수정됨)
    bool hasAskedNotification = prefs.getBool('has_asked_notification') ?? false;
    if (!hasAskedNotification) {
      pages.add(_buildNotificationPermissionPage());
    }

    // 3. 개인정보 동의 체크
    bool hasPersonalInfoAgreed = prefs.getBool('personal_info_agreed') ?? false;
    if (!hasPersonalInfoAgreed) {
      pages.add(_buildPersonalInfoPermissionPage());
    }

    // 4. 위치 권한 체크 (수정됨)
    bool hasAskedLocation = prefs.getBool('has_asked_location') ?? false;
    if (!hasAskedLocation) {
      pages.add(_buildLocationPermissionPage());
    }

    setState(() {
      _pages = pages;
      _isLoading = false;
      _pageController = PageController();
    });

    // 모든 권한이 이미 있으면 바로 메인으로
    if (pages.isEmpty) {
      await Future.delayed(Duration(milliseconds: 500));
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/main');
      }
    }

    // 첫 실행 플래그 저장
    if (isFirstRun) {
      await prefs.setBool('is_first_run', false);
    }
  }

  void _goToNextPageOrMain() {
    if (_pageController.page! < _pages.length - 1) {
      _pageController.nextPage(duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      Navigator.pushReplacementNamed(context, '/main');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Container(
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
                  '무물',
                  style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'serif'),
                ),
                SizedBox(height: 20),
                CircularProgressIndicator(color: Colors.white),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: PageView(controller: _pageController, physics: NeverScrollableScrollPhysics(), children: _pages),
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
              '무물',
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'serif'),
            ),
            SizedBox(height: 20),
            Text('운명을 만나는 특별한 공간', style: TextStyle(fontSize: 18, color: Colors.white70)),
            SizedBox(height: 100),
            ElevatedButton(
              onPressed: _goToNextPageOrMain,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.indigo[900],
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: Text('시작하1111기'),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ 알림 권한 - 시스템 권한 요청 추가
  Widget _buildNotificationPermissionPage() {
    return _buildPermissionPage(
      title: '알림 허용',
      description: '예약 확정 및 중요한 소식을 받으시겠습니까?',
      icon: Icons.notifications,
      onAllow: () async {
        final prefs = await SharedPreferences.getInstance();

        // ✅ 시스템 알림 권한 요청
        PermissionStatus status = await Permission.notification.request();
        bool granted = status.isGranted;

        print('권한 받았는지 확인: $granted');

        // SharedPreferences에 기록
        await prefs.setBool('notification_permission', granted);
        await prefs.setBool('has_asked_notification', true);

        if (!mounted) return;

        context.read<AppState>().setNotificationPermission(granted);
        _goToNextPageOrMain();
      },
      onDeny: () async {
        final prefs = await SharedPreferences.getInstance();

        // 거부 시에도 물어봤다고 기록
        await prefs.setBool('notification_permission', false);
        await prefs.setBool('has_asked_notification', true);

        if (!mounted) return;

        context.read<AppState>().setNotificationPermission(false);
        _goToNextPageOrMain();
      },
    );
  }

  // ✅ 개인정보 동의 - 거부 시 앱 종료
  Widget _buildPersonalInfoPermissionPage() {
    return _buildPermissionPage(
      title: '개인정보 이용 허용 (필수)',
      description: '서비스 이용을 위해 개인정보 수집에 동의하시겠습니까?\n\n※ 필수 동의 항목입니다.',
      icon: Icons.person,
      onAllow: () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('personal_info_agreed', true);

        if (!mounted) return;

        _goToNextPageOrMain();
      },
      onDeny: () async {
        if (!mounted) return;

        // ✅ 거부 시 다이얼로그 표시
        bool? retry = await showDialog<bool>(
          context: context,
          barrierDismissible: false, // 바깥 터치로 닫기 방지
          builder: (context) => AlertDialog(
            title: Text('서비스 이용 불가'),
            content: Text(
              '개인정보 수집 및 이용 동의는 서비스 이용을 위한 필수 항목입니다.\n\n'
              '동의하지 않으시면 서비스를 이용하실 수 없습니다.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: Text('앱 종료'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: Text('다시 보기'),
              ),
            ],
          ),
        );

        if (retry == true) {
          // 다시 보기 선택 시 - 현재 페이지에 머물러있음
          return;
        } else {
          // 앱 종료
          SystemNavigator.pop();
        }
      },
    );
  }

  // ✅ 위치 권한 - 시스템 권한 요청 (기존과 동일)
  Widget _buildLocationPermissionPage() {
    return _buildPermissionPage(
      title: '위치정보 이용 허용',
      description: '내 주변 추천 서비스를 위해 위치정보를 사용하시겠습니까?',
      icon: Icons.location_on,
      onAllow: () async {
        final prefs = await SharedPreferences.getInstance();

        // ✅ 시스템 위치 권한 요청
        bool granted = await _requestLocationPermission();

        // SharedPreferences에 기록
        await prefs.setBool('has_asked_location', true);

        if (!mounted) return;

        context.read<AppState>().setLocationPermission(granted);
        _goToNextPageOrMain();
      },
      onDeny: () async {
        final prefs = await SharedPreferences.getInstance();

        // 거부 시에도 물어봤다고 기록
        await prefs.setBool('has_asked_location', true);

        if (!mounted) return;

        context.read<AppState>().setLocationPermission(false);
        _goToNextPageOrMain();
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
            textAlign: TextAlign.center,
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
              ElevatedButton(
                onPressed: onDeny,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  backgroundColor: Colors.white,
                ),
                child: Text('건너뛰기', style: TextStyle(color: Colors.black)),
              ),
              ElevatedButton(
                onPressed: onAllow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                child: Text('허용', style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ✅ 시스템 위치 권한 요청 함수
  Future<bool> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission != LocationPermission.denied && permission != LocationPermission.deniedForever;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
