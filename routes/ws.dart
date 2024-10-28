import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_web_socket/dart_frog_web_socket.dart';
import 'package:vka_api/src/repositories/message_repository.dart';

// Хранит список подключенных клиентов
final List<WebSocketChannel> clients = [];

Future<Response> onRequest(RequestContext context) async {
  final messageRepository = context.read<MessageRepository>();
  final handler = webSocketHandler((channel, protocol) {
    // Добавляем клиента в список подключенных
    clients.add(channel);
    print('Clients connected: ${clients.length}');

    // Слушаем входящие сообщения
    channel.stream.listen(
      (message) {
        if (message is! String) {
          channel.sink.add('Invalid message');
          return;
        }

        Map<String, dynamic> messageJson = jsonDecode(message);
        final event = messageJson['event'];
        final data = messageJson['data'];
        print('event: $event, data: $data');

        switch (event) {
          case 'message.create':
            messageRepository.createMessage(data).then((message) {
              // Рассылаем сообщение всем подключенным клиентам
              for (final client in clients) {
                client.sink.add(jsonEncode({
                  'event': 'message.created',
                  'data': message,
                }));
              }
            }).catchError((err) {
              print('Something went wrong: $err');
            });
            break;
          default:
            channel.sink.add('Unknown event');
        }
      },
      onDone: () {
        // Удаляем клиента из списка при закрытии соединения
        clients.remove(channel);
        print('Client disconnected. Remaining clients: ${clients.length}');
      },
      onError: (error) {
        print('Error occurred: $error');
      },
    );
  });
  return handler(context);
}
