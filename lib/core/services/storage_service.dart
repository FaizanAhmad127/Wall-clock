import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/alarm/models/alarm_model.dart';

/// Interface for storage operations (Dependency Inversion Principle)
abstract class IStorageService {
  Future<void> initialize();
  Future<List<AlarmModel>> loadAlarms();
  Future<void> saveAlarms(List<AlarmModel> alarms);
  Future<void> clearAlarms();
  Future<void> dispose();
}

/// Concrete implementation of storage service using SharedPreferences
class StorageService implements IStorageService {
  static const String _alarmsKey = 'saved_alarms';
  SharedPreferences? _prefs;

  @override
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  Future<List<AlarmModel>> loadAlarms() async {
    try {
      final alarmsJson = _prefs?.getStringList(_alarmsKey) ?? [];
      return alarmsJson
          .map((alarmString) => AlarmModel.fromJson(json.decode(alarmString)))
          .toList();
    } catch (e) {
      print('StorageService: Error loading alarms: $e');
      return [];
    }
  }

  @override
  Future<void> saveAlarms(List<AlarmModel> alarms) async {
    try {
      final alarmsJson =
          alarms.map((alarm) => json.encode(alarm.toJson())).toList();
      await _prefs?.setStringList(_alarmsKey, alarmsJson);
    } catch (e) {
      print('StorageService: Error saving alarms: $e');
    }
  }

  @override
  Future<void> clearAlarms() async {
    try {
      await _prefs?.remove(_alarmsKey);
    } catch (e) {
      print('StorageService: Error clearing alarms: $e');
    }
  }

  @override
  Future<void> dispose() async {
    // SharedPreferences doesn't need explicit disposal
    _prefs = null;
  }
}
