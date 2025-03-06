import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/svg.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../color.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _city = "Ща определим..."; // Город пользователя
  LatLng? _userLocation; // Координаты пользователя

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  /// Получение местоположения
  Future<void> _getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Проверяем, включена ли геолокация
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    // Проверяем разрешения
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) return;
    }

    // Показываем последнее местоположение (чтобы карта загрузилась быстрее)
    Position? lastPosition = await Geolocator.getLastKnownPosition();
    if (lastPosition != null) {
      setState(() {
        _userLocation = LatLng(lastPosition.latitude, lastPosition.longitude);
      });
    }

    // Получаем актуальное местоположение
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high, // Точная геолокация
    );

    setState(() {
      _userLocation = LatLng(position.latitude, position.longitude);
      _city = "Москва"; // Заглушка, можно заменить API для получения города
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false, // стрелка назад (выкл)
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
                        color: AppColors.grey,),
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
          /// Карта
          _userLocation == null
              ? Center(child: CircularProgressIndicator()) // Пока грузится
              : FlutterMap(
            options: MapOptions(
              center: _userLocation, // Центр карты - координаты пользователя
              zoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: 'com.example.podpole',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _userLocation!,
                    width: 40,
                    height: 40,
                    child: SvgPicture.asset(
                      'assets/icons/location.svg',
                      color: AppColors.black,
                      width: 30,
                      height: 30,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}