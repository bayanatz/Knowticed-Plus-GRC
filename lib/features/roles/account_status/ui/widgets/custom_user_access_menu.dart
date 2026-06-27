import 'package:flutter/material.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:get/get.dart';
import 'package:demo_app/features/roles/widgets/dialogs/reschedule_dialog.dart';
import 'package:demo_app/features/roles/core_widgets/main_widget/custom_schedule_or_now_dialog.dart';
import 'package:demo_app/features/roles/core_widgets/dialogs/response_dialog.dart';


import 'package:demo_app/core/theme/app_font_size.dart';
import 'package:demo_app/features/onboarding/presentation/ui/pages/onboarding.dart';

class CustomUserAccessMenu {
  String? selectedOption;
  bool isSortSelected = false;

  Future<void> showSortMenu(
    BuildContext context,
    Offset iconPosition,
    String status,
    Function(String) onDateTimeSelected,
    Function(String) onButtonPressed,
  ) async {
    List<String> sortOptions = _getOptionsForStatus(status);
    if (sortOptions.isEmpty) {
      // Handle the case where no options are available for the given status
      return;
    }
    final isTablet = MediaQuery.of(context).size.shortestSide > 600;
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final double menuOffsetX = iconPosition.dx - (isTablet ? -9.0 : -11);
    final double menuOffsetY = iconPosition.dy - (-7.0);

    final RelativeRect position = RelativeRect.fromLTRB(
      menuOffsetX,
      menuOffsetY,
      overlay.size.width - menuOffsetX,
      overlay.size.height,
    );

    selectedOption = await showMenu(
      shadowColor: Colors.transparent,
      elevation: 0,
      context: context,
      position: position,
      color: themeController.currentTheme == AppColors.lightTheme
          ? AppColors.colorLightGrey
          : AppColors.colorBlack,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      items: sortOptions.map((option) {
        return PopupMenuItem<String>(
          height: isTablet ? 0.02.h : 0.03.h,
          padding:
              EdgeInsets.symmetric(horizontal: isTablet ? 0.01.w : 0.002.w),
          value: option,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                option.tr,
                style: AppFontStyle.cairoRegularStyle.copyWith(
                  fontSize: isTablet
                      ? (isPortrait
                          ? FontConstants.fontSize014.h
                          : FontConstants.fontSize015.w)
                      : FontConstants.fontSize016.h,
                  height: isTablet ? (isPortrait ? 2 : 1.6) : 1.8,
                  color: Theme.of(context).colorScheme.scrim,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );

    if (selectedOption != null) {
      switch (selectedOption!) {
        case "Deactivate Account":
          _showDeactivateDialog(context, onDateTimeSelected, onButtonPressed);
          break;
        case "Reactivate Account":
          _showReactivateDialog(context, onDateTimeSelected, onButtonPressed);
          break;
        case "Reschedule Deactivation Date":
          _showRescheduleDeactivationDialog(
              context, onDateTimeSelected, onButtonPressed);
          break;
        case "Deactivate Now":
          _showDeactivateNowDialog(
              context, onDateTimeSelected, onButtonPressed);
          break;
        case "Cancel Deactivation":
          _showCancelDeactivationDialog(
              context, onDateTimeSelected, onButtonPressed);
          break;
        case "Reschedule Reactivation Date":
          _showRescheduleReactivationDialog(
              context, onDateTimeSelected, onButtonPressed);
          break;
        case "Reactivate Now":
          _showReactivateNowDialog(
              context, onDateTimeSelected, onButtonPressed);
          break;
        case "Cancel Reactivation":
          _showCancelReactivationDialog(
              context, onDateTimeSelected, onButtonPressed);
          break;
        case "Unlock Account":
          _showUnlockDialog(context, onDateTimeSelected, onButtonPressed);
          break;
      }
    }
  }

  List<String> _getOptionsForStatus(String status) {
    switch (status) {
      case "active":
        return ["Deactivate Account"];
      case "deactivated":
        return ["Reactivate Account"];
      case "inactive":
        return ["Deactivate Account"];
      case "Deactivation At":
        return [
          "Reschedule Deactivation Date",
          "Deactivate Now",
          "Cancel Deactivation"
        ];
      case "Deactivated For Now":
        return [
          "Reschedule Reactivation Date",
          "Reactivate Now",
          "Cancel Reactivation"
        ];
      case "locked":
        return ["Unlock Account"];
      default:
        return [];
    }
  }

  void _showDeactivateDialog(BuildContext context,
      Function(String) onDateTimeSelected, Function(String) onButtonPressed)
  {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomScheduleOrNowDialog(
          titleText: 'Deactivate Account',
          bodyText: 'When Do You Want To Deactivate This Account ?',
          onDateTimeSelected: onDateTimeSelected,
          // onDailogPressed: onButtonPressed('Deactivate Account'),
          yesOnPressed: () {
            onButtonPressed('Deactivate Account');
            Navigator.of(context).pop();
            showDialog(
                context: context,
                builder: (context) {
                  return const ResponseDialog(
                    title: "Done",
                    subtitle: "You Successfully Reactivated This Account",
                    lottieAsset: "assets/images/correct.json",
                  );
                });
          },
        );
      },
    );
  }

  void _showReactivateDialog(BuildContext context,
      Function(String) onDateTimeSelected, Function(String) onButtonPressed) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomScheduleOrNowDialog(
          titleText: 'Reactivate Account',
          bodyText: 'When Do You Want To Reactivate This Account ?',
          onDateTimeSelected: onDateTimeSelected,
          //  onDailogPressed: onButtonPressed('FFDSFSD'),
          yesOnPressed: () {
            onButtonPressed('Reactivate Account');
            Navigator.of(context).pop();
            showDialog(
                context: context,
                builder: (context) {
                  return const ResponseDialog(
                    title: "Done",
                    subtitle: "You Successfully Reactivated This Account",
                    lottieAsset: "assets/images/correct.json",
                  );
                });
          },
        );
      },
    );
  }

  void _showRescheduleDeactivationDialog(BuildContext context,
      Function(String) onDateTimeSelected, Function(String) onButtonPressed) {
    showDialog(
        context: context,
        builder: (context) {
          return RescheduleDialog(
            dialogName: "Deactivation",
            confirmationDialogBody:
                "Are You Sure You Want To Deactivate This Account At",
            onDateTimeSelected: onDateTimeSelected,
            onButtonPressed: () {},
          );
        });
  }

  void _showDeactivateNowDialog(BuildContext context,
      Function(String) onDateTimeSelected, Function(String) onButtonPressed) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomScheduleOrNowDialog(
          titleText: 'Deactivate Now',
          isNow: true,
          bodyText: 'Are You Sure You Want To Deactivate This Account Now?',
          onDateTimeSelected: onDateTimeSelected,
          //  onDailogPressed: onButtonPressed('Deactivate Now'),
          yesOnPressed: () {
            onButtonPressed('Deactivate Now');
            Navigator.of(context).pop();
            showDialog(
                context: context,
                builder: (context) {
                  return const ResponseDialog(
                    title: "Done",
                    subtitle: "You Successfully Deactivated This Account",
                    lottieAsset: "assets/images/correct.json",
                  );
                });
          },
        );
      },
    );
  }

  void _showCancelDeactivationDialog(BuildContext context,
      Function(String) onDateTimeSelected, Function(String) onButtonPressed) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomScheduleOrNowDialog(
          titleText: 'Cancel Deactivation',
          isNow: true,
          bodyText:
              'Are You Sure You Want To Cancel Deactivation Of This Account Now?',
          onDateTimeSelected: onDateTimeSelected,
          //  onDailogPressed: onButtonPressed('Cancel Deactivation'),
          yesOnPressed: () {
            onButtonPressed('Cancel Deactivation');
            Navigator.of(context).pop();
            showDialog(
                context: context,
                builder: (context) {
                  return const ResponseDialog(
                    title: "Done",
                    subtitle:
                        "You Successfully Canceled Deactivation Of This Account",
                    lottieAsset: "assets/images/correct.json",
                  );
                });
          },
        );
      },
    );
  }

  void _showRescheduleReactivationDialog(BuildContext context,
      Function(String) onDateTimeSelected, Function(String) onButtonPressed) {
    showDialog(
        context: context,
        builder: (context) {
          return RescheduleDialog(
            dialogName: "Reactivation",
            confirmationDialogBody:
                "Are You Sure You Want To Reactivate This Account At",
            onDateTimeSelected: onDateTimeSelected,
            onButtonPressed: () {},
          );
        });
  }

  void _showReactivateNowDialog(BuildContext context,
      Function(String) onDateTimeSelected, Function(String) onButtonPressed) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomScheduleOrNowDialog(
          titleText: 'Reactivate Now',
          isNow: true,
          bodyText: 'Are You Sure You Want To Reactivate This Account Now?',
          onDateTimeSelected: onDateTimeSelected,
          //   onDailogPressed: onButtonPressed('Reactivate Now'),
          yesOnPressed: () {
            onButtonPressed('Reactivate Now');
            Navigator.of(context).pop();
            showDialog(
                context: context,
                builder: (context) {
                  return const ResponseDialog(
                    title: "Done",
                    subtitle: "You Successfully Reactivated This Account",
                    lottieAsset: "assets/images/correct.json",
                  );
                });
          },
        );
      },
    );
  }

  void _showCancelReactivationDialog(BuildContext context,
      Function(String) onDateTimeSelected, Function(String) onButtonPressed) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomScheduleOrNowDialog(
          titleText: 'Cancel Reactivation',
          isNow: true,
          bodyText:
              'Are You Sure You Want To Cancel Reactivation Of This Account Now?',
          onDateTimeSelected: onDateTimeSelected,
          //   onDailogPressed: onButtonPressed('Cancel Reactivation'),
          yesOnPressed: () {
            onButtonPressed('Cancel Reactivation');
            Navigator.of(context).pop();
            showDialog(
                context: context,
                builder: (context) {
                  return const ResponseDialog(
                    title: "Done",
                    subtitle:
                        "You Successfully Canceled Reactivation Of This Account",
                    lottieAsset: "assets/images/correct.json",
                  );
                });
          },
        );
      },
    );
  }

  void _showUnlockDialog(BuildContext context,
      Function(String) onDateTimeSelected, Function(String) onButtonPressed) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomScheduleOrNowDialog(
          titleText: 'Unlock Account',
          isNow: true,
          bodyText: 'Are You Sure You Want To Unlock This Account Now?',
          onDateTimeSelected: onDateTimeSelected,
          //  onDailogPressed: onButtonPressed('Unlock Account'),
          yesOnPressed: () {
            onButtonPressed('Unlock Account');
            Navigator.of(context).pop();
            showDialog(
                context: context,
                builder: (context) {
                  return const ResponseDialog(
                    title: "Done",
                    subtitle: "You Successfully Unlocked This Account",
                    lottieAsset: "assets/images/correct.json",
                  );
                });
          },
        );
      },
    );
  }
}
