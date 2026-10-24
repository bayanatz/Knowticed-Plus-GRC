/// Module: settings/se6_requests
///
///*************************** FILE INFO ****************************///
/// File Name: request_page.dart
/// Description: The employee's own list of change requests.
/// Author: Amr Mesbah
/// Created at: 13/11/2024
/// Updated: 11/8/2026 - CR-SKEL-SE6-N01/N02/N04/N06/N12: the Firestore query, the document parsing
///          and the try/catch moved into RequestsCubit/ChangeRequestMapper;
///          Get.snackbar replaced with a themed SnackBar; raw colours route
///          through AppColors; `Get.locale` replaced with
///          `Localizations.localeOf(context)`.
library;

import 'package:knowticed_plus/core/custom/buttons/custom_button_sizing.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_search_widget_custom.dart';
import 'package:knowticed_plus/features/settings/se6_requests/presentation/ui/pages/request_section_label.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_sort_button.dart';
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
// navigate helpers (inlined from removed inventory_module)
import 'package:knowticed_plus/core/theme/app_colors.dart';
// REMOVED_MODULE: import 'package:knowticed_plus/features/external/services_mangment_module/Category/presentation/ui/service_department_manager/tablet/s2_details_service/details_service/widget/info_text.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/features/settings/se6_requests/domain/entities/change_request.dart';
import 'package:knowticed_plus/features/settings/se6_requests/domain/entities/field_change.dart';
import 'package:knowticed_plus/features/settings/se6_requests/presentation/controller/requests_cubit.dart';
import 'package:knowticed_plus/features/settings/se6_requests/presentation/ui/pages/details_request.dart';

import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:knowticed_plus/core/extensions/context_extensions.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';

part '../widgets/request_page/my_request_page_builders.dart';
part '../widgets/request_page/my_request_page_builders_2.dart';
part '../widgets/request_page/my_request_page_logic.dart';

/// Returns the route's Future so callers can await the pop and refresh. The
/// details screen can change a request's status, and this list groups and
/// counts by status — without re-fetching on return it keeps showing whatever
/// initState loaded.
Future<T?> navigateTo<T>(BuildContext context, Widget widget) =>
    Navigator.push<T>(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => widget,
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );

class MyRequestPage extends StatefulWidget {
  const MyRequestPage({super.key});

  @override
  State<MyRequestPage> createState() => _MyRequestPageState();
}

/// Sort order for the requests list, applied to `dateRequested`.
///
/// Null (nothing selected) leaves the list in the order the cubit returned it,
/// which is what CustomSortButton's toggle produces when the active option is
/// tapped a second time.
enum RequestDateSort { ascending, descending }

class _MyRequestPageState extends State<MyRequestPage> {
  /// Lets this screen's builder/logic extensions refresh it (setState
  /// itself may only be called inside the State class).
  void rebuild(VoidCallback fn) => setState(fn);

  /// Canonical status key (see kAll / kApproved / … below), not a display label.
  String selectStatus = kAll;

  List<Map<String, dynamic>> allRequests = [];
  List<Map<String, dynamic>> filteredRequests = [];

  /// Active sort, or null for "unsorted" (see [RequestDateSort]).
  RequestDateSort? _sortOrder;

  /// Owned by this page; the requests list is its whole reason to exist.
  final RequestsCubit _requestsCubit = RequestsCubit();

  TextEditingController searchController = TextEditingController();

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRequests();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    _requestsCubit.close();
    super.dispose();
  }

  void _onSearchChanged() {
    _filterRequests();
  }

  /// Canonical status keys. Firestore holds both spellings of cancelled
  /// depending on which screen wrote the record, so everything funnels through
  /// here before being compared or counted.
  static const String kAll = 'All';
  static const String kApproved = 'approved';
  static const String kPending = 'pending';
  static const String kRejected = 'rejected';
  static const String kCancelled = 'cancelled';

  @override
  Widget build(BuildContext context) => _buildView(context);
}
