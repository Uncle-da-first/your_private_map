import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const LocationMixerApp());
}

class LocationMixerApp extends StatelessWidget {
  const LocationMixerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(), // Гиковский темный стиль
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isMasked = false;
  String currentcoords = "Нажмите 'Обновить', чтобы получить GPS";

  // Функция получения реальных координат
  Future<void> _getLocation() async {
    // Проверяем разрешения на доступ к геопозиции
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );
      
      setState(() {
        if (isMasked) {
          // Имитируем маскировку: добавляем случайный "шум" к координатам
          double maskedLat = position.latitude + 0.005;
          double maskedLng = position.longitude - 0.005;
          currentcoords = "Маскировка включена!\nLat: ${maskedLat.toStringAsFixed(5)}\nLng: ${maskedLng.toStringAsFixed(5)}";
        } else {
          currentcoords = "Реальный GPS:\nLat: ${position.latitude.toStringAsFixed(5)}\nLng: ${position.longitude.toStringAsFixed(5)}";
        }
      });
    } else {
      setState(() {
        currentcoords = "Доступ к GPS отклонен";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Web3 Location Mixer MVP')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: isMasked ? Colors.green.withOpacity(0.2) : Colors.grey[900],
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  currentcoords,
                  style: const TextStyle(fontSize: 18, fontFamily: 'monospace'),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Маскировка локации (RAM-only)", style: TextStyle(fontSize: 16)),
                Switch(
                  value: isMasked,
                  onChanged: (value) {
                    setState(() {
                      isMasked = value;
                    });
                    _getLocation(); // Сразу обновляем координаты при переключении
                  },
                ),
              ],
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _getLocation,
              icon: const Icon(Icons.refresh),
              label: const Text("Обновить координаты"),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(15)),
            ),
          ],
        ),
      ),
    );
  }
}
