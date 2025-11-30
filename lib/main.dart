import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sajunara_app/models/booking.dart';
import 'package:sajunara_app/models/store.dart';
import 'package:sajunara_app/screens/event/event_screen.dart';
import 'package:sajunara_app/screens/store/store_detail_screen.dart';
import 'package:sajunara_app/screens/booking/my_bookings_screen.dart';
import 'package:sajunara_app/screens/user/profile_edit_screen.dart';
import 'providers/app_state.dart';
import 'providers/user_state.dart';
import 'providers/store_state.dart';
import 'screens/intro/intro_screen.dart';
import 'screens/main/main_screen.dart';
import 'screens/login/login_screen.dart';
import 'screens/booking/booking_screen.dart';
import 'screens/mypage/my_page_screen.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

void main() {
  KakaoSdk.init(nativeAppKey: '13f34ed6d5d0e471eaa120673077d50d');
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
  const SajuNaraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '무물',
      theme: ThemeData(primarySwatch: Colors.blueGrey, fontFamily: 'NotoSans', scaffoldBackgroundColor: Colors.white),
      home: IntroScreen(),
      routes: {
        '/main': (context) => MainScreen(),
        '/login': (context) => LoginScreen(),
        '/store_detail': (context) {
          final store = ModalRoute.of(context)!.settings.arguments as Store;
          return StoreDetailScreen(store: store);
        },
        '/booking': (context) {
          final booking = ModalRoute.of(context)!.settings.arguments as Booking;
          return BookingScreen(booking: booking);
        },
        '/my_page': (context) => MyPageScreen(),
        '/event': (context) => EventScreen(),
        '/my_booking': (context) => MyBookingsScreen(),
        '/profile_edit': (context) => ProfileEditScreen(),
      },
    );
  }
}
