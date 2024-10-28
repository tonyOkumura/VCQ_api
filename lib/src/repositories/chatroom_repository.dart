import 'package:supabase/supabase.dart' as supabase;
import 'package:vcq_models/src/chat_room.dart';

class ChatroomRepository {
  final supabase.SupabaseClient dbClient;

  const ChatroomRepository({required this.dbClient});

  Future<List<Map<String, dynamic>>> getAllChatRooms() async {
    try {
      // Выполняем запрос на получение всех пользователей
      final List<dynamic> response = await dbClient.from('chat_rooms').select();

      final chatrooms = response.cast<Map<String, dynamic>>();

      return chatrooms;
    } catch (err) {
      // В случае ошибки возвращаем пустой список
      print('Что-то пошло не так: $err');
      return [];
    }
  }

  Future<List<dynamic>> getParticipantsByChatRoomID(
    String chatRoomID,
  ) async {
    try {
      // Выполняем запрос на получение всех пользователей
      final response = await dbClient
          .from('chat_rooms_id')
          .select('participant_id')
          .eq('chat_room_id', chatRoomID);

      final participantIds =
          response.map((item) => item['participant_id']).toList();

      print(participantIds);

      return participantIds;
    } catch (err) {
      // В случае ошибки возвращаем пустой список
      print('Что-то пошло не так: $err');
      return [];
    }
  }

  Future<List<dynamic>> getChatRoomsByParticipantID(
    String participantID,
  ) async {
    try {
      // Выполняем запрос на получение всех пользователей
      final response = await dbClient
          .from('chat_rooms_id')
          .select('chat_room_id')
          .eq('participant_id', participantID);

      final chatRoomIds = response.map((item) => item['chat_room_id']).toList();

      print(chatRoomIds);

      return chatRoomIds;
    } catch (err) {
      // В случае ошибки возвращаем пустой список
      print('Что-то пошло не так: $err');
      return [];
    }
  }

  createChatRoom(
    ChatRoom chatRoom,
  ) async {
    try {
      await dbClient.from('chat_rooms').insert({
        'id': chatRoom.id,
      });

      chatRoom.participants.forEach((p) async {
        await dbClient.from('chat_rooms_id').insert({
          'chat_room_id': chatRoom.id,
          'participant_id': p.id,
        });
      });
    } catch (err) {
      print('Что-то пошло не так: $err');
    }
  }
}
