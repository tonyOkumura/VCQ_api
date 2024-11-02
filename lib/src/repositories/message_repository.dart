import 'package:supabase/supabase.dart';
import 'package:vcq_models/models.dart';

class MessageRepository {
  final SupabaseClient dbClient;

  const MessageRepository({required this.dbClient});

  Future<Map<String, dynamic>> createMessage(Message message) async {
    try {
      return await dbClient.from('messages').insert(message.toJson());
    } catch (err) {
      throw Exception(err);
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
