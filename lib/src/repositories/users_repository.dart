import 'package:supabase/supabase.dart';
import 'package:vcq_models/models.dart' as vcqModels;

class UsersRepository {
  final SupabaseClient dbClient;

  const UsersRepository({required this.dbClient});

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final List<dynamic> response = await dbClient.from('users').select();
      final users = response.cast<Map<String, dynamic>>();
      return users;
    } catch (err) {
      print('Что-то пошло не так при получении пользователей: $err');
      return [];
    }
  }

  Future<void> updateUser(vcqModels.User user) async {
    try {
      await dbClient.from('users').update(user.toJson()).eq('id', user.id!);
      await dbClient.from('users_auth').update({
        'username': user.username,
      }).eq('id', user.id!);
    } catch (err) {
      print('Что-то пошло не так при обновлении пользователя: $err');
    }
  }

  Future<Map<String, dynamic>> findUserById(
    String id,
  ) async {
    try {
      final response =
          await dbClient.from('users').select().eq('id', id).single();
      return response.cast<String, dynamic>();
    } catch (err) {
      print('Что-то пошло не так при поиске пользователя: $err');
      return {};
    }
  }

  Future<void> updateUserStatus(String userId, {required bool isOnline}) async {
    try {
      await dbClient
          .from('users')
          .update({'is_online': isOnline}).eq('id', userId);
    } catch (error) {
      print('Error updating user status: $error');
    }
  }
}
