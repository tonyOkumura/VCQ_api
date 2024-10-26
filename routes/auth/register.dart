import 'dart:convert';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:vka_api/src/repositories/users_repository.dart';
import 'package:vcq_models/models.dart';

Future<Response> onRequest(RequestContext context) async {
  switch (context.request.method) {
    case HttpMethod.post:
      return await _post(context);
    default:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}

Future<Response> _post(RequestContext context) async {
  final usersRepository = context.read<UsersRepository>();

  try {
    // Читаем тело запроса и парсим JSON
    final body = await context.request.body();
    final Map<String, dynamic> jsonData = jsonDecode(body);

    // Создаём объект User на основе полученных данных
    final user = User.fromJson(jsonData);

    // Создаём пользователя в базе данных
    final createdUser = await usersRepository.createUser(user);

    return Response.json(
      body: {
        'token': createdUser,
      },
      statusCode: HttpStatus.created,
    );
  } catch (err) {
    return Response.json(
      body: {'error': err.toString()},
      statusCode: HttpStatus.internalServerError,
    );
  }
}
