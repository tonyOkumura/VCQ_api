import 'dart:convert';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:vcq_models/models.dart';
import 'package:vka_api/src/repositories/chatroom_repository.dart';
import 'package:vka_api/src/repositories/message_repository.dart';

Future<Response> onRequest(RequestContext context) async {
  switch (context.request.method) {
    case HttpMethod.post:
      return await _post(context);
    default:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}

Future<Response> _post(RequestContext context) async {
  final messaageRepository = context.read<MessageRepository>();

  try {
    final body = await context.request.body();
    final Map<String, dynamic> jsonData = jsonDecode(body);

    final message = Message.fromJson(jsonData);

    await messaageRepository.createMessage(
      message,
    );

    return Response(statusCode: HttpStatus.created);
  } catch (err) {
    return Response.json(
      body: {'error': err.toString()},
      statusCode: HttpStatus.internalServerError,
    );
  }
}
