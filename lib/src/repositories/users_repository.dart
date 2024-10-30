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

      final users = response.cast<Map<String, dynamic>>();

      return users;
    } catch (err) {
      // В случае ошибки возвращаем пустой список
      print('Что-то пошло не так: $err');
      return [];
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

  Future<Map<String, dynamic>> findUserById(
    String id,
  ) async {
    try {
      // Выполняем запрос на получение пользователя по id
      final response =
          await dbClient.from('users').select().eq('id', id).single();
      print(response);

      return response.cast<String, dynamic>();
    } catch (err) {
      // В случае ошибки возвращаем пустой Map
      print('Что-то пошло не так: $err');
      return {};
    }
  }
}
