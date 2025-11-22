// lib/pages/profile_page.dart
import 'package:flutter/material.dart';
import '../services/websocket_service.dart';

class ProfilePage extends StatefulWidget {
  final String initialNickname;
  final ValueChanged<String> onNickUpdated;
  const ProfilePage({
    super.key,
    required this.initialNickname,
    required this.onNickUpdated,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ws = WebSocketService.instance;
  late String nickname;

  @override
  void initState() {
    super.initState();
    nickname = widget.initialNickname;
  }

  Future<void> _editNick() async {
    final ctrl = TextEditingController(text: nickname);
    final res = await showDialog<String?>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Изменить ник'),
          content: TextField(controller: ctrl),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, ctrl.text.trim()),
              child: const Text('Сохранить'),
            ),
          ],
        );
      },
    );
    if (res == null) return;
    setState(() => nickname = res);
    // Сохраняем локально и уведомляем сервер
    await ws.saveNickname(res);
    widget.onNickUpdated(res);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Ник сохранён')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Профиль'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: const Color(0xFF6C29FF),
              child: Text(
                nickname.isNotEmpty ? nickname[0].toUpperCase() : '?',
                style: const TextStyle(fontSize: 24),
              ),
            ),
            const SizedBox(height: 12),
            Text(nickname, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _editNick,
              icon: const Icon(Icons.edit),
              label: const Text('Изменить ник'),
            ),
          ],
        ),
      ),
    );
  }
}
