import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sajunara_app/screens/store/store_detail_screen.dart';
import 'providers/app_state.dart';
import 'providers/user_state.dart';
import 'providers/store_state.dart';
import 'screens/intro/intro_screen.dart';
import 'screens/main/main_screen.dart';
import 'screens/user/login_screen.dart';
import 'screens/booking/booking_screen.dart';
import 'screens/user/my_page_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
        ChangeNotifierProvider(create: (_) => UserState()),
        ChangeNotifierProvider(create: (_) => StoreState()),
      ],
      child: SajuNaraApp(),
    ),
  );
}

class SajuNaraApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '사주나라',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'NotoSans',
        scaffoldBackgroundColor: Colors.white,
      ),
      home: IntroScreen(),
      routes: {
        '/main': (context) => MainScreen(),
        '/login': (context) => LoginScreen(),
        '/store_detail': (context) => StoreDetailScreen(),
        '/booking': (context) => BookingScreen(),
        '/my_page': (context) => MyPageScreen(),
      },
    );
  }
}
