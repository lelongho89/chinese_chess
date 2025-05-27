import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../global.dart';

/// Service for managing device-specific identifiers for anonymous users
class DeviceIdService {
  static const String _deviceIdKey = 'anonymous_device_id';
  static const String _deviceInfoKey = 'device_info';
  
  static DeviceIdService? _instance;
  static DeviceIdService get instance => _instance ??= DeviceIdService._();
  
  DeviceIdService._();
  
  SharedPreferences? _prefs;
  String? _cachedDeviceId;
  Map<String, dynamic>? _cachedDeviceInfo;
  
  /// Initialize the service
  Future<void> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      logger.info('DeviceIdService initialized');
    } catch (e) {
      logger.severe('Error initializing DeviceIdService: $e');
      rethrow;
    }
  }
  
  /// Get or generate a unique device identifier for anonymous users
  Future<String> getDeviceId() async {
    if (_cachedDeviceId != null) {
      return _cachedDeviceId!;
    }
    
    try {
      // Try to get existing device ID from local storage
      final existingId = _prefs?.getString(_deviceIdKey);
      if (existingId != null && existingId.isNotEmpty) {
        _cachedDeviceId = existingId;
        logger.info('Retrieved existing device ID: ${existingId.substring(0, 8)}...');
        return existingId;
      }
      
      // Generate new device ID based on device info + UUID
      final deviceId = await _generateDeviceId();
      
      // Store the device ID locally
      await _prefs?.setString(_deviceIdKey, deviceId);
      _cachedDeviceId = deviceId;
      
      logger.info('Generated new device ID: ${deviceId.substring(0, 8)}...');
      return deviceId;
    } catch (e) {
      logger.severe('Error getting device ID: $e');
      // Fallback to pure UUID if device info fails
      final fallbackId = const Uuid().v4();
      await _prefs?.setString(_deviceIdKey, fallbackId);
      _cachedDeviceId = fallbackId;
      return fallbackId;
    }
  }
  
  /// Generate a device-specific identifier
  Future<String> _generateDeviceId() async {
    final deviceInfoPlugin = DeviceInfoPlugin();
    String deviceIdentifier;
    
    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfoPlugin.androidInfo;
        // Use Android ID as base (unique per device + app combination)
        deviceIdentifier = androidInfo.id ?? '';
        
        // Store additional device info for debugging
        _cachedDeviceInfo = {
          'platform': 'android',
          'model': androidInfo.model,
          'brand': androidInfo.brand,
          'device': androidInfo.device,
          'androidId': androidInfo.id,
        };
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfoPlugin.iosInfo;
        // Use identifierForVendor as base (unique per vendor + device)
        deviceIdentifier = iosInfo.identifierForVendor ?? '';
        
        // Store additional device info for debugging
        _cachedDeviceInfo = {
          'platform': 'ios',
          'model': iosInfo.model,
          'name': iosInfo.name,
          'systemName': iosInfo.systemName,
          'systemVersion': iosInfo.systemVersion,
          'identifierForVendor': iosInfo.identifierForVendor,
        };
      } else {
        // Fallback for other platforms
        deviceIdentifier = '';
        _cachedDeviceInfo = {
          'platform': Platform.operatingSystem,
        };
      }
      
      // Store device info locally for debugging
      if (_cachedDeviceInfo != null) {
        await _prefs?.setString(_deviceInfoKey, _cachedDeviceInfo.toString());
      }
      
      // If we couldn't get a device identifier, generate a UUID
      if (deviceIdentifier.isEmpty) {
        deviceIdentifier = const Uuid().v4();
        logger.warning('Could not get platform device ID, using UUID: ${deviceIdentifier.substring(0, 8)}...');
      } else {
        // Combine device identifier with a UUID for additional uniqueness
        // This ensures we have a unique ID even if device ID changes
        final uuid = const Uuid().v4();
        deviceIdentifier = '${deviceIdentifier}_$uuid';
      }
      
      return deviceIdentifier;
    } catch (e) {
      logger.severe('Error generating device ID: $e');
      // Fallback to pure UUID
      return const Uuid().v4();
    }
  }
  
  /// Get device information for debugging
  Future<Map<String, dynamic>?> getDeviceInfo() async {
    if (_cachedDeviceInfo != null) {
      return _cachedDeviceInfo;
    }
    
    try {
      final deviceInfoPlugin = DeviceInfoPlugin();
      
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfoPlugin.androidInfo;
        _cachedDeviceInfo = {
          'platform': 'android',
          'model': androidInfo.model,
          'brand': androidInfo.brand,
          'device': androidInfo.device,
          'androidId': androidInfo.id,
          'version': androidInfo.version.release,
        };
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfoPlugin.iosInfo;
        _cachedDeviceInfo = {
          'platform': 'ios',
          'model': iosInfo.model,
          'name': iosInfo.name,
          'systemName': iosInfo.systemName,
          'systemVersion': iosInfo.systemVersion,
          'identifierForVendor': iosInfo.identifierForVendor,
        };
      } else {
        _cachedDeviceInfo = {
          'platform': Platform.operatingSystem,
        };
      }
      
      return _cachedDeviceInfo;
    } catch (e) {
      logger.severe('Error getting device info: $e');
      return null;
    }
  }
  
  /// Clear stored device ID (for testing or profile deletion)
  Future<void> clearDeviceId() async {
    try {
      await _prefs?.remove(_deviceIdKey);
      await _prefs?.remove(_deviceInfoKey);
      _cachedDeviceId = null;
      _cachedDeviceInfo = null;
      logger.info('Device ID cleared');
    } catch (e) {
      logger.severe('Error clearing device ID: $e');
      rethrow;
    }
  }
  
  /// Check if device ID exists locally
  Future<bool> hasStoredDeviceId() async {
    try {
      final existingId = _prefs?.getString(_deviceIdKey);
      return existingId != null && existingId.isNotEmpty;
    } catch (e) {
      logger.severe('Error checking stored device ID: $e');
      return false;
    }
  }
}
