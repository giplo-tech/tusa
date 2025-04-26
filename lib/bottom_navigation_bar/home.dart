import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../color.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  String _city = "Определяем...";
  LatLng? _userLocation;
  String? _avatarUrl;
  final _supabase = Supabase.instance.client;

  List<Map<String, dynamic>> _friends = [];

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _getUserLocation();
    _loadUserAvatar();
    _loadFriends();

    // Обновляем данные каждые 30 секунд
    Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        _getUserLocation();
        _loadFriends();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }



  Future<void> _loadUserAvatar() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final response = await _supabase
          .from('user_info')
          .select('avatar_url')
          .eq('id', userId)
          .single();

      if (response != null && mounted) {
        setState(() {
          _avatarUrl = response['avatar_url'];
        });
      }
    } catch (e) {
      debugPrint('Ошибка загрузки аватара: $e');
    }
  }

  Future<void> _getUserLocation() async {
    // ... существующий код ...

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // Обновляем location в Supabase
    try {
      await _supabase
          .from('user_info')
          .update({
        'latitude': position.latitude,
        'longitude': position.longitude,
        'updated_at': DateTime.now().toIso8601String(),
      })
          .eq('id', _supabase.auth.currentUser!.id);
    } catch (e) {
      debugPrint('Ошибка обновления местоположения: $e');
    }

    if (mounted) {
      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
        _city = "Москва"; // Или получайте город из position если возможно
      });
    }
  }

  Future<void> _loadFriends() async {
    try {
      final currentUserId = _supabase.auth.currentUser?.id;
      if (currentUserId == null) return;

      final response = await _supabase
          .from('friends')
          .select('''*, user_info:user_info!friends_receiver_id_fkey(
          id, 
          username,
          avatar_url, 
          latitude, 
          longitude,
          city
        )''')
          .or('requester_id.eq.$currentUserId,receiver_id.eq.$currentUserId')
          .eq('status', 'accepted')
          .neq('user_info.id', currentUserId); // Важно: исключаем себя

      final friendsData = response
          .map((rel) {
        final user = rel['user_info'] as Map<String, dynamic>?;
        if (user == null || user['id'] == currentUserId) return null; // Дополнительная проверка

        return {
          'id': user['id'],
          'username': user['username'],
          'avatar_url': user['avatar_url'],
          'lat': user['latitude'],
          'lng': user['longitude'],
          'city': user['city'],
        };
      })
          .where((user) => user != null)
          .cast<Map<String, dynamic>>()
          .toList();

      if (mounted) {
        setState(() {
          _friends = friendsData;
          debugPrint('Загружено друзей: ${_friends.length}'); // Для отладки
        });
      }
    } catch (e) {
      debugPrint('Ошибка загрузки друзей: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось загрузить список друзей')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "TUS'Э",
              style: TextStyle(
                fontFamily: 'Unbounded',
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: AppColors.primary_b,
              ),
            ),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Город',
                      style: TextStyle(
                        fontFamily: 'Styrene',
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                        color: AppColors.grey,
                      ),
                    ),
                    Text(
                      _city,
                      style: const TextStyle(
                        fontFamily: 'Styrene',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 4),
                SvgPicture.asset(
                  'assets/icons/global.svg',
                  color: AppColors.white,
                  width: 32,
                  height: 32,
                ),
              ],
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          _userLocation == null
              ? const Center(child: CircularProgressIndicator())
              : FlutterMap(
            options: MapOptions(
              center: _userLocation,
              zoom: 13.0,
            ),
            children: [
              Stack(
                children: [
                  TileLayer(
                    urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                    userAgentPackageName: 'com.example.podpole',
                  ),
                  IgnorePointer(
                    child: Container(
                      color: Colors.black.withOpacity(0.4),
                    ),
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _userLocation!,
                    width: 40,
                    height: 40,
                    child: AnimatedBuilder(
                      animation: _scaleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value,
                          child: _buildAvatarMarker(_avatarUrl, isCurrentUser: true),
                        );
                      },
                    ),
                  ),
                  ..._friends.map((friend) {
                    if (friend['lat'] == null || friend['lng'] == null)
                      return const Marker(point: LatLng(0, 0), width: 0, height: 0, child: SizedBox());
                    return Marker(
                      point: LatLng(friend['lat'], friend['lng']),
                      width: 40,
                      height: 40,
                      child: _buildAvatarMarker(friend['avatar_url']),
                    );
                  }).toList(),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarMarker(String? url, {bool isCurrentUser = false}) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isCurrentUser ? AppColors.primary : AppColors.primary_b,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: (isCurrentUser ? AppColors.primary : AppColors.primary_b)
                .withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipOval(
        child: url != null
            ? Image.network(
          url,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            width: 40,
            height: 40,
            color: Colors.grey,
            child: const Icon(Icons.person, color: Colors.white),
          ),
        )
            : Container(
          width: 40,
          height: 40,
          color: Colors.grey,
          child: const Icon(Icons.person, color: Colors.white),
        ),
      ),
    );
  }
}
