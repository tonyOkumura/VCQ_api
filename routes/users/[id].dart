import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:vcq_models/models.dart';
import 'package:vka_api/src/repositories/users_repository.dart';

Future<Response> onRequest(
  RequestContext context,
  String id,
) async {
  // TODO: implement route handler
  switch (context.request.method) {
    case HttpMethod.get:
      return await _get(context, id);
    default:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}

Future<Response> _get(RequestContext context, String id) async {
  final usersRepository = context.read<UsersRepository>();
  try {
    final usermap = await usersRepository.findUserById(id);
    if (usermap.isEmpty) {
      return Response.json(
        body: {'error': 'User not found'},
        statusCode: HttpStatus.notFound,
      );
    }
    final user = User.fromJson(usermap);

    return Response.json(
      body: user.toJson(),
      statusCode: HttpStatus.accepted,
    );
  } catch (err) {
    return Response.json(
      body: {'error': err.toString()},
      statusCode: HttpStatus.internalServerError,
    );
  }
}
