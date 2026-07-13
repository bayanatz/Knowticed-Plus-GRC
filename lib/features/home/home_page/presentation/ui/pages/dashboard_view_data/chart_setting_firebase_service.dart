import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_app/features/home/home_page/presentation/ui/pages/dashboard_view_data/chart_orientation_enum.dart';

/// Service to handle chart orientation settings in Firebase
///
/// Firebase Structure:
/// /Demo/84763782/Chart_View/{email as doc ID}
/// {
///   "services_services_offered": "horizontal",
///   "services_number_of_services": "vertical",
///   "updatedAt": timestamp
/// }
class ChartSettingsFirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Collection path (not including document)
  static const String collectionPath = 'Demo/84763782/Chart_View';

  /// Build chart field key: module_chartId
  /// Example: services_services_offered
  String _buildChartKey(String module, String chartId) {
    return '${module}_$chartId';
  }

  /// Save chart orientation to Firebase
  /// [email] - User email from employeeFunctionHelper.email (used as document ID)
  /// [module] - Module name (e.g., 'services')
  /// [chartId] - Chart identifier (e.g., 'services_offered')
  /// [orientation] - Chart orientation (horizontal or vertical)
  Future<void> saveChartOrientation({
    required String email,
    required String module,
    required String chartId,
    required ChartOrientation orientation,
  }) async {
    try {
      print('💾 [CHART_SETTINGS] Saving chart orientation...');
      print('💾 [CHART_SETTINGS] Collection: $collectionPath');
      print('💾 [CHART_SETTINGS] Document ID (Email): $email');
      print('💾 [CHART_SETTINGS] Module: $module');
      print('💾 [CHART_SETTINGS] Chart ID: $chartId');
      print('💾 [CHART_SETTINGS] Orientation: ${orientation.name}');

      final chartKey = _buildChartKey(module, chartId);

      await _firestore
          .collection(collectionPath)
          .doc(email)
          .set({
        chartKey: orientation.toFirestore(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print('✅ [CHART_SETTINGS] Chart orientation saved successfully');
      print('✅ [CHART_SETTINGS] Path: $collectionPath/$email');
      print('✅ [CHART_SETTINGS] Saved as field: $chartKey = ${orientation.toFirestore()}');
    } catch (e, stackTrace) {
      print('❌ [CHART_SETTINGS] Error saving chart orientation: $e');
      print('❌ [CHART_SETTINGS] StackTrace: $stackTrace');
      rethrow;
    }
  }

  /// Get chart orientation from Firebase
  /// Returns the stored orientation or null if not found
  Future<ChartOrientation?> getChartOrientation({
    required String email,
    required String module,
    required String chartId,
  }) async {
    try {
      print('📖 [CHART_SETTINGS] Loading chart orientation...');
      print('📖 [CHART_SETTINGS] Collection: $collectionPath');
      print('📖 [CHART_SETTINGS] Document ID (Email): $email');
      print('📖 [CHART_SETTINGS] Module: $module');
      print('📖 [CHART_SETTINGS] Chart ID: $chartId');

      final chartKey = _buildChartKey(module, chartId);

      final doc = await _firestore
          .collection(collectionPath)
          .doc(email)
          .get();

      if (!doc.exists) {
        print('⚠️ [CHART_SETTINGS] No saved settings found for user');
        print('⚠️ [CHART_SETTINGS] Path: $collectionPath/$email (does not exist)');
        return null;
      }

      final data = doc.data();
      if (data == null || !data.containsKey(chartKey)) {
        print('⚠️ [CHART_SETTINGS] No saved orientation for chart: $chartKey');
        return null;
      }

      final orientationStr = data[chartKey] as String;
      final orientation = ChartOrientation.fromFirestore(orientationStr);

      print('✅ [CHART_SETTINGS] Loaded orientation: ${orientation.name}');
      print('✅ [CHART_SETTINGS] From path: $collectionPath/$email');
      return orientation;
    } catch (e, stackTrace) {
      print('❌ [CHART_SETTINGS] Error loading chart orientation: $e');
      print('❌ [CHART_SETTINGS] StackTrace: $stackTrace');
      return null;
    }
  }

  /// Get all chart orientations for a module
  /// Returns a map of chartId -> orientation
  Future<Map<String, ChartOrientation>> getAllChartOrientations({
    required String email,
    required String module,
  }) async {
    try {
      print('📖 [CHART_SETTINGS] Loading all chart orientations for module: $module');
      print('📖 [CHART_SETTINGS] Path: $collectionPath/$email');

      final doc = await _firestore
          .collection(collectionPath)
          .doc(email)
          .get();

      if (!doc.exists) {
        print('⚠️ [CHART_SETTINGS] No saved settings found for user');
        return {};
      }

      final data = doc.data();
      if (data == null) {
        print('⚠️ [CHART_SETTINGS] Document exists but no data');
        return {};
      }

      final Map<String, ChartOrientation> orientations = {};
      final modulePrefix = '${module}_';

      // Filter fields that start with module prefix
      data.forEach((key, value) {
        if (key.startsWith(modulePrefix) && value is String) {
          // Extract chartId from key (remove module prefix)
          final chartId = key.substring(modulePrefix.length);
          orientations[chartId] = ChartOrientation.fromFirestore(value);
        }
      });

      print('✅ [CHART_SETTINGS] Loaded ${orientations.length} chart orientations');
      orientations.forEach((chartId, orientation) {
        print('   - $chartId: ${orientation.name}');
      });

      return orientations;
    } catch (e, stackTrace) {
      print('❌ [CHART_SETTINGS] Error loading all chart orientations: $e');
      print('❌ [CHART_SETTINGS] StackTrace: $stackTrace');
      return {};
    }
  }

  /// Delete chart orientation setting
  Future<void> deleteChartOrientation({
    required String email,
    required String module,
    required String chartId,
  }) async {
    try {
      final chartKey = _buildChartKey(module, chartId);

      await _firestore
          .collection(collectionPath)
          .doc(email)
          .update({
        chartKey: FieldValue.delete(),
      });

      print('✅ [CHART_SETTINGS] Chart orientation deleted: $chartKey');
      print('✅ [CHART_SETTINGS] From path: $collectionPath/$email');
    } catch (e) {
      print('❌ [CHART_SETTINGS] Error deleting chart orientation: $e');
      rethrow;
    }
  }

  /// Reset all chart orientations for a module to defaults
  Future<void> resetModuleChartOrientations({
    required String email,
    required String module,
  }) async {
    try {
      final doc = await _firestore
          .collection(collectionPath)
          .doc(email)
          .get();

      if (!doc.exists) {
        print('⚠️ [CHART_SETTINGS] No settings to reset');
        return;
      }

      final data = doc.data();
      if (data == null) {
        print('⚠️ [CHART_SETTINGS] No data to reset');
        return;
      }

      final Map<String, dynamic> updates = {};
      final modulePrefix = '${module}_';

      // Find all fields for this module and mark for deletion
      data.forEach((key, value) {
        if (key.startsWith(modulePrefix)) {
          updates[key] = FieldValue.delete();
        }
      });

      if (updates.isNotEmpty) {
        await _firestore
            .collection(collectionPath)
            .doc(email)
            .update(updates);

        print('✅ [CHART_SETTINGS] Reset ${updates.length} chart orientations for module: $module');
        print('✅ [CHART_SETTINGS] From path: $collectionPath/$email');
      } else {
        print('⚠️ [CHART_SETTINGS] No chart orientations found for module: $module');
      }
    } catch (e) {
      print('❌ [CHART_SETTINGS] Error resetting chart orientations: $e');
      rethrow;
    }
  }

  /// Get all settings for a user (all modules)
  Future<Map<String, dynamic>> getAllUserSettings({
    required String email,
  }) async {
    try {
      print('📖 [CHART_SETTINGS] Loading all user settings');
      print('📖 [CHART_SETTINGS] Path: $collectionPath/$email');

      final doc = await _firestore
          .collection(collectionPath)
          .doc(email)
          .get();

      if (!doc.exists) {
        print('⚠️ [CHART_SETTINGS] No settings found');
        return {};
      }

      print('✅ [CHART_SETTINGS] Loaded all user settings');
      return doc.data() ?? {};
    } catch (e) {
      print('❌ [CHART_SETTINGS] Error loading all user settings: $e');
      return {};
    }
  }
}