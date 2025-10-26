import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sajunara_app/models/store.dart';
import 'package:sajunara_app/screens/event/event_screen.dart';
import 'package:sajunara_app/screens/store/store_detail_screen.dart';
import 'providers/app_state.dart';
import 'providers/user_state.dart';
import 'providers/store_state.dart';
import 'screens/intro/intro_screen.dart';
import 'screens/main/_main_screen.dart';
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
        '/booking': (context) => BookingScreen(),
        '/my_page': (context) => MyPageScreen(),
        '/event': (context) => EventScreen(),
      },
    );
  }
}
