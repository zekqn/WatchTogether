// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import '../services/websocket_service.dart';
import 'package:watchtogether/pages/rooms_page.dart';
import 'package:watchtogether/pages/create_room_page.dart';
import 'package:watchtogether/pages/profile_page.dart';
import 'main_welcome_page.dart';

class HomePage extends StatefulWidget {
  final String initialNickname;
  const HomePage({super.key, required this.initialNickname});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late String nickname;

  int pageIndex = 0;

  @override
  void initState() {
    super.initState();
    nickname = widget.initialNickname;
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const MainWelcomePage(),
      RoomsPage(username: nickname),
      CreateRoomPage(username: nickname),
      ProfilePage(
        initialNickname: nickname,
        onNickUpdated: (newNick) {
          setState(() => nickname = newNick);
        },
      ),
    ];

    return Scaffold(
      body: pages[pageIndex],
      bottomNavigationBar: NavigationBar(
        height: 70,
        backgroundColor: const Color(0xFF161622),
        indicatorColor: const Color(0xFF6C29FF),
        selectedIndex: pageIndex,
        onDestinationSelected: (i) => setState(() => pageIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
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
