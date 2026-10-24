import 'package:get/get.dart';
import 'package:knowticed_plus/core/helper/access/modules_enum.dart';
import 'package:knowticed_plus/features/roles/r5_system_logs/presentation/controller/system_logs_controller.dart';

class QiyasLogService {
  static void log(String action) {
    try {
      Get.find<SystemLogsController>()
          .systemLogsAction(action, module: Modules.qiyas);
    } catch (_) {}
  }
}
