class RoomInfo {
  final String id;
  final String name;
  final bool isPrivate;
  final int participants;
  final String? videoId;

  RoomInfo({
    required this.id,
    required this.name,
    required this.isPrivate,
    required this.participants,
    this.videoId,
  });

  factory RoomInfo.fromJson(Map<String, dynamic> json) => RoomInfo(
    id: json["id"],
    name: json["name"],
    isPrivate: json["isPrivate"] ?? false,
    participants: json["participants"] ?? 0,
    videoId: json["videoId"],
  );
}
