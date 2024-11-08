import 'package:supabase/supabase.dart';
import 'package:vcq_models/models.dart';

class MessageRepository {
  final SupabaseClient dbClient;

  const MessageRepository({required this.dbClient});

  Future<Message> createMessage(Message message) async {
    try {
      // Сохраняем сообщение в базе данных
      final newMessage = message.copyWith(
        createdAt: DateTime.now(),
      );
      final response = await dbClient
          .from('messages')
          .insert(newMessage.toJson())
          .select()
          .single();

      final createdMessage = Message.fromJson(response);

      //Обновляем "последнее сообщение" в таблице chat_rooms для данной комнаты
      await dbClient.from('chat_rooms').update({
        'last_message_id': createdMessage.id,
        'created_at': createdMessage.createdAt != null
            ? createdMessage.createdAt?.toIso8601String()
            : DateTime.now().toIso8601String(),
      }).eq('id', message.chatRoomId);

      return createdMessage;
    } catch (err) {
      throw Exception('Failed to create and set last message: $err');
    }
  }

  // Функция для подгрузки сообщений с поддержкой пагинации
  Future<List<Message>> fetchMessagesWithPagination(
      {required String chatRoomId,
      required int limit,
      required int offset}) async {
    try {
      final response = await dbClient
          .from('messages')
          .select()
          .eq('chat_room_id', chatRoomId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1); // Определяем диапазон сообщений

      final List<Message> messages = response
          .map<Message>((message) => Message.fromJson(message))
          .toList();

      return messages;
    } catch (err) {
      throw Exception("Failed to fetch messages: $err");
    }
  }
}
