import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:vka_api/src/repositories/users_repository.dart';

Future<Response> onRequest(RequestContext context) async {
  switch (context.request.method) {
    case HttpMethod.get:
      return await _get(context);
    default:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}

Future<Response> _get(RequestContext context) async {
  final usersRepository = context.read<UsersRepository>();

  try {
    // Используем await, чтобы получить данные из getAllUsers, которые не Future, а List<Map<String, dynamic>>
    final users = await usersRepository.getAllUsers();

    return Response.json(
      body: users,
      statusCode: HttpStatus.ok,
    );
  } catch (err) {
    return Response.json(
      body: {'error': err.toString()},
      statusCode: HttpStatus.internalServerError,
    );
  }
}
