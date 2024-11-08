import 'package:supabase/supabase.dart' as supabase;
import 'package:vcq_models/models.dart';
import 'package:vcq_models/src/chat_room.dart';
import 'package:vka_api/src/repositories/users_repository.dart';
import 'package:vka_api/src/repositories/message_repository.dart';

class ChatroomRepository {
  final supabase.SupabaseClient dbClient;
  final MessageRepository messageRepository;

  ChatroomRepository({
    required this.dbClient,
    required this.messageRepository,
  });

  Future<List<Map<String, dynamic>>> _getAllChatRooms() async {
    try {
      final List<dynamic> response = await dbClient.from('chat_rooms').select();
      return response.cast<Map<String, dynamic>>();
    } catch (err) {
      print('Error retrieving chat rooms: $err');
      return [];
    }
  }

  Future<List<dynamic>> _getParticipantsIdsByChatRoomID(
      String chatRoomID) async {
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

  Future<List<dynamic>> _getChatRoomsIdsByParticipantID(
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
          await _getChatRoomsIdsByParticipantID(participantIds[0]!);

      // Проверяем, содержат ли остальные участники хотя бы одну общую комнату
      bool roomExists = true;
      for (var i = 1; i < participantIds.length; i++) {
        final participantChatRooms =
            await _getChatRoomsIdsByParticipantID(participantIds[i]!);
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

      return chatRoom;
    } catch (err) {
      print('Произошла ошибка при создании комнаты: $err');
      return null;
    }
  }

  Future<List<ChatRoom>> getChatRoomsByParticipantID(
      String participantID) async {
    try {
      final chatRoomsIds = await _getChatRoomsIdsByParticipantID(participantID);
      final chatRooms = <ChatRoom>[];
      for (final chatRoomId in chatRoomsIds) {
        final chatRoom = await _getChatRoomById(
          chatRoomId: chatRoomId!,
        );
        if (chatRoom != null) {
          chatRooms.add(chatRoom);
        }
      }
      return chatRooms;
    } catch (err) {
      print('Error retrieving chat rooms by participant ID: $err');
      return [];
    }
  }

  Future<ChatRoom?> _getChatRoomById({
    required String chatRoomId,
  }) async {
    ChatRoom? chatRoom;
    final participants = <User>[];

    final usersRepository = UsersRepository(dbClient: dbClient);

    final participantIds = await _getParticipantsIdsByChatRoomID(chatRoomId);

    for (final participantId in participantIds) {
      final user = await usersRepository.findUserById(participantId);

      if (user.isNotEmpty) {
        participants.add(User.fromJson(user));
      }
    }

    try {
      final lastMessages = await messageRepository.fetchMessagesWithPagination(
        chatRoomId: chatRoomId,
        limit: 1,
        offset: 0,
      );
      final lastMessage = lastMessages.isNotEmpty ? lastMessages.first : null;

      // Создаем объект ChatRoom с последним сообщением
      chatRoom = ChatRoom(
        id: chatRoomId,
        participants: participants,
        lastMessage: lastMessage,
        unreadCount:
            0, // Значение для количества непрочитанных сообщений можно добавить позже
      );
    } catch (err) {
      print('Error retrieving chat room: $err');
    }
    return chatRoom;
  }
}
