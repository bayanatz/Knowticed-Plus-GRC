import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:grc_module/core/constants/quotes_list.dart';
import 'package:grc_module/features/home/h3_app_drawer/presentation/controller/app_drawer_cubit.dart';
import 'package:grc_module/features/home/h2_nav_bar/presentation/controller/nav_bar_cubit.dart';
import 'package:grc_module/core/helper/role/modules_enum.dart';
import 'package:grc_module/features/roles/r1_role_management/presentation/controller/modules_cubit.dart';
import 'package:grc_module/features/home/h1_home_page/presentation/controller/schedule_controller.dart';
import 'package:grc_module/core/helper/main_helper/format_title.dart';

part './skeleton_home_state.dart';

/// Converted from GetxController to Cubit.
///
/// Dependency lookup still goes through GetX (`Get.put` in
/// home_responsive_page, `Get.find` at the call sites) — only the state
/// mechanism changed. Note the former `onInit()` hook now runs from the
/// constructor: GetX does not drive lifecycle callbacks on a Cubit, so the
/// quote/module initialisation would otherwise never fire.
class SkeletonHomeController extends Cubit<SkeletonHomeState> {
  SkeletonHomeController() : super(SkeletonHomeInitial()) {
    getHomeQuote();
    initModules();
    emit(SkeletonHomeReady());
  }

  String quote = "";
  String author = "";
  List<Modules> modules = [];

  List<DateTime?> selectedDate = [DateTime.now()];

  /// Method Name: [getCurrentDate]
  ///
  /// Purpose: This method is used to get the current date in the format of 'dd MMMM yyyy' in English and Arabic.
  ///
  /// return type: [String]
  String getCurrentDate() {
    initializeDateFormatting('ar');
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('dd MMMM yyyy').format(now);
    DateFormat arabicFormat = DateFormat.yMMMMd('ar');
    String arabicDate = arabicFormat.format(now);
    return Get.locale.toString().contains('en') ? formattedDate : arabicDate;
  }

  /// Method Name: [getQuoteForToday]
  ///
  /// Purpose: This method is used to get the quote for the current date.
  getHomeQuote() {
    String quoteAndAuthor = Get.locale.toString().contains('en')
        ? FormatHelper.capitalize(getQuoteForToday())
        : getQuoteForToday();
    List<String> splitQuote = quoteAndAuthor.split(' - ');
    quote = splitQuote[0];
    author = splitQuote.length > 1 ? splitQuote[1] : "Unknown";
  }

  initModules() {
    try {
      modules = Get.find<AppDrawerCubit>().allowedDrawerModules;
    } catch (e) {
      modules = Get.find<NavBarCubit>().navBarModules;
    }
  }
}
