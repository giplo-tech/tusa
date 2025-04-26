import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/services.dart';
import '../color.dart';
import 'package:podpole/auth/auth_service.dart';

import '../pages/friends_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final authService = AuthService();
  final supabase = Supabase.instance.client;
  String? _username;
  String? _avatarUrl;
  String? _fullName;
  String? _city;
  String? _district;
  String? _metroStation;
  bool _isLoading = true;

  Future<void> _loadProfile() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      final response = await supabase
          .from('user_info')
          .select('username, avatar_url, full_name, city, district, metro_station')
          .eq('id', userId)
          .single();

      if (response != null) {
        setState(() {
          _username = response['username'];
          _avatarUrl = response['avatar_url'];
          _fullName = response['full_name'];
          _city = response['city'];
          _district = response['district'];
          _metroStation = response['metro_station'];
        });
      }
    } catch (e) {
      debugPrint('Ошибка загрузки профиля: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Не удалось загрузить профиль')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }


  Future<void> _logout() async {
    try {
      await authService.signOut();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при выходе: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _copyUsername() async {
    if (_username == null) return;

    await Clipboard.setData(ClipboardData(text: _username!));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Никнейм скопирован')),
      );
    }
  }

  void _navigateToFriendsPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FriendsPage()),
    );
  }

  void _editCharacterPhotos() {
    // Редактирование фотографий характера
    // Navigator.push(context, MaterialPageRoute(builder: (_) => EditPhotosPage()));
  }



  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final avatarSize = screenWidth * 0.3;

    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        title: GestureDetector(
          onTap: _username != null ? _copyUsername : null,
          child: _username != null
              ? RichText(
            text: TextSpan(
              children: [
                const TextSpan(
                  text: '@',
                  style: TextStyle(
                    fontFamily: 'Styrene',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.white,
                  ),
                ),
                TextSpan(
                  text: _username!,
                  style: const TextStyle(
                    fontFamily: 'Styrene',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          )
              : const Text(
            'Профиль',
            style: TextStyle(
              fontFamily: 'Styrene',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.white,
            ),
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.black,
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 10),
                      // Аватар
                      SizedBox(
                        width: avatarSize,
                        height: avatarSize,
                        child: CircleAvatar(
                          backgroundColor: Colors.grey[800],
                          backgroundImage: _avatarUrl != null
                              ? NetworkImage(_avatarUrl!)
                              : null,
                          child: _avatarUrl == null
                              ? Icon(
                            Icons.person,
                            size: avatarSize * 0.5,
                            color: Colors.white,
                          )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 10),

                      if (_fullName != null) ...[
                        SizedBox(
                          width: double.infinity,
                          child: Text(
                            _fullName!,
                            style: const TextStyle(
                              fontFamily: 'Styrene',
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: AppColors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],

                      // Три контейнера с информацией о местоположении
                      if (_city != null || _district != null || _metroStation != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10), // Верхний и нижний отступ 30
                          child: Wrap(
                            alignment: WrapAlignment.center, // Выравнивание по центру
                            spacing: 8, // Горизонтальный отступ между элементами
                            runSpacing: 8, // Вертикальный отступ между строками
                            children: [
                              // Город
                              if (_city != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                  decoration: BoxDecoration(
                                    color: AppColors.black_l,
                                    borderRadius: BorderRadius.circular(7),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.location_city,
                                          size: 16,
                                          color: AppColors.white),
                                      const SizedBox(width: 4),
                                      Text(
                                        _city!,
                                        style: const TextStyle(
                                          fontFamily: 'Styrene',
                                          color: AppColors.white,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              // Район
                              if (_district != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                  decoration: BoxDecoration(
                                    color: AppColors.black_l,
                                    borderRadius: BorderRadius.circular(7),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.map,
                                          size: 16,
                                          color: AppColors.white),
                                      const SizedBox(width: 4),
                                      Text(
                                        _district!,
                                        style: const TextStyle(
                                          fontFamily: 'Styrene',
                                          color: AppColors.white,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              // Станция метро
                              if (_metroStation != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                  decoration: BoxDecoration(
                                    color: AppColors.black_l,
                                    borderRadius: BorderRadius.circular(7),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.directions_subway,
                                          size: 16,
                                          color: AppColors.white),
                                      const SizedBox(width: 4),
                                      Text(
                                        _metroStation!,
                                        style: const TextStyle(
                                          fontFamily: 'Styrene',
                                          color: AppColors.white,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 0),

                      // Остальной контент...
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10), // Вертикальные отступы
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8, right: 4), // Левая кнопка: слева 8, справа 4
                                child: ElevatedButton(
                                  onPressed: _navigateToFriendsPage,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SvgPicture.asset(
                                        'assets/icons/people.svg',
                                        width: 20,
                                        height: 20,
                                        color: AppColors.black_l,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Друзья',
                                        style: TextStyle(
                                          fontFamily: 'Styrene',
                                          color: AppColors.black_l,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 4, right: 8), // Правая кнопка: слева 4, справа 8
                                child: ElevatedButton(
                                  onPressed: _editCharacterPhotos,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.black_l,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SvgPicture.asset(
                                        'assets/icons/edit.svg',
                                        width: 20,
                                        height: 20,
                                        color: AppColors.white,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Редактировать',
                                        style: TextStyle(
                                          fontFamily: 'Styrene',
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      GridView.count(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        crossAxisCount: 2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 1,
                        children: List.generate(4, (index) {
                          return Container(
                            decoration: BoxDecoration(
                              color: AppColors.black_l,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text(
                                'Фото ${index + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}