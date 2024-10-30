import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:vka_api/src/repositories/message_repository.dart';

Response onRequest(
  RequestContext context,
  String chatRoomId,
) {
  switch (context.request.method) {
    case HttpMethod.get:
      return _get(context, chatRoomId);
    default:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}

Response _get(RequestContext context, String chatRoomId) {
  final messageRepository = context.read<MessageRepository>();

  try {
    final messages = messageRepository.fetchMessages(chatRoomId);
    return Response.json(
      body: messages,
      statusCode: HttpStatus.accepted,
    );
  } catch (err) {
    return Response.json(
      body: {'error': err.toString()},
      statusCode: HttpStatus.internalServerError,
    );
  }
}
