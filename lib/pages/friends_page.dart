// Новый FriendsPage
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../color.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  final _supabase = Supabase.instance.client;
  final String? _userId = Supabase.instance.client.auth.currentUser?.id;
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _friendRelations = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _loadFriendRelations();
  }

  Future<void> _loadUsers() async {
    try {
      final data = await _supabase
          .from('user_info')
          .select('id, username, avatar_url')
          .neq('id', _userId!);

      setState(() {
        _users = List<Map<String, dynamic>>.from(data);
      });
    } catch (e) {
      debugPrint('Ошибка загрузки пользователей: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось загрузить пользователей')),
      );
    }
  }

  Future<void> _loadFriendRelations() async {
    try {
      final data = await _supabase
          .from('friends')
          .select()
          .or('requester_id.eq.$_userId,receiver_id.eq.$_userId');

      if (mounted) {
        setState(() {
          _friendRelations = List<Map<String, dynamic>>.from(data);
        });
      }
    } catch (e) {
      debugPrint('Ошибка загрузки отношений дружбы: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось загрузить список друзей')),
        );
      }
    }
  }

  String _getFriendStatus(String otherUserId) {
    try {
      for (var rel in _friendRelations) {
        if (rel['requester_id'] == _userId && rel['receiver_id'] == otherUserId) {
          return rel['status'] == 'accepted' ? 'friends' : 'waiting';
        }
        if (rel['receiver_id'] == _userId && rel['requester_id'] == otherUserId) {
          return rel['status'] == 'accepted' ? 'friends' : 'incoming';
        }
      }
      return 'none';
    } catch (e) {
      debugPrint('Ошибка определения статуса дружбы: $e');
      return 'none';
    }
  }

  Future<void> _addFriend(String receiverId) async {
    await _supabase.from('friends').insert({
      'requester_id': _userId,
      'receiver_id': receiverId,
      'status': 'pending',
    });
    await _loadFriendRelations();
    // Можно добавить уведомление об успешном добавлении
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Запрос на добавление отправлен')),
    );
  }

  Future<void> _acceptFriend(String requesterId) async {
    try {
      final response = await _supabase
          .from('friends')
          .update({
        'status': 'accepted',
        // Не нужно явно обновлять updated_at - триггер сделает это автоматически
      })
          .match({
        'requester_id': requesterId,
        'receiver_id': _userId!,
      })
          .select();

      if (response.isEmpty) {
        throw Exception('Не удалось найти запрос на дружбу');
      }

      // Обновляем UI
      await Future.wait([
        _loadFriendRelations(),
        _loadUsers(),
      ]);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Запрос на дружбу принят!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint('Ошибка при принятии дружбы: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: ${e is PostgrestException ? e.message : e.toString()}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _rejectFriend(String requesterId) async {
    try {
      // Добавляем проверку на mounted в начале
      if (!mounted) return;

      final response = await _supabase
          .from('friends')
          .delete()
          .match({
        'requester_id': requesterId,
        'receiver_id': _userId!,
        'status': 'pending'  // Удаляем только pending-запросы
      })
          .select();

      if (response.isEmpty) {
        throw Exception('Запрос на дружбу не найден или уже обработан');
      }

      // Обновляем UI
      await _loadFriendRelations();
      await _loadUsers();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Запрос отклонен'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error rejecting friend: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: ${e.toString()}'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Widget _buildActionButton(String userId, String status) {
    switch (status) {
      case 'none':
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          onPressed: () => _addFriend(userId),
          child: const Text('Добавить', style: TextStyle(color: Colors.white)),
        );
      case 'waiting':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text('Ожидание', style: TextStyle(color: Colors.grey)),
        );
      case 'incoming':
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
              onPressed: () => _acceptFriend(userId),
              child: const Text('Принять', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
              onPressed: () => _rejectFriend(userId),
              child: const Text('Отклонить', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      case 'friends':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text('Друзья', style: TextStyle(color: Colors.green)),
        );
      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Друзья',
          style: TextStyle(
            fontFamily: 'Unbounded',
            fontSize: 24,
            color: AppColors.primary_b,
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          final status = _getFriendStatus(user['id']);
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(user['avatar_url'] ?? ''),
              backgroundColor: Colors.grey,
            ),
            title: Text(
              user['username'] ?? 'Без имени',
              style: const TextStyle(color: Colors.white),
            ),
            trailing: _buildActionButton(user['id'], status),
          );
        },
      ),
    );
  }
}
