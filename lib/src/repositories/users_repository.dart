import 'dart:math';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:supabase/supabase.dart';

import 'package:vcq_models/models.dart' as vcqModels;

class UsersRepository {
  final SupabaseClient dbClient;

  const UsersRepository({required this.dbClient});

  /// Возвращает список пользователей или пустой список при ошибке
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      // Выполняем запрос на получение всех пользователей
      final List<dynamic> response = await dbClient.from('users').select();

      // Преобразуем ответ в список Map
      final users = response.cast<Map<String, dynamic>>();

      return users;
    } catch (err) {
      // В случае ошибки возвращаем пустой список
      print('Что-то пошло не так: $err');
      return [];
    }
  }

  Future<String> createUser(vcqModels.User user) async {
    try {
      // Выполняем запрос на создание пользователя
      await dbClient.from('users').insert(user.toJson());

      final token = Random().nextInt(100).toString();
      return token;
    } catch (err) {
      // В случае ошибки возвращаем пустой Map
      print('Что-то пошло не так: $err');
      return '';
    }
  }

  Future<String> updateUser(vcqModels.User user) async {
    try {
      // Выполняем запрос на обновление пользователя
      await dbClient.from('users').update(user.toJson()).eq('id', user.id);

      final token = Random().nextInt(100).toString();
      return token;
    } catch (err) {
      // В случае ошибки возвращаем пустой Map
      print('Что-то пошло не так: $err');
      return '';
    }
  }

  Future<String> deleteUser(vcqModels.User user) async {
    try {
      // Выполняем запрос на удаление пользователя
      await dbClient.from('users').delete().eq('id', user.id);

      final token = Random().nextInt(100).toString();
      return token;
    } catch (err) {
      // В случае ошибки возвращаем пустой Map
      print('Что-то пошло не так: $err');
      return '';
    }
  }

  Future<String> loginUser(String email, String password) async {
    try {
      // Выполняем запрос на удаление пользователя
      final response = await dbClient
          .from("users_auth")
          .select()
          .eq('email', email)
          .eq('password_hash', password);
      if (response.isEmpty) {
        return '';
      } else {
        final jwt = JWT(
          {'email': email},
        );

        final token =
            await jwt.sign(SecretKey('123'), algorithm: JWTAlgorithm.HS256);

        return token;
      }
    } catch (err) {
      // В случае ошибки возвращаем пустой Map
      print('Что-то пошло не так: $err');
      return '';
    }
  }

  Future<User?> verifyToken(String token) async {
    try {
      final payload = JWT.verify(
        token,
        SecretKey('123'),
      );

      final payloadData = payload.payload as Map<String, dynamic>;

      final email = payloadData['email'] as String;
      final user =
          await dbClient.from('users').select().eq('email', email).single();

      return User.fromJson(user);
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }
}
