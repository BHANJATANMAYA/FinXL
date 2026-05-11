import 'package:equatable/equatable.dart';

class DetectedSmsMessage extends Equatable {
  const DetectedSmsMessage({
    required this.body,
    required this.receivedAt,
    this.sender,
  });

  final String body;
  final DateTime receivedAt;
  final String? sender;

  factory DetectedSmsMessage.fromMap(Map<Object?, Object?> map) {
    final timestamp = map['timestamp'];
    return DetectedSmsMessage(
      body: (map['body'] as String?) ?? '',
      sender: map['sender'] as String?,
      receivedAt: timestamp is int
          ? DateTime.fromMillisecondsSinceEpoch(timestamp)
          : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [body, sender, receivedAt];
}
