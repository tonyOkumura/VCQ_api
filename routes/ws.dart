import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_web_socket/dart_frog_web_socket.dart';
import 'package:vcq_models/models.dart';
import 'package:vka_api/src/repositories/message_repository.dart';
import 'package:vka_api/src/repositories/users_repository.dart';

// Маппинг userId на канал WebSocket, чтобы отслеживать подключение каждого пользователя
final Map<String, WebSocketChannel> activeUsers = {};

Future<Response> onRequest(RequestContext context) async {
  final messageRepository = context.read<MessageRepository>();
  final userRepository = context.read<UsersRepository>();

  final handler = webSocketHandler((channel, protocol) {
    String? userId;

    channel.stream.listen(
      (message) async {
        if (message is! String) {
          channel.sink.add(jsonEncode({
            'event': 'error',
            'data': {'message': 'Invalid message format'},
          }));
          return;
        }

        Map<String, dynamic> messageJson = jsonDecode(message);
        final event = messageJson['event'];
        final data = messageJson['data'];
        print('event: $event, data: $data');

        switch (event) {
          case 'user.connect':
            userId = data['user_id'];
            activeUsers[userId!] = channel;
            await userRepository.updateUserStatus(userId!, isOnline: true);
            print('User $userId is now online');
            break;

          case 'message.create':
            final newMessage = Message.fromJson(data);
            final createdMessage =
                await messageRepository.createMessage(newMessage);

            // Отправка сообщения только получателю, если он в сети
            final receiverChannel = activeUsers[newMessage.receiverUserId];
            if (receiverChannel != null) {
              receiverChannel.sink.add(jsonEncode({
                'event': 'message.created',
                'data': createdMessage.toJson(),
              }));
            }
            break;

          default:
            channel.sink.add(jsonEncode({
              'event': 'error',
              'data': {'message': 'Unknown event'},
            }));
        }
      },
      onDone: () async {
        // Удаляем пользователя из списка при отключении и обновляем статус
        if (userId != null) {
          activeUsers.remove(userId);
          await userRepository.updateUserStatus(userId!, isOnline: false);
          print('User $userId is now offline');
        }
      },
      onError: (error) {
        print('Error occurred: $error');
      },
    );
  });
  return handler(context);
}
