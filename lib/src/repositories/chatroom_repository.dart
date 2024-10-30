import 'package:supabase/supabase.dart' as supabase;
import 'package:vcq_models/src/chat_room.dart';

class ChatroomRepository {
  final supabase.SupabaseClient dbClient;

  const ChatroomRepository({required this.dbClient});

  Future<List<Map<String, dynamic>>> getAllChatRooms() async {
    try {
      final List<dynamic> response = await dbClient.from('chat_rooms').select();
      return response.cast<Map<String, dynamic>>();
    } catch (err) {
      print('Error retrieving chat rooms: $err');
      return [];
    }
  }

  Future<List<dynamic>> getParticipantsByChatRoomID(String chatRoomID) async {
    try {
      final response = await dbClient
          .from('chat_rooms_id')
          .select('participant_id')
          .eq('chat_room_id', chatRoomID);
      return response.map((item) => item['participant_id']).toList();
    } catch (err) {
      print('Error retrieving participants: $err');
      return [];
    }
  }

  Future<List<dynamic>> getChatRoomsByParticipantID(
      String participantID) async {
    try {
      final response = await dbClient
          .from('chat_rooms_id')
          .select('chat_room_id')
          .eq('participant_id', participantID);
      return response.map((item) => item['chat_room_id']).toList();
    } catch (err) {
      print('Error retrieving chat rooms by participant ID: $err');
      return [];
    }
  }

  Future<ChatRoom?> createChatRoom(ChatRoom chatRoom) async {
    try {
      final List<String?> participantIds =
          chatRoom.participants.map((p) => p.id).toList();

      // Получаем все комнаты для первого участника
      final firstParticipantChatRooms =
          await getChatRoomsByParticipantID(participantIds[0]!);

      // Проверяем, содержат ли остальные участники хотя бы одну общую комнату
      bool roomExists = true;
      for (var i = 1; i < participantIds.length; i++) {
        final participantChatRooms =
            await getChatRoomsByParticipantID(participantIds[i]!);
        roomExists = roomExists &&
            firstParticipantChatRooms.any(participantChatRooms.contains);

        if (!roomExists) break;
      }

      if (roomExists) {
        print('Chat room already exists with these participants');
        return chatRoom;
      }

      // Если комната не найдена, создаем новую
      await dbClient.from('chat_rooms').insert({'id': chatRoom.id});

      for (final participant in chatRoom.participants) {
        await dbClient.from('chat_rooms_id').insert({
          'chat_room_id': chatRoom.id,
          'participant_id': participant.id,
        });
      }

      print('Chat room created successfully');
      return chatRoom;
    } catch (err) {
      print('Error creating chat room: $err');
      return null;
    }
  }
}
