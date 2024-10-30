import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_auth/dart_frog_auth.dart';
import 'package:vka_api/src/repositories/auth_repository.dart';

Handler middleware(Handler handler) {
  return handler
      .use(bearerAuthentication<String>(authenticator: (context, token) async {
    final authRepository = context.read<AuthRepository>();
    final email = authRepository.verifyToken(token);
    return email;
  }));
}
