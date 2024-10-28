import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:supabase/supabase.dart' as supabase;
import 'package:vcq_models/models.dart';

class AuthRepository {
  final supabase.SupabaseClient dbClient;

  const AuthRepository({required this.dbClient});

  Future<void> createUser(UserRegister userRegister) async {
    try {
      await dbClient.from('users_auth').insert(userRegister.toJson());
      final user = User(
        id: userRegister.id,
        username: userRegister.username,
        createdAt: DateTime.now(),
        is_online: false,
      );
      await dbClient.from('users').insert(user.toJson());
    } catch (err) {
      // В случае ошибки возвращаем пустой Map
      print('Что-то пошло не так: $err');
      return null;
    }
  }

  Future<String> loginUser(String username, String password) async {
    try {
      final response = await dbClient
          .from("users_auth")
          .select("id")
          .eq('username', username)
          .eq('password_hash', password);
      if (response.isEmpty) {
        return '';
      } else {
        final jwt = JWT(
          {
            'username': username,
            'id': response[0]['id'],
          },
        );

        final token = await jwt.sign(SecretKey('tokumura'),
            algorithm: JWTAlgorithm.HS256, expiresIn: const Duration(days: 7));

        return token;
      }
    } catch (err) {
      print('Что-то пошло не так: $err');
      return '';
    }
  }

  String? verifyToken(String token) {
    final payload = JWT.verify(
      token,
      SecretKey('tokumura'),
    );
    final payloadData = payload.payload as Map<String, dynamic>;

    final username = payloadData['username'] as String;

    return username;
  }
}
