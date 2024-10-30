import 'dart:convert';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:vcq_models/models.dart';
import 'package:vka_api/src/repositories/chatroom_repository.dart';
import 'package:vka_api/src/repositories/users_repository.dart';

Future<Response> onRequest(
  RequestContext context,
  String participantId,
) async {
  // TODO: implement route handler
  switch (context.request.method) {
    case HttpMethod.get:
      return await _get(context, participantId);
    case HttpMethod.post:
      return await _post(context);
    default:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}

Future<Response> _get(RequestContext context, String id) async {
  final chatRoomsRepository = context.read<ChatroomRepository>();
  try {
    final chatRoomIds =
        await chatRoomsRepository.getChatRoomsByParticipantID(id);

    return Response.json(
      body: chatRoomIds,
      statusCode: HttpStatus.accepted,
    );
  } catch (err) {
    return Response.json(
      body: {'error': err.toString()},
      statusCode: HttpStatus.internalServerError,
    );
  }
}

Future<Response> _post(RequestContext context) async {
  final chatRoomsRepository = context.read<ChatroomRepository>();

  try {
    final body = await context.request.body();
    final Map<String, dynamic> jsonData = jsonDecode(body);

    final chatRoom = ChatRoom.fromJson(jsonData);

    await chatRoomsRepository.createChatRoom(
      chatRoom,
    );

    return Response(
      body: jsonEncode(chatRoom.toJson()),
      statusCode: HttpStatus.created,
    );
  } catch (err) {
    return Response.json(
      body: {'error': err.toString()},
      statusCode: HttpStatus.internalServerError,
    );
  }
}
