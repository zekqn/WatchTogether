// lib/pages/create_room_page.dart
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../services/websocket_service.dart';

class CreateRoomPage extends StatefulWidget {
  final String username;
  const CreateRoomPage({super.key, required this.username});

  @override
  State<CreateRoomPage> createState() => _CreateRoomPageState();
}

class _CreateRoomPageState extends State<CreateRoomPage> {
  final nameCtrl = TextEditingController();
  final videoCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool isPrivate = false;
  bool creating = false;
  final ws = WebSocketService.instance;

  void _createRoom() {
    final name = nameCtrl.text.trim();
    if (name.isEmpty) return;
    final videoUrl = videoCtrl.text.trim();
    final videoId = videoUrl.isEmpty
        ? null
        : YoutubePlayer.convertUrlToId(videoUrl) ?? videoUrl;
    final payload = {
      'type': 'create_room',
      'name': name,
      'isPrivate': isPrivate,
      'password': isPrivate ? passCtrl.text.trim() : null,
      'videoId': videoId,
      'creator': widget.username,
    };
    setState(() => creating = true);
    ws.send(payload);
    Future.delayed(const Duration(milliseconds: 350), () {
      setState(() => creating = false);
      Navigator.pop(context);
    });
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    videoCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Создать комнату'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Название комнаты'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: videoCtrl,
              decoration: const InputDecoration(
                labelText: 'Ссылка на YouTube (опционально)',
              ),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Приватная (пароль)'),
              value: isPrivate,
              onChanged: (v) => setState(() => isPrivate = v),
            ),
            if (isPrivate)
              TextField(
                controller: passCtrl,
                decoration: const InputDecoration(labelText: 'Пароль'),
                obscureText: true,
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: creating ? null : _createRoom,
              child: creating
                  ? const Text('Создаём...')
                  : const Text('Создать'),
            ),
          ],
        ),
      ),
    );
  }
}
