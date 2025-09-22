import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sajunara_app/providers/app_state.dart';
import 'package:sajunara_app/providers/store_state.dart';
import 'package:sajunara_app/screens/category/category_screen.dart';
import 'package:sajunara_app/screens/main/home_screen.dart';
import 'package:sajunara_app/screens/user/my_bookings_screen.dart';
import 'package:sajunara_app/screens/user/my_page_screen.dart';

// 메인 화면
class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    context.read<StoreState>().loadStores();

    return Scaffold(
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          switch (appState.currentIndex) {
            case 0:
              return HomeScreen();
            case 1:
              return CategoryScreen(category: '신점');
            case 2:
              return CategoryScreen(category: '타로');
            case 3:
              return CategoryScreen(category: '철학관');
            case 4:
              return MyBookingsScreen();
            case 5:
              return MyPageScreen();
            default:
              return HomeScreen();
          }
        },
      ),
      bottomNavigationBar: Consumer<AppState>(
        builder: (context, appState, child) {
          return BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: appState.currentIndex,
            onTap: (index) => appState.setCurrentIndex(index),
            selectedItemColor: Colors.indigo,
            unselectedItemColor: Colors.grey,
            items: [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
              BottomNavigationBarItem(icon: Icon(Icons.star), label: '신점'),
              BottomNavigationBarItem(
                icon: Icon(Icons.auto_awesome),
                label: '타로',
              ),
              BottomNavigationBarItem(icon: Icon(Icons.school), label: '철학관'),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today),
                label: '나의 예약',
              ),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: '내 정보'),
            ],
          );
        },
      ),
    );
  }
}
