import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const MapNoLogApp());
}

class MapNoLogApp extends StatelessWidget {
  const MapNoLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MapNoLog',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F0F11),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF1D9E75),
          secondary: Color(0xFF1565C0),
        ),
      ),
      home: const MainMixerScreen(),
    );
  }
}

class MainMixerScreen extends StatefulWidget {
  const MainMixerScreen({super.key});

  @override
  State<MainMixerScreen> createState() => _MainMixerScreenState();
}

class _MainMixerScreenState extends State<MainMixerScreen> {
  bool _isMaskingEnabled = false;
  
  double _realLat = 0.0;
  double _realLon = 0.0;
  double _outputLat = 0.0;
  double _outputLon = 0.0;
  
  double _currentOffsetMeters = 0.0;
  double _currentBearing = 0.0;

  StreamSubscription<Position>? _gpsStreamSubscription;
  Timer? _noiseRotationTimer;

  @override
  void initState() {
    super.initState();
    _initGPS();
  }

  @override
  void dispose() {
    _gpsStreamSubscription?.cancel();
    _noiseRotationTimer?.cancel();
    super.dispose();
  }

  Future<void> _initGPS() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    
    if (permission == LocationPermission.deniedForever) return;

    _gpsStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 2,
      ),
    ).listen((Position position) {
      setState(() {
        _realLat = position.latitude;
        _realLon = position.longitude;
      });
      _processCoordinates();
    });
  }

  void _generateNewNoiseVector() {
    final random = math.Random();
    double minDistance = 300.0;
    double maxDistance = 800.0;
    
    _currentOffsetMeters = minDistance + random.nextDouble() * (maxDistance - minDistance);
    _currentBearing = random.nextDouble() * 2 * math.pi;
    
    _processCoordinates();
  }

  void _processCoordinates() {
    if (!_isMaskingEnabled || _realLat == 0.0) {
      setState(() {
        _outputLat = _realLat;
        _outputLon = _realLon;
      });
      return;
    }

    const double earthRadius = 6378137.0;
    double deltaLat = (_currentOffsetMeters * math.cos(_currentBearing)) / earthRadius;
    double deltaLon = (_currentOffsetMeters * math.sin(_currentBearing)) / (earthRadius * math.cos(_realLat * math.pi / 180));

    setState(() {
      _outputLat = _realLat + (deltaLat * 180 / math.pi);
      _outputLon = _realLon + (deltaLon * 180 / math.pi);
    });
  }

  void _toggleMasking(bool value) {
    _isMaskingEnabled = value;
    
    if (_isMaskingEnabled) {
      _generateNewNoiseVector();
      _noiseRotationTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
        _generateNewNoiseVector();
      });
    } else {
      _noiseRotationTimer?.cancel();
      _currentOffsetMeters = 0.0;
      _processCoordinates();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📍 MapNoLog Engine', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFF16161A),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _isMaskingEnabled ? const Color(0xFF0A2F24) : const Color(0xFF261818),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isMaskingEnabled ? const Color(0xFF1D9E75) : const Color(0xFFD32F2F),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isMaskingEnabled ? Icons.shield_rounded : Icons.gpp_bad_rounded,
                    color: _isMaskingEnabled ? const Color(0xFF1D9E75) : const Color(0xFFD32F2F),
                    size: 40,
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isMaskingEnabled ? "PRIVACY ACTIVE" : "TRACKING RISK",
                          style: TextStyle(
                            fontSize: 18, 
                            fontWeight: FontWeight.bold, 
                            color: _isMaskingEnabled ? const Color(0xFF1D9E75) : const Color(0xFFD32F2F)
                          ),
                        ),
                        Text(
                          _isMaskingEnabled 
                              ? "Vector updates every 2 min. Streaming fuzzed data." 
                              : "GPS sensors are streaming raw telemetry.",
                          style: const TextStyle(fontSize: 13, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            _buildCoordinateTile(
              "Real GPS (From Satellites)", 
              _realLat, 
              _realLon, 
              _realLat == 0.0 ? Colors.orange : Colors.grey
            ),
            const SizedBox(height: 15),
            _buildCoordinateTile(
              "Fuzzed Stream Output", 
              _outputLat, 
              _outputLon, 
              _isMaskingEnabled ? const Color(0xFF1D9E75) : Colors.grey
            ),
            
            if (_isMaskingEnabled) ...[
              const SizedBox(height: 10),
              Text(
                "Current Vector: ~${_currentOffsetMeters.toStringAsFixed(1)}m at ${(_currentBearing * 180 / math.pi).toStringAsFixed(0)}°",
                style: const TextStyle(color: Color(0xFF1D9E75), fontWeight: FontWeight.w500),
              ),
            ],

            const SizedBox(height: 50),

            Transform.scale(
              scale: 1.5,
              child: Switch(
                value: _isMaskingEnabled,
                activeColor: const Color(0xFF1D9E75),
                onChanged: _toggleMasking,
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              "Toggle Dynamic Privacy Layer",
              style: TextStyle(fontSize: 16, color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoordinateTile(String title, double lat, double lon, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF16161A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(
            lat == 0.0 ? "Waiting for GPS fix..." : "Lat: ${lat.toStringAsFixed(6)} | Lon: ${lon.toStringAsFixed(6)}",
            style: const TextStyle(fontSize: 15, fontFamily: 'monospace', fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}