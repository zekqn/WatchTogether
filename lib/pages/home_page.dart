// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import '../services/websocket_service.dart';
import 'room_host_page.dart';
import 'rooms_page.dart';
import 'profile_page.dart';
import 'create_room_page.dart';

class HomePage extends StatefulWidget {
  final String username;
  const HomePage({super.key, required this.username});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      _HomeScreen(username: widget.username),
      RoomsPage(username: widget.username),
      CreateRoomPage(username: widget.username),
      ProfilePage(username: widget.username),
    ];

    return Scaffold(
      body: pages[index],
      bottomNavigationBar: NavigationBar(
        height: 70,
        indicatorColor: const Color(0xFF6C29FF),
        backgroundColor: const Color(0xFF161622),
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
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

class _HomeScreen extends StatelessWidget {
  final String username;
  const _HomeScreen({required this.username});

  @override
  Widget build(BuildContext context) {
    final ws = WebSocketService.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text("WatchTogether"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.play_circle_fill,
              size: 92,
              color: Color(0xFF6C29FF),
            ),
            const SizedBox(height: 16),
            Text("Привет, $username!", style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RoomsPage(username: username),
                ),
              ),
              icon: const Icon(Icons.people),
              label: const Text("Перейти в комнаты"),
            ),
          ],
        ),
      ),
    );
  }
}
