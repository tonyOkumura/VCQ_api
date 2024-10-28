import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:supabase/supabase.dart';
import 'package:vka_api/src/repositories/auth_repository.dart';
import 'package:vka_api/src/repositories/chatroom_repository.dart';
import 'package:vka_api/src/repositories/message_repository.dart';
import 'package:vka_api/src/repositories/users_repository.dart';

import 'src/env/env.dart';

late MessageRepository messageRepository;
late UsersRepository usersRepository;
late AuthRepository authRepository;
late ChatroomRepository chatroomRepository;

Future<HttpServer> run(Handler handler, InternetAddress ip, int port) {
  final dbClient = SupabaseClient(
    Env.SUPABASE_URL,
    Env.SUPABASE_SERVICE_ROLE_KEY, // Use it only in the server, never on the client side.
  );

  messageRepository = MessageRepository(dbClient: dbClient);
  usersRepository = UsersRepository(dbClient: dbClient);
  authRepository = AuthRepository(dbClient: dbClient);
  chatroomRepository = ChatroomRepository(dbClient: dbClient);

  return serve(handler, ip, port);
}
