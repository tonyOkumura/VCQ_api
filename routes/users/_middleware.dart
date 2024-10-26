import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_auth/dart_frog_auth.dart';
import 'package:vcq_models/models.dart';
import 'package:vka_api/src/repositories/users_repository.dart';

Handler middleware(Handler handler) {
  return handler
      .use(bearerAuthentication<User>(authenticator: (context, token) async {
    final usersRepository = context.read<UsersRepository>();
    return usersRepository.verifyToken(token);
  }));
}
