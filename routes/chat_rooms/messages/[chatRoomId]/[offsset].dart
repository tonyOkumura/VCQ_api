import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:vka_api/src/repositories/message_repository.dart';

Future<Response> onRequest(
    RequestContext context, String chatRoomId, String offset) async {
  switch (context.request.method) {
    case HttpMethod.get:
      return await _get(context, chatRoomId, int.parse(offset));
    default:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}

Future<Response> _get(
    RequestContext context, String chatRoomId, int offset) async {
  final messageRepository = context.read<MessageRepository>();

  try {
    final messages = await messageRepository.fetchMessagesWithPagination(
      chatRoomId: chatRoomId,
      limit: 20,
      offset: offset,
    );

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
