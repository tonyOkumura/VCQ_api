import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

import 'package:vka_api/src/repositories/chatroom_repository.dart';

Future<Response> onRequest(
  RequestContext context,
  String participantId,
) async {
  switch (context.request.method) {
    case HttpMethod.get:
      return await _get(context, participantId);
    default:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}

Future<Response> _get(RequestContext context, String id) async {
  final chatRoomsRepository = context.read<ChatroomRepository>();
  try {
    final chatRooms = await chatRoomsRepository.getChatRoomsByParticipantID(id);

    return Response.json(
      body: chatRooms,
      statusCode: HttpStatus.accepted,
    );
  } catch (err) {
    return Response.json(
      body: {'error': err.toString()},
      statusCode: HttpStatus.internalServerError,
    );
  }
}
