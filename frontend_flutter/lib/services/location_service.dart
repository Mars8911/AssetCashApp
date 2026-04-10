// lib/services/location_service.dart
import 'dart:async';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_service.dart';

const String _channelId = 'assetcash_location';
const int _notificationId = 9001;
const String _prefKeyToken = 'auth_token';
const String _prefKeyTrackingEnabled = 'location_tracking_enabled';

// 策略：移動超過 10 公尺 或 每隔 20 秒
const int _distanceFilterMeters = 10;
const Duration _timeInterval = Duration(seconds: 20);

StreamSubscription<Position>? _positionSubscription;
Timer? _intervalTimer;

/// 初始化背景服務（需在 main() 中呼叫）
Future<void> initializeLocationService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: _onBackgroundStart,
      autoStart: false,
      isForegroundMode: true,
      notificationChannelId: _channelId,
      initialNotificationTitle: 'AsseTcash APP 定位追蹤',
      initialNotificationContent: '正在背景記錄您的位置',
      foregroundServiceNotificationId: _notificationId,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: false,
      onForeground: _onBackgroundStart,
      onBackground: _onIosBackground,
    ),
  );
}

@pragma('vm:entry-point')
Future<bool> _onIosBackground(ServiceInstance service) async {
  return true;
}

@pragma('vm:entry-point')
Future<void> _onBackgroundStart(ServiceInstance service) async {
  if (service is AndroidServiceInstance) {
    service.on('stop').listen((_) => service.stopSelf());
  }

  Timer.periodic(const Duration(seconds: 60), (_) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_prefKeyToken);
      final enabled = prefs.getBool(_prefKeyTrackingEnabled) ?? false;

      if (token == null || token.isEmpty || !enabled) {
        service.stopSelf();
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );

      await ApiService().updateLocation(token, position.latitude, position.longitude);
    } catch (_) {}
  });
}

/// 檢查並請求定位權限
Future<bool> _requestLocationPermission() async {
  var status = await Permission.locationWhenInUse.status;
  if (status.isGranted) {
    status = await Permission.locationAlways.status;
    if (!status.isGranted) {
      status = await Permission.locationAlways.request();
    }
    return status.isGranted;
  }
  status = await Permission.locationWhenInUse.request();
  if (status.isGranted) {
    status = await Permission.locationAlways.request();
  }
  return status.isGranted;
}

/// 使用 getPositionStream + 定時器：每 10m 或每 20 秒上傳
Future<void> startTracking(String token) async {
  final serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    throw Exception('請先開啟裝置的定位服務');
  }

  final granted = await _requestLocationPermission();
  if (!granted) {
    throw Exception('需要定位權限才能追蹤');
  }

  await _stopForegroundTracking();

  void uploadPosition(Position position) {
    ApiService()
        .updateLocation(token, position.latitude, position.longitude)
        .catchError((_) {});
  }

  // 立即上傳第一筆，不等 20 秒
  try {
    final first = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        timeLimit: Duration(seconds: 10),
      ),
    );
    uploadPosition(first);
  } catch (_) {}

  _positionSubscription = Geolocator.getPositionStream(
    locationSettings: LocationSettings(
      accuracy: LocationAccuracy.medium,
      distanceFilter: _distanceFilterMeters,
      timeLimit: const Duration(seconds: 30),
    ),
  ).listen(
    (position) => uploadPosition(position),
    onError: (_) {},
  );

  _intervalTimer = Timer.periodic(_timeInterval, (_) async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );
      uploadPosition(position);
    } catch (_) {}
  });

  await SharedPreferences.getInstance().then((prefs) {
    prefs.setBool(_prefKeyTrackingEnabled, true);
  });
}

Future<void> _stopForegroundTracking() async {
  await _positionSubscription?.cancel();
  _positionSubscription = null;
  _intervalTimer?.cancel();
  _intervalTimer = null;
}

/// 啟動定位追蹤（前台：getPositionStream + 定時；背景：Android 服務）
Future<void> startLocationTracking() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString(_prefKeyToken);
  if (token == null || token.isEmpty) {
    throw Exception('請先登入');
  }
  await prefs.setBool(_prefKeyTrackingEnabled, true);

  await startTracking(token);

  final service = FlutterBackgroundService();
  service.startService();
}

/// 停止定位追蹤
Future<void> stopLocationTracking() async {
  await _stopForegroundTracking();

  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_prefKeyTrackingEnabled, false);

  final service = FlutterBackgroundService();
  service.invoke('stop');
}

Future<bool> isLocationTrackingEnabled() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(_prefKeyTrackingEnabled) ?? false;
}

Future<bool> isLocationServiceRunning() async {
  return _positionSubscription != null ||
      (await FlutterBackgroundService().isRunning());
}
