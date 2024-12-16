import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter7/pages/home_page.dart';
import 'package:flutter7/pages/cart_page.dart';
import 'package:flutter7/pages/profile_page.dart';
import 'package:flutter7/models/cart.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => Cart(), // Инициализация Cart
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            titleTextStyle: TextStyle(
              color: Colors.black,
              fontSize: 20,
            ),
          ),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Colors.black),
            bodyMedium: TextStyle(color: Colors.black87),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Colors.white,
            selectedItemColor: Colors.blueAccent,
            unselectedItemColor: Colors.grey,
          ),
        ),
        home: MainPage(),
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = <Widget>[
    HomePage(),
    CartPage(),
    ProfilePage(),

  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/Home.png',
              width: 24,
              height: 24,
              color: _selectedIndex == 0 ? Colors.blueAccent : Colors.grey,
            ),
            label: 'Главная',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/Cart.png',
              width: 24,
              height: 24,
              color: _selectedIndex == 1 ? Colors.blueAccent : Colors.grey,
            ),
            label: 'Корзина',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/User.png',
              width: 24,
              height: 24,
              color: _selectedIndex == 2 ? Colors.blueAccent : Colors.grey,
            ),
            label: 'Профиль',
          ),
        ],
      ),
    );
  }
}