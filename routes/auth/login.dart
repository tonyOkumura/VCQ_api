import 'dart:convert';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:vcq_models/models.dart';
import 'package:vka_api/src/repositories/auth_repository.dart';

Future<Response> onRequest(RequestContext context) async {
  switch (context.request.method) {
    case HttpMethod.post:
      return await _post(context);
    default:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}

Future<Response> _post(RequestContext context) async {
  final authRepository = context.read<AuthRepository>();
  try {
    final body = await context.request.body();
    final Map<String, dynamic> jsonData = jsonDecode(body);
    final userAuth = UserLogin.fromJson(jsonData);
    final token = await authRepository.loginUser(
        userAuth.username, userAuth.password_hash);

    if (token.isEmpty) {
      return Response.json(
        body: {'error': 'Invalid username or password'},
        statusCode: HttpStatus.unauthorized,
      );
    }

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
