// lib/main.dart
import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/rooms_page.dart';
import 'pages/create_room_page.dart';
import 'pages/profile_page.dart';
import 'services/websocket_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Подключаем WebSocket один раз сразу при старте
  // Замените на ваш URL (wss://... или ws://...)
  WebSocketService.instance.connect('wss://watchtogetger-server.onrender.com');
  runApp(const AppRoot());
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WatchTogether',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: const Color(0xFF6C29FF),
        scaffoldBackgroundColor: const Color(0xFF0F0F19),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1C1C2A),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int index = 0;
  String username = "User${DateTime.now().millisecondsSinceEpoch % 10000}";

  @override
  void initState() {
    super.initState();
    // загрузим локально сохранённый ник (если есть)
    WebSocketService.instance.loadSavedNickname().then((saved) {
      if (saved != null && saved.isNotEmpty) {
        setState(() => username = saved);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(username: username),
      RoomsPage(username: username),
      CreateRoomPage(username: username),
      ProfilePage(
        initialNickname: username,
        onNickUpdated: (newNick) => setState(() => username = newNick),
      ),
    ];
    return Scaffold(
      body: pages[index],
      bottomNavigationBar: NavigationBar(
        height: 70,
        backgroundColor: const Color(0xFF161622),
        indicatorColor: const Color(0xFF6C29FF),
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.play_circle_outline),
            label: "Главная",
          ),
          NavigationDestination(
            icon: Icon(Icons.people_alt_outlined),
            label: "Комнаты",
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            label: "Создать",
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: "Профиль",
          ),
        ],
      ),
    );
  }
}
