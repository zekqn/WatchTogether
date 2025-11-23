// lib/pages/rooms_page.dart
import 'package:flutter/material.dart';
import '../services/websocket_service.dart';
import 'create_room_page.dart';
import 'room_host_page.dart';
import 'dart:async';

class RoomsPage extends StatefulWidget {
  final String username;
  const RoomsPage({super.key, required this.username});

  @override
  State<RoomsPage> createState() => _RoomsPageState();
}

class _RoomsPageState extends State<RoomsPage> {
  final ws = WebSocketService.instance;
  List<Map<String, dynamic>> rooms = [];
  StreamSubscription? _wsSub;

  @override
  void initState() {
    super.initState();
    _wsSub = ws.stream.listen((d) {
      if (d['type'] == 'rooms_list') {
        setState(
          () => rooms = List<Map<String, dynamic>>.from(d['rooms'] ?? []),
        );
      } else if (d['type'] == 'enter_ok') {
        final rid = d['roomId'];
        final meta = Map<String, dynamic>.from(d['roomMeta'] ?? {});
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RoomHostPage(
              channelService: ws,
              username: widget.username,
              roomId: rid,
              roomMeta: meta,
            ),
          ),
        );
      } else if (d['type'] == 'error') {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Ошибка: ${d['reason']}')));
      } else if (d['type'] == 'room_created') {
        // optional: immediately refresh rooms list
        Future.delayed(const Duration(milliseconds: 50), _requestRooms);
      }
    });
    Future.delayed(const Duration(milliseconds: 200), _requestRooms);
  }

  @override
  void dispose() {
    try {
      _wsSub?.cancel();
    } catch (_) {}
    super.dispose();
  }

  void _requestRooms() => ws.send({'type': 'list_rooms'});

  void _enterRoom(Map<String, dynamic> room) async {
    if (room['isPrivate'] == true) {
      final pass = await showDialog<String?>(
        context: context,
        builder: (_) {
          final ctrl = TextEditingController();
          return AlertDialog(
            title: Text('Пароль для ${room['name']}'),
            content: TextField(controller: ctrl, obscureText: true),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, null),
                child: const Text('Отмена'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, ctrl.text.trim()),
                child: const Text('Войти'),
              ),
            ],
          );
        },
      );
      if (pass == null) return;
      ws.send({
        'type': 'enter_room',
        'roomId': room['id'],
        'username': widget.username,
        'password': pass,
      });
    } else {
      ws.send({
        'type': 'enter_room',
        'roomId': room['id'],
        'username': widget.username,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Комнаты'),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _requestRooms),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CreateRoomPage(username: widget.username),
                ),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Создать комнату'),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => _requestRooms(),
                child: ListView.builder(
                  itemCount: rooms.length,
                  itemBuilder: (_, i) {
                    final r = rooms[i];
                    return Card(
                      color: const Color(0xFF12121A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: Text(r['name'] ?? r['id']),
                        subtitle: Text(
                          'Участников: ${r['participants'] ?? 0} ${r['isPrivate'] ? '• Приват' : ''}',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _enterRoom(r),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
