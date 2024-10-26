import 'dart:math';

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
}
