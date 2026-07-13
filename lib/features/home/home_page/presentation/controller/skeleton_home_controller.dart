import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:demo_app/core/constants/quotes_list.dart';
import 'package:demo_app/core/enums/enum.dart';
import 'package:demo_app/features/home/app_drawer/presentation/controller/drawer_controller.dart';
import 'package:demo_app/features/home/nav_bar/presentation/controller/nav_bar_controller.dart';
import 'package:demo_app/features/roles/role_management/domain/enums/modules_enum.dart';
import 'package:demo_app/features/roles/role_management/controller/modules_controller.dart';
import 'package:demo_app/features/home/home_page/presentation/controller/schedule_controller.dart';

class SkeletonHomeController extends GetxController {
  String quote = "";
  String author = "";
  List<Modules> modules = [];
  @override
  onInit() {
    super.onInit();
    getHomeQuote();
    initModules();

  }

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
        ? capitalize(getQuoteForToday())
        : getQuoteForToday();
    List<String> splitQuote = quoteAndAuthor.split(' - ');
    quote = splitQuote[0];
    author = splitQuote.length > 1 ? splitQuote[1] : "Unknown";
  }

  initModules() {
    try {
      modules = Get.find<AppDrawerController>().allowedDrawerModules;
    } catch (e) {
      modules = Get.find<NavBarController>().navBarModules;
    }
  }
}
