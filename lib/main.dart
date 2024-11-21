import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/premium_screen.dart';
import 'screens/profile_screen.dart';
import 'package:provider/provider.dart';
import 'providers/navigation_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => NavigationState(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Perio->Do Buy',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      home: const MainScreen(), // HomeScreenからMainScreenに変更
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // 表示する画面のリスト
  final List<Widget> _screens = [
    const HomeScreen(), // 既存のHomeScreen
    const PremiumScreen(), // 新規作成必要
    const ProfileScreen(), // 新規作成必要
  ];

  @override
  Widget build(BuildContext context) {
    final navigationState = context.watch<NavigationState>();

    return Scaffold(
      body: _screens[navigationState.selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: '購入リスト',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.diamond_outlined),
            label: '商品リスト',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'プロフィール',
          ),
        ],
        currentIndex: navigationState.selectedIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          context.read<NavigationState>().setIndex(index);
        },
      ),
    );
  }
}
