// lib/pages/room_host_page.dart
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../services/websocket_service.dart';

class RoomHostPage extends StatefulWidget {
  final WebSocketService channelService;
  final String username;
  final String roomId;
  final Map<String, dynamic> roomMeta;

  const RoomHostPage({
    super.key,
    required this.channelService,
    required this.username,
    required this.roomId,
    required this.roomMeta,
  });

  @override
  State<RoomHostPage> createState() => _RoomHostPageState();
}

class _RoomHostPageState extends State<RoomHostPage> {
  late YoutubePlayerController yt;
  final TextEditingController _msg = TextEditingController();
  final TextEditingController _videoInput = TextEditingController();

  List<Map<String, String>> chat = [];
  bool videoLoaded = false;

  @override
  void initState() {
    super.initState();

    String? initialVideo = widget.roomMeta["videoId"];
    yt = YoutubePlayerController(
      initialVideoId: initialVideo ?? "",
      flags: const YoutubePlayerFlags(autoPlay: false),
    );

    if (initialVideo != null) {
      videoLoaded = true;
    }

    widget.channelService.stream.listen((d) {
      if (!mounted) return;

      switch (d["type"]) {
        case "message":
          setState(() {
            chat.insert(0, {"user": d["username"], "text": d["text"]});
          });
          break;

        case "peer_joined":
          setState(() {
            chat.insert(0, {
              "user": "SYSTEM",
              "text": "${d['username']} вошёл в комнату",
            });
          });
          break;

        case "peer_left":
          setState(() {
            chat.insert(0, {
              "user": "SYSTEM",
              "text": "${d['username']} вышел",
            });
          });
          break;

        case "video_control":
          if (d["videoId"] != null) {
            yt.load(d["videoId"]);
            setState(() => videoLoaded = true);
          }
          break;
      }
    });
  }

  void sendMessage() {
    final text = _msg.text.trim();
    if (text.isEmpty) return;

    widget.channelService.send({
      "type": "message",
      "roomId": widget.roomId,
      "username": widget.username,
      "text": text,
    });

    setState(() {
      chat.insert(0, {"user": widget.username, "text": text});
    });

    _msg.clear();
  }

  void changeVideo() {
    final url = _videoInput.text.trim();
    if (url.isEmpty) return;

    final id = YoutubePlayer.convertUrlToId(url);
    if (id == null) return;

    widget.channelService.send({
      "type": "video_control",
      "roomId": widget.roomId,
      "action": "load",
      "videoId": id,
    });

    yt.load(id);
    videoLoaded = true;
    setState(() {});
  }

  void leaveRoom() {
    widget.channelService.send({
      "type": "leave_room",
      "roomId": widget.roomId,
      "username": widget.username,
    });

    Navigator.pop(context);
  }

  @override
  void dispose() {
    yt.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.roomMeta['name'] ?? "Комната"),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.exit_to_app), onPressed: leaveRoom),
        ],
      ),

      body: Column(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            child: videoLoaded
                ? YoutubePlayer(controller: yt)
                : Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        TextField(
                          controller: _videoInput,
                          decoration: const InputDecoration(
                            hintText: "Ссылка на видео",
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: changeVideo,
                          child: const Text("Загрузить видео"),
                        ),
                      ],
                    ),
                  ),
          ),

          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: chat.length,
              itemBuilder: (_, i) {
                final m = chat[i];
                return ListTile(
                  title: Text(m["user"]!),
                  subtitle: Text(m["text"]!),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msg,
                    decoration: const InputDecoration(hintText: "Сообщение..."),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
