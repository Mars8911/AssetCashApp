// lib/services/location_service_stub.dart
// Web 平台用 stub：定位服務僅支援 Android/iOS

Future<void> initializeLocationService() async {
  // Web 不支援背景定位，略過
}

Future<void> startLocationTracking() async {
  // Web 不支援
}

Future<void> stopLocationTracking() async {
  // Web 不支援
}

Future<bool> isLocationTrackingEnabled() async => false;

Future<bool> isLocationServiceRunning() async => false;
