import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';
import '../../domain/enums/notification_catalog.dart';
import '../../domain/enums/notification_event.dart';
import 'package:grc_module/core/enums/app_module.dart';
import 'package:grc_module/core/enums/template_variable.dart';

class NotificationTemplateService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionPath = 'notification_templates';

  // ✅ Get template by module and event type (NO notificationType parameter needed now)
  Future<NotificationTemplateModel?> getTemplate({
    required String module,
    required String eventType,
  }) async {
    try {
      final templateId = '${module}_$eventType';
      print('📥 Fetching template: $templateId');

      final doc = await _firestore
          .collection(_collectionPath)
          .doc(templateId)
          .get();

      if (doc.exists) {
        final template = NotificationTemplateModel.fromFirestore(doc);
        print('✅ Template found: ${template.subjectEnglish}');
        print('✅ Selected types: ${template.selectedNotificationTypes}');
        return template;
      } else {
        print('⚠️ Template not found: $templateId');
        // Return default template if not found
        return _getDefaultTemplate(module: module, eventType: eventType);
      }
    } catch (e) {
      print('❌ Error fetching template: $e');
      return null;
    }
  }

  // Get all templates for a module
  Future<List<NotificationTemplateModel>> getTemplatesByModule(String module) async {
    try {
      print('📥 Fetching templates for module: $module');

      final querySnapshot = await _firestore
          .collection(_collectionPath)
          .where('module', isEqualTo: module)
          .get();

      final templates = querySnapshot.docs
          .map((doc) => NotificationTemplateModel.fromFirestore(doc))
          .toList();

      print('✅ Found ${templates.length} templates for $module');
      return templates;
    } catch (e) {
      print('❌ Error fetching templates: $e');
      return [];
    }
  }

  // ✅ Save or update template with selected notification types
  Future<bool> saveTemplate(NotificationTemplateModel template) async {
    try {
      print('💾 Saving template: ${template.id}');
      print('💾 Selected types: ${template.selectedNotificationTypes}');

      final updatedTemplate = template.copyWith(
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection(_collectionPath)
          .doc(template.id)
          .set(updatedTemplate.toFirestore(), SetOptions(merge: true));

      print('✅ Template saved successfully');
      return true;
    } catch (e) {
      print('❌ Error saving template: $e');
      return false;
    }
  }

  // ✅ Update only selected notification types
  Future<bool> updateSelectedNotificationTypes({
    required String module,
    required String eventType,
    required List<String> selectedTypes,
  }) async {
    try {
      final templateId = '${module}_$eventType';
      print('🔄 Updating notification types for: $templateId');
      print('🔄 New types: $selectedTypes');

      await _firestore
          .collection(_collectionPath)
          .doc(templateId)
          .set({
        'selectedNotificationTypes': selectedTypes,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      }, SetOptions(merge: true));

      print('✅ Notification types updated successfully');
      return true;
    } catch (e) {
      print('❌ Error updating notification types: $e');
      return false;
    }
  }

  // Delete template
  Future<bool> deleteTemplate(String templateId) async {
    try {
      print('🗑️ Deleting template: $templateId');

      await _firestore
          .collection(_collectionPath)
          .doc(templateId)
          .delete();

      print('✅ Template deleted successfully');
      return true;
    } catch (e) {
      print('❌ Error deleting template: $e');
      return false;
    }
  }

  // ✅ Reset to default template
  Future<bool> resetToDefault({
    required String module,
    required String eventType,
  }) async {
    try {
      final defaultTemplate = _getDefaultTemplate(
        module: module,
        eventType: eventType,
      );

      if (defaultTemplate != null) {
        return await saveTemplate(defaultTemplate);
      }
      return false;
    } catch (e) {
      print('❌ Error resetting template: $e');
      return false;
    }
  }

  // ✅ Get default template from the module event catalog.
  //
  // Was an 830-line hand-maintained switch that had to be kept in sync with
  // the hardcoded list in notification_control.dart. Both now read the same
  // per-module event enums (domain/enums/<module>_module/), so a new
  // is added in exactly one place.
  NotificationTemplateModel? _getDefaultTemplate({
    required String module,
    required String eventType,
  }) {
    final event = NotificationCatalog.findByKeys(
      moduleKey: module,
      eventKey: eventType,
    );
    if (event == null) {
      print('⚠️ No catalog entry for template: ${module}_$eventType');
      return null;
    }
    return templateFromEvent(event);
  }

  /// Build a template model straight from a catalog event. Public so the
  /// Notification Control screen can render rows before Firestore answers.
  NotificationTemplateModel templateFromEvent(
    NotificationEvent event, {
    List<String>? selectedNotificationTypes,
    bool isEnabled = true,
  }) {
    final now = DateTime.now();
    return NotificationTemplateModel(
      id: event.templateId,
      module: event.module.key,
      eventType: event.key,
      isEnabled: isEnabled,
      // Default: Email and Push enabled for most notifications.
      selectedNotificationTypes:
          selectedNotificationTypes ?? const ['email', 'push'],
      subjectEnglish: event.titleEn,
      subjectArabic: event.titleAr,
      bodyEnglish: event.bodyEn,
      bodyArabic: event.bodyAr,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Seed / repair Firestore for a whole module: writes any template
  /// document that does not exist yet, leaving admin-edited ones untouched.
  Future<int> seedModuleDefaults(AppModule module) async {
    var written = 0;
    for (final event in NotificationCatalog.eventsOf(module)) {
      final doc =
          await _firestore.collection(_collectionPath).doc(event.templateId).get();
      if (doc.exists) continue;
      if (await saveTemplate(templateFromEvent(event))) written++;
    }
    print('🌱 Seeded $written default templates for ${module.key}');
    return written;
  }


  // Process template variables (replace placeholders)
  String processTemplate(String template, Map<String, String> variables) {
    String result = template;
    variables.forEach((key, value) {
      result = result.replaceAll('{{$key}}', value);
    });
    return result;
  }

  /// Type-safe variant — no raw placeholder strings at call sites.
  /// `processTemplateVars(t, {TemplateVariable.serviceName: name})`
  String processTemplateVars(
    String template,
    Map<TemplateVariable, String> variables,
  ) =>
      processTemplate(template, variables.toTemplateVariables());
}