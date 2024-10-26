import 'dart:convert';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:vka_api/src/models/user_auth_model.dart';
import 'package:vka_api/src/repositories/users_repository.dart';

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
    final body = await context.request.body();
    final Map<String, dynamic> jsonData = jsonDecode(body);
    final userAuth = UserAuth.fromJson(jsonData);
    final token =
        await usersRepository.loginUser(userAuth.email, userAuth.password);

    return Response.json(
      body: {
        'token': token,
      },
      statusCode: HttpStatus.accepted,
    );
  } catch (err) {
    return Response.json(
      body: {'error': err.toString()},
      statusCode: HttpStatus.internalServerError,
    );
  }
}
