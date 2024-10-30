import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:vka_api/src/repositories/chatroom_repository.dart';

Future<Response> onRequest(
  RequestContext context,
  String chat_roomId,
) async {
  // TODO: implement route handler
  switch (context.request.method) {
    case HttpMethod.get:
      return await _get(context, chat_roomId);
    default:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}

Future<Response> _get(RequestContext context, String id) async {
  final chatRoomsRepository = context.read<ChatroomRepository>();
  try {
    final participantIds =
        await chatRoomsRepository.getParticipantsByChatRoomID(id);

    return Response.json(
      body: participantIds,
      statusCode: HttpStatus.accepted,
    );
  } catch (err) {
    return Response.json(
      body: {'error': err.toString()},
      statusCode: HttpStatus.internalServerError,
    );
  }
}
