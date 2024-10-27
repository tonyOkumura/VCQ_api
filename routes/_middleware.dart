import 'package:dart_frog/dart_frog.dart';
import 'package:vka_api/src/repositories/auth_repository.dart';
import 'package:vka_api/src/repositories/message_repository.dart';
import 'package:vka_api/src/repositories/users_repository.dart';

import '../main.dart';

Handler middleware(Handler handler) {
  return handler
      .use(requestLogger())
      .use(
        provider<MessageRepository>((_) => messageRepository),
      )
      .use(provider<UsersRepository>((_) => usersRepository))
      .use(
        provider<AuthRepository>((_) => authRepository),
      );
}
