import 'package:demo_app/core/custom/1-custom_dropdwon.dart';
import 'package:demo_app/core/helper/todo_new_module/core_widgets/main_widget/side_frame_master.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' as intl;

import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:demo_app/core/helper/todo_new_module/core_widgets/main_widget/DatePicker.dart';

import 'package:demo_app/core/theme/app_font_weights.dart';
import 'package:demo_app/generated/l10n.dart';
import '../../../../../../../../inventory_module/core/text_field.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/features/employee/domain/entities/employee_entity.dart';
import 'package:demo_app/features/employee/presentation/controller/main_core_employee_controller.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';
import '../../../../../core/custom_widgets/CustomDialogManager.dart';
import '../../../../../core/custom_widgets/customIconButton.dart';
import '../../../../../core/custom_widgets/custom_button_widget.dart';
import '../../../../../core/custom_widgets/custom_pop_up_dialog_widget.dart';
import '../../../../../core/custom_widgets/custom_side_bar_widget.dart';
import '../../../../../core/custom_widgets/drop_down.dart';
import '../../../../../core/custom_widgets/svg_custom.dart';
import '../../../../../core/custom_widgets/text_field.dart';
import '../../../../../core/enums/frequency_enum.dart';
import '../../../../../core/enums/reminder_enum.dart';
import '../../../../../core/enums/task_priority_enum.dart';
import '../../../../../core/enums/task_status_enum.dart';
import '../../../../../core/utilties/images.dart';
import '../../../../data/models/frequency_model.dart';
import '../../../../data/models/reminder_model.dart';
import '../../../../data/models/schedule_data.dart';
import '../../../../data/models/task_model_updates_with_field_history.dart';
import '../../../../domain/services/task_services.dart';
import '../home_screen.dart';

class CreateToDoScreen extends StatefulWidget {
  final TaskModel? existingTask;

  bool get isEditing => existingTask != null;
  const CreateToDoScreen({Key? key, this.existingTask}) : super(key: key);
  static String routeName = '/CreateToDoScreen';

  @override
  State<CreateToDoScreen> createState() => _CreateToDoScreenState();
}

class _CreateToDoScreenState extends State<CreateToDoScreen> {
  final _formKey = GlobalKey<FormState>();
  final TaskFirebaseService _firebaseService = TaskFirebaseService();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  String _selectedPriority = 'Select';
  bool _isScheduled = false;
  DateTime? _startDate;
  TimeOfDay? _startTime;
  DateTime? _endDate;
  TimeOfDay? _endTime;

  bool _setFrequency = false;
  int _frequencyCount = 1;
  String _frequencyUnit = 'Select';
  Set<String> _selectedDays = {};

  List<ReminderData> _reminders = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.existingTask?.name.current ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.existingTask?.description.current ?? '',
    );

    if (widget.existingTask != null) {
      _selectedPriority = widget.existingTask!.priority.current ?? '';

      if (widget.existingTask!.currentScheduled != null) {
        _isScheduled = true;
        _startDate = widget.existingTask!.currentScheduled!.taskStartDate;
        _endDate = widget.existingTask!.currentScheduled!.taskEndDate;
        _startTime = TimeOfDay.fromDateTime(_startDate!);
        if (_endDate != null) _endTime = TimeOfDay.fromDateTime(_endDate!);
        _reminders = List.from(
          widget.existingTask!.currentScheduled!.reminders,
        );
      }

      if (widget.existingTask!.currentFrequency != null) {
        _setFrequency = true;
        _frequencyCount = widget.existingTask!.currentFrequency!.frequencyCount;
        _frequencyUnit = widget.existingTask!.currentFrequency!.frequencyUnit;
        _selectedDays =
            widget.existingTask!.currentFrequency!.selectedDays ?? {};
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime now = DateTime.now();
    final DateTime tomorrow = DateTime(now.year, now.month, now.day + 1);

    DateTime firstDate;
    DateTime lastDate;

    if (isStart) {
      firstDate = tomorrow;
      lastDate = _endDate ?? DateTime(2100);
    } else {
      firstDate = _startDate != null
          ? _startDate!.add(const Duration(days: 1))
          : tomorrow;
      lastDate = DateTime(2100);
    }

    final DateTime initialDate =
    isStart ? (_startDate ?? firstDate) : (_endDate ?? firstDate);

    // Use DatePicker class instead of showDatePicker
    final datePicker = DatePicker();
    final List<DateTime?>? result = await datePicker.showDatePicker(

      context,
      [initialDate], // Initial value as list
      initialDate,   // Current date
      CalendarDatePicker2Type.single, // Single date selection
     // firstDate: firstDate,
    );

    if (result != null && result.isNotEmpty && result[0] != null) {
      final picked = result[0]!;
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate != null && picked.isAfter(_endDate!)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  // ✅ REPLACE _selectTime method:
  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.dial,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData(
            brightness: Theme.of(context).brightness,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.background,
              brightness: Theme.of(context).brightness,
            ).copyWith(
              primary: AppColors.background,
              onPrimary: Colors.white,
              surface: AppColors.background,
              onSurface: Colors.white,
            ),
            // Remove hover effect globally for all interactive elements
            hoverColor: Colors.transparent,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            timePickerTheme: TimePickerThemeData(
              backgroundColor: AppColors.card,
              hourMinuteTextColor: AppColors.text,
              hourMinuteColor: AppColors.background,
              dayPeriodTextColor: WidgetStateColor.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return AppColors.textButton; // Selected AM/PM
                }
                return AppColors.text; // Unselected AM/PM
              }),
              dayPeriodColor: AppColors.primary,
              dialHandColor: AppColors.text,
              dialBackgroundColor: AppColors.background,
              dialTextColor: AppColors.secondaryText,
              entryModeIconColor: Colors.transparent,
              helpTextStyle: AppTextStyles.font18BlackMediumCairo.copyWith(
                color: Colors.transparent,
                fontSize: 0,
                height: 0,
              ),
              padding: EdgeInsets.all(15.sp),

              cancelButtonStyle: TextButton.styleFrom(
                minimumSize: Size(150.w, 38.h),
                fixedSize: Size(150.w, 38.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.r),
                ),
                foregroundColor: AppColors.textButton,
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                overlayColor: Colors.transparent,
              ),
              confirmButtonStyle: TextButton.styleFrom(
                minimumSize: Size(150.w, 38.h),
                fixedSize: Size(150.w, 38.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.r),
                ),
                foregroundColor: AppColors.textButton,
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                overlayColor: Colors.transparent,
              ),
            ),
            dialogTheme: DialogThemeData(
              actionsPadding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 16.h),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                alignment: Alignment.center,
                overlayColor: Colors.transparent,
              ),
            ),
          ),
          child: Directionality(
            textDirection: TextDirection.rtl, // Changed from rtl to ltr
            child: Align(
              alignment: Alignment.center,
              child: child!,
            ),
          ),
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  void _addReminder(String? unit, int count) {

    setState(() {
      _reminders.add(
        ReminderData(durationUnit: unit ?? '', durationCount: count),
      );
    });
  }

  void _showCreateTodoDialog(BuildContext context) {
    var isMobile = context.isPhone;
    var lightMode = Theme.of(context).brightness == Brightness.light;
    showDialog(

      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => CustomPopupDialogWithLottie(
        lottiePath: widget.existingTask != null
            ? Images.editToDoLottie
            : Images.createToDoLottie,
        title: widget.existingTask != null ? S.of(context).editingToDodialog: S.of(context).creatingToDodialoge,
        message: widget.existingTask != null
            ? S.of(context).areYouSureYouWouldLikeToProceedWithEditingToDo
            : S.of(context).areYouSureYouWouldLikeToProceedWithCreatingToDo,
        actions: [
          customButton(
            title: S.of(context).no,
            width: 135.w,
            color: lightMode ? Colors.grey[400] : Colors.grey[700],
            height: 38.sp,
            textStyle: AppTextStyles.font16BlackMediumCairo.copyWith(
              color: lightMode ? Colors.black : Colors.white,
            ),
            radius: 8.r,
            function: () {
              Navigator.of(dialogContext).pop();
            },
          ),
          SizedBox(width: isMobile ? 12.w : 28.w),
          customButton(
            title: S.of(context).yes,
            width: 135.w,
            color: AppColors.primary,
            height: 38.sp,
            textStyle: AppTextStyles.font16BlackMediumCairo.copyWith(
              color: AppColors.textButton,
            ),
            radius: 8.r,
            function: () {
              // Close dialog first
              Navigator.of(dialogContext).pop();
              // Then save task
              _saveTask();
            },
          ),
        ],
      ),
    );
  }

  void _showSuccessDialogAndNavigate() {
    if (!mounted) {
      print('❌ Widget not mounted, cannot show success dialog');
      return;
    }

    print('📱 Showing success dialog...');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        print('✅ Success dialog built');


        // Auto-close and navigate after 2 seconds
        Future.delayed(const Duration(seconds: 2), () {
          print('⏰ Auto-close timer triggered');

          try {
            // Check if dialog context is still valid
            if (Navigator.of(dialogContext, rootNavigator: true).canPop()) {
              Navigator.of(dialogContext, rootNavigator: true).pop();
              print('✅ Success dialog closed');
            }
          } catch (e) {
            print('⚠️ Could not close success dialog: $e');
          }

          // Small delay before navigation
          Future.delayed(const Duration(milliseconds: 100), () {
            try {
              if (mounted) {
                print('🚀 Navigating to home screen...');
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const ToDoListScreen(),
                  ),
                  (route) => false,
                );
                print('✅ Navigation completed');
              }
            } catch (e) {
              print('❌ Navigation error: $e');
            }
          });
        });

        return CustomPopupDialogWithLottie(
          lottiePath: Images.approvedLottie,
          title: S.of(context).successful,
          message: widget.existingTask != null
              ? S.of(context).youSuccessfullyEditedTheToDo
              : S.of(context).youSuccessfullyCreatedNewToDo,
        );
      },
    );
  }

  var employeeEntity = Get.find<MainCoreEmployeeController>().employeeEntity ??
      EmployeeEntityPro();

  //save task
  void _saveTask() async {
    print('🔥 === _saveTask STARTED ===');

    // Check if widget is still mounted
    if (!mounted) {
      print('❌ Widget not mounted, aborting save');
      return;
    }

    // Show loading
    try {
      setState(() => _isLoading = true);
      print('✅ Loading state set to true');
    } catch (e) {
      print('❌ Error setting loading state: $e');
      return;
    }

    try {
      print('📅 Processing dates...');
      DateTime? finalStartDate;
      DateTime? finalEndDate;

      if (_isScheduled && _startDate != null && _startTime != null) {
        try {
          finalStartDate = DateTime(
            _startDate!.year,
            _startDate!.month,
            _startDate!.day,
            _startTime!.hour,
            _startTime!.minute,
          );
          print('✅ Start date created: $finalStartDate');

          if (_endDate != null && _endTime != null) {
            finalEndDate = DateTime(
              _endDate!.year,
              _endDate!.month,
              _endDate!.day,
              _endTime!.hour,
              _endTime!.minute,
            );
            print('✅ End date created: $finalEndDate');
          }
        } catch (e) {
          print('❌ Error creating dates: $e');
          throw Exception('Date creation failed: $e');
        }
      }

      if (widget.existingTask != null) {
        print('✏️ === EDITING EXISTING TASK ===');
        try {
          TaskModel task = widget.existingTask!;
          print('✅ Task loaded');

          task.updateName(_nameController.text.trim());
          print('✅ Name updated');

          task.updateDescription(_descriptionController.text.trim());
          print('✅ Description updated');

          task.updatePriority(_selectedPriority);
          print('✅ Priority updated');

          task.updateTaskStatus(
            _isScheduled ? TaskStatus.scheduled : TaskStatus.toDo,
          );
          print('✅ Status updated');

          if (task.items.current != null && task.items.current!.isNotEmpty) {
            task.updateItems(task.currentItems!);
            print('✅ Items updated');
          }

          // Update scheduled
          if (_isScheduled && finalStartDate != null) {
            print('📅 Creating ScheduledData...');
            try {
              task.updateScheduled(
                ScheduledData(
                  taskStartDate: finalStartDate,
                  taskStartTime: _startTime?.format(context) ?? '',
                  taskEndDate: finalEndDate,
                  taskEndTime: _endTime?.format(context) ?? '',
                  reminders: _reminders,
                ),
              );
              print('✅ Scheduled data updated');
            } catch (e) {
              print('❌ Error creating ScheduledData: $e');
              throw Exception('ScheduledData creation failed: $e');
            }
          } else {
            task.updateScheduled(null);
            print('✅ Scheduled cleared');
          }

          if (_setFrequency) {
            print('🔄 Creating FrequencyData...');
            try {
              task.updateFrequency(
                FrequencyData(
                  frequencyCount: _frequencyCount,
                  frequencyUnit: _frequencyUnit,
                  selectedDays: _selectedDays,
                ),
              );
              print('✅ Frequency data updated');
            } catch (e) {
              print('❌ Error creating FrequencyData: $e');
              throw Exception('FrequencyData creation failed: $e');
            }
          } else {
            task.updateFrequency(null);
            print('✅ Frequency cleared');
          }

          print('💾 Updating task in Firebase...');
          await _firebaseService.updateTask(task.taskId.current ?? '', task);
          print('✅ Task updated successfully in Firebase');
        } catch (e) {
          print('❌ Error during task update: $e');
          rethrow;
        }
      } else {
        print('➕ === CREATING NEW TASK ===');
        try {
          print('📝 Task details:');
          print('  - Email: ${employeeEntity.email ?? "MISSING"}');
          print('  - Name: ${_nameController.text.trim()}');
          print('  - Description: ${_descriptionController.text.trim()}');
          print('  - Priority: $_selectedPriority');
          print('  - Scheduled: $_isScheduled');
          print('  - Set Frequency: $_setFrequency');

          ScheduledData? scheduledData;
          if (_isScheduled && finalStartDate != null) {
            print('📅 Creating ScheduledData for new task...');
            try {
              scheduledData = ScheduledData(
                taskStartDate: finalStartDate,
                taskStartTime: _startTime?.format(context) ?? '',
                taskEndDate: finalEndDate,
                taskEndTime: _endTime?.format(context) ?? '',
                reminders: _reminders,
              );
              print('✅ ScheduledData created');
            } catch (e) {
              print('❌ Error creating ScheduledData: $e');
              throw Exception('ScheduledData creation failed: $e');
            }
          }

          FrequencyData? frequencyData;
          if (_setFrequency) {
            print('🔄 Creating FrequencyData for new task...');
            try {
              frequencyData = FrequencyData(
                frequencyCount: _frequencyCount,
                frequencyUnit: _frequencyUnit,
                selectedDays: _selectedDays,
              );
              print('✅ FrequencyData created');
            } catch (e) {
              print('❌ Error creating FrequencyData: $e');
              throw Exception('FrequencyData creation failed: $e');
            }
          }

          print('🏗️ Creating TaskModel...');
          TaskModel task;
          try {
            task = TaskModel.createNew(
              creatorEmail: employeeEntity.email ?? '',
              taskId: '',
              name: _nameController.text.trim(),
              description: _descriptionController.text.trim(),
              items: [],
              taskStatus: _isScheduled ? TaskStatus.scheduled : TaskStatus.toDo,
              priority: _selectedPriority,
              scheduled: scheduledData,
              frequency: frequencyData,
            );
            print('✅ TaskModel created successfully');
          } catch (e) {
            print('❌ Error creating TaskModel: $e');
            throw Exception('TaskModel.createNew failed: $e');
          }

          print('💾 Saving task to Firebase...');
          await _firebaseService.createTask(task);
          print('✅ Task saved successfully to Firebase');
        } catch (e, stack) {
          print('❌ Error during task creation: $e');
          print('Stack trace: $stack');
          rethrow;
        }
      }

      print('🎉 Task operation completed successfully');

      // Hide loading
      if (mounted) {
        setState(() => _isLoading = false);
        print('✅ Loading state set to false');
      }

      // Small delay to ensure state is updated
      await Future.delayed(const Duration(milliseconds: 100));

      // Show success dialog and navigate
      if (mounted) {
        print('🎉 Showing success dialog');
        _showSuccessDialogAndNavigate();
      }
    } catch (e, stackTrace) {
      print('❌ ========================================');
      print('❌ CRITICAL ERROR IN _saveTask');
      print('❌ Error: $e');
      print('❌ Stack trace: $stackTrace');
      print('❌ ========================================');

      // Hide loading on error
      if (mounted) {
        try {
          setState(() => _isLoading = false);
        } catch (e2) {
          print('❌ Error hiding loading: $e2');
        }
      }

      // Show error message
      if (mounted) {
        try {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving task: $e'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        } catch (e2) {
          print('❌ Error showing snackbar: $e2');
        }
      }
    }

    print('🔥 === _saveTask ENDED ===');
  }

  Future<void> _validate() async {
    setState(() => _showErrors = true);

    if (!_formKey.currentState!.validate()) return;

    if (_nameController.text.trim().isEmpty ||
        _descriptionController.text.trim().isEmpty) {
      return;
    }

    // ✅ NEW VALIDATION: End date/time cannot be selected without start date
    if (_isScheduled == true) {
      if ((_endDate != null || _endTime != null) && _startDate == null) {
        await _showValidationDialog(
          S.of(context).pleaseselectstartdatebeforeenddate,
        );
        return;
      }
    }

    if (_selectedPriority == 'Select') {
      await _showValidationDialog(S.of(context).pleaseselectapriority);
      return;
    }

    if (_setFrequency && _frequencyUnit == 'Select') {
      await _showValidationDialog(S.of(context).pleaseselectafrequencyunit);
      return;
    }

    if (_setFrequency &&
        _frequencyUnit == TaskFrequency.weekly &&
        _selectedDays.isEmpty) {
      await _showValidationDialog(S.of(context).pleaseselectatleastoneday);
      return;
    }

    // ✅ UPDATED: Allow same day if end time is after start time
    if (_endDate != null && _startDate != null) {
      final isSameDay = _endDate!.year == _startDate!.year &&
          _endDate!.month == _startDate!.month &&
          _endDate!.day == _startDate!.day;

      if (isSameDay) {
        // Same day: validate times
        if (_endTime != null && _startTime != null) {
          final startMinutes = _startTime!.hour * 60 + _startTime!.minute;
          final endMinutes = _endTime!.hour * 60 + _endTime!.minute;

          if (endMinutes <= startMinutes) {
            await _showValidationDialog(
              S.of(context).endtimemustbeafterstarttime, // Add translation: "End time must be after start time"
            );
            return;
          }
        }
      } else {
        // Different days: end date must be after start date
        if (_endDate!.isBefore(_startDate!)) {
          await _showValidationDialog(S.of(context).enddatemustbeafterstartdate);
          return;
        }
      }
    }

    if (_reminders.isNotEmpty) {
      for (final reminder in _reminders) {
        if (reminder.durationUnit == null || reminder.durationUnit!.isEmpty) {
          await _showValidationDialog(
            S.of(context).pleaseselectadurationunitforreminder,
          );
          return;
        }
      }
    }

    _showCreateTodoDialog(context);
  }

  Future<void> _showValidationDialog(String message) async {
    await CustomDialogManager.showDialogFlow(
      context: context,
      confirmLottie: Images.warningLottie,
      confirmTitle: S.of(context).validationError,
      confirmSubtitle: message,
      confirmYesText: S.of(context).ok,
      confirmNoText: S.of(context).cancel,
      onConfirm: () {},
      successLottie: Images.warningLottie,
      successTitle: S.of(context).notice,
      successSubtitle: message,
      onNoPressed: () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    var isMobile = context.isPhone;
    final size = MediaQuery.of(context).size;
    final isTablet = size.shortestSide >= 600;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SideFrameMasterServices(
        titleText: S.of(context).toDoListTitle,
        onFirstTap: () => Navigator.pop(context),
        secondTitle: widget.isEditing ? S.of(context).detailsPageTitle : null,
        onSecondTap: widget.isEditing ? () => Navigator.pop(context) : null,
        thirdTitle: widget.isEditing
            ? S.of(context).editingToDoTitle
            : S.of(context).creatingToDoTitle,
        child: isMobile
            ? Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(8.r),
              ),
              padding: EdgeInsets.all(15.w),
              margin: EdgeInsets.symmetric(horizontal: 0.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildNameField(),
                    SizedBox(height: 15.h),
                    _buildPriorityField(),
                    SizedBox(height: 15.h),
                    _buildDescriptionField(),
                    SizedBox(height: 37.h),
                    _buildScheduledSwitch(isTablet),
                    SizedBox(height: 15.h),
                    if (_isScheduled) _buildSchedule(isTablet),
                    SizedBox(height: 25.sp),
                    _buildSetFrequencySwitch(isTablet),
                    if (_setFrequency) ...[
                      SizedBox(height: 15.h),
                      _buildFrequencyCounter(isTablet, isLandscape),
                    ],
                    SizedBox(height: 15.h),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20.h),
            _buildActionButtons(isTablet),
            SizedBox(height: 17.h),
          ],
        )
            : LayoutBuilder( // ✅ REMOVE Expanded wrapper, use LayoutBuilder directly
          builder: (context, constraints) {
            var lightMode = Theme.of(context).brightness == Brightness.light;
            return SingleChildScrollView(
              child: ConstrainedBox( // ✅ Use ConstrainedBox instead of Column with Expanded
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        padding: EdgeInsets.all(15.w),
                        margin: EdgeInsets.symmetric(horizontal: 0.w),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (isTablet && isLandscape)
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(child: _buildNameField()),
                                    SizedBox(width: 15.w),
                                    Expanded(child: _buildPriorityField()),
                                  ],
                                )
                              else ...[
                                _buildNameField(),
                                SizedBox(height: 15.h),
                                _buildPriorityField(),
                              ],
                              SizedBox(height: 15.h),
                              _buildDescriptionField(),
                              SizedBox(height: 37.h),
                              _buildScheduledSwitch(isTablet),
                              SizedBox(height: 15.h),
                              if (_isScheduled) _buildSchedule(isTablet),
                              SizedBox(height: 25.sp),
                              _buildSetFrequencySwitch(isTablet),
                              if (_setFrequency) ...[
                                SizedBox(height: 15.h),
                                _buildFrequencyCounter(isTablet, isLandscape),
                              ],
                              SizedBox(height: 15.h),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      _buildActionButtons(isTablet),
                      SizedBox(height: 17.h),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  bool _showErrors = false;

  Widget _buildNameField() {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return CustomValidatedTextField(

      label: S.of(context).name,
      hint: S.of(context).textHere,
      controller: _nameController,
      maxLength: 60,
      height: 36,
      maxLines: 1,
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      errorText:
          _showErrors ? _getFieldError('taskName', _nameController.text) : null,
      onlyDigits: false,
      onChanged: (_) {
        setState(() {});
      },
    );
  }

  String? _getFieldError(String key, String? value) {
    if (value == null || value.isEmpty) {
      switch (key) {
        case 'taskName':
          return 'Please enter task name';
        case 'priority':
          return 'Please select a priority';
        case 'description':
          return 'Please enter description';
        default:
          return 'This field is required';
      }
    }
    return null;
  }

  Widget _buildPriorityField() {
    return CustomDropdown<String>(
      value: _selectedPriority == 'Select' ? null : _selectedPriority,
      label: S.of(context).priority,
      hint: S.of(context).selectpriority,
      hintStyle: AppTextStyles.font12BlackCairoRegular.copyWith(
        color: AppColors.secondaryText.withOpacity(.5),
      ),
      items: [
        DropdownItem<String>(value: TaskPriority.high, label: S.of(context).high),
        DropdownItem<String>(value: TaskPriority.medium, label: S.of(context).medium),
        DropdownItem<String>(value: TaskPriority.low, label: S.of(context).low),
      ],
      onChanged: (val) {
        setState(() {
          _selectedPriority = val;
        });
      },
    );
  }
  Widget _buildDescriptionField() {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return CustomValidatedTextField(
      label: S.of(context).description,
      hint: S.of(context).textHere,
      maxLines: 3,
      maxLength: 500,
      height: 72,
      showCharCount: true,
      controller: _descriptionController,
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      errorText: _showErrors
          ? _getFieldError('description', _descriptionController.text)
          : null,
      onlyDigits: false,
      onChanged: (_) {
        setState(() {
          // validationErrors.remove(key);
        });
      },
    );
  }


  Widget _buildScheduledSwitch(isTablet) {
    var lightMode = Theme.of(context).brightness == Brightness.light;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    var isMobile = context.isPhone; // ✅ Use context.isPhone

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: 120.w,
          child: Text(
            S.of(context).scheduled,
            style: AppTextStyles.font14BlackCairoMedium.copyWith(
              color: lightMode
                  ? AppColors.blackButton
                  : AppColors.white,
            ),
          ),
        ),
        // ✅ Add Spacer only on mobile
        if (isMobile) const Spacer(),
        Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..rotateY(isArabic ? 3.14159 : 0), // 180 degrees = π radians
          child: FlutterSwitch(
            activeColor: AppColors.primary,
            height: 22.sp,
            width: 38.sp,
            padding: 3.sp,
            borderRadius: 20.sp,
            toggleSize: 16.sp,
            value: _isScheduled,
            onToggle: (val) {
              setState(() {
                _isScheduled = val;
              });
            },
          ),
        ),
        // ✅ Keep existing spacing only for tablet/desktop
        if (!isMobile)
          SizedBox(
            width: MediaQuery.of(context).size.width * .16,
          ),
      ],
    );
  }

  Widget _buildSchedule(bool isTablet) {
    var lightMode = Theme.of(context).brightness == Brightness.light;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        isTablet
            ? Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    S.of(context).homeScreenStartDateTitle,
                    style: AppTextStyles.font14BlackCairoMedium
                        .copyWith(color: AppColors.text),
                  ),
                  SizedBox(height: 8.sp),
                  Row(
                    children: [
                      Flexible( // ✅ Changed from Expanded
                        flex: 3,
                        child: InkWell(
                          onTap: () => _selectDate(context, true),
                          child: Container(
                            height: 38.h,
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 7.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _startDate != null
                                      ? intl.DateFormat('dd MMM yyyy').format(_startDate!)
                                      : S.of(context).selectStartDate,
                                  style: AppTextStyles.font12BlackMediumCairo.copyWith(
                                    color: AppColors.secondaryText,
                                  ),
                                ),
                                SizedBox(
                                  child: CustomSvg(
                                    assetPath: Images.calendarIcon,
                                    width: 20.w,
                                    height: 20.h,
                                    fit: BoxFit.fill,
                                    color: AppColors.secondaryText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Flexible( // ✅ Changed from Expanded
                        child: InkWell(
                          onTap: () => _selectTime(context, true),
                          child: Container(
                            height: 38.h,
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 7.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _startTime != null
                                      ? _startTime!.format(context)
                                      : S.of(context).selectStartTime,
                                  style: AppTextStyles.font12BlackMediumCairo.copyWith(
                                    color: AppColors.secondaryText,
                                  ),
                                ),
                                CustomSvg(
                                  assetPath: Images.clockIcon,
                                  width: 20.w,
                                  height: 20.h,
                                  fit: BoxFit.fill,
                                  color: AppColors.secondaryText,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 15.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    S.of(context).homeScreenEndDateTitle,
                    style: AppTextStyles.font14BlackCairoRegular.copyWith(color: AppColors.text),
                  ),
                  SizedBox(height: 8.sp),
                  Row(
                    children: [
                      Flexible( // ✅ Changed from Expanded
                        flex: 3,
                        child: InkWell(
                          onTap: () => _selectDate(context, false),
                          child: Container(
                            height: 38.h,
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 7.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _endDate != null
                                      ? intl.DateFormat('dd MMM yyyy').format(_endDate!)
                                      : S.of(context).selectEndDate,
                                  style: AppTextStyles.font12BlackMediumCairo.copyWith(
                                    color: AppColors.secondaryText,
                                  ),
                                ),
                                CustomSvg(
                                  assetPath: Images.calendarIcon,
                                  width: 20.w,
                                  height: 20.h,
                                  fit: BoxFit.fill,
                                  color: AppColors.secondaryText,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Flexible( // ✅ Changed from Expanded
                        child: InkWell(
                          onTap: () => _selectTime(context, false),
                          child: Container(
                            height: 38.h,
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 7.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _endTime != null
                                      ? _endTime!.format(context)
                                      : S.of(context).selectEndTime,
                                  style: AppTextStyles.font12BlackMediumCairo.copyWith(
                                    color: AppColors.secondaryText,
                                  ),
                                ),
                                CustomSvg(
                                  assetPath: Images.clockIcon,
                                  width: 20.w,
                                  height: 20.h,
                                  fit: BoxFit.fill,
                                  color: AppColors.secondaryText,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        )
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.of(context).homeScreenStartDateTitle,
              style: TextStyle(
                fontWeight: AppFontWeights.regular,
                fontSize: 14.sp,
                color: AppColors.text,
              ),
            ),
            SizedBox(height: 6.h),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: InkWell(
                    onTap: () => _selectDate(context, true),
                    child: Container(
                      height: 38.h,
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 7.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _startDate != null
                                ? intl.DateFormat('dd/MM/yyyy').format(_startDate!)
                                : S.of(context).selectStartDate,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.inverseBase,
                              fontWeight: AppFontWeights.regular,
                            ),
                          ),
                          CustomSvg(
                            assetPath: Images.calendarIcon,
                            width: 16.w,
                            height: 16.h,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectTime(context, true),
                    child: Container(
                      height: 38.h,
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 7.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _startTime != null
                                ? _startTime!.format(context)
                                : S.of(context).selectStartTime,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.inverseBase,
                              fontWeight: AppFontWeights.regular,
                            ),
                          ),
                          CustomSvg(
                            assetPath: Images.clockIcon,
                            width: 16.w,
                            height: 16.h,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 15.w),
            Text(
              S.of(context).homeScreenEndDateTitle,
              style: TextStyle(
                fontWeight: AppFontWeights.regular,
                fontSize: 14.sp,
                color: AppColors.text,
              ),
            ),
            SizedBox(height: 6.h),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: InkWell(
                    onTap: () => _selectDate(context, false),
                    child: Container(
                      height: 38.h,
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 7.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _endDate != null
                                ? intl.DateFormat('dd/MM/yyyy').format(_endDate!)
                                : S.of(context).selectEndDate,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.inverseBase,
                              fontWeight: AppFontWeights.regular,
                            ),
                          ),
                          CustomSvg(
                            assetPath: Images.calendarIcon,
                            width: 16.w,
                            height: 16.h,
                            color: AppColors.secondaryText,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectTime(context, false),
                    child: Container(
                      height: 38.h,
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 7.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _endTime != null
                                ? _endTime!.format(context)
                                : S.of(context).selectEndTime,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.inverseBase,
                              fontWeight: AppFontWeights.regular,
                            ),
                          ),
                          CustomSvg(
                            assetPath: Images.clockIcon,
                            width: 16.w,
                            height: 16.h,
                            color: AppColors.secondaryText,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),

        // Reminders
        if (_reminders.isNotEmpty) ...[
          SizedBox(height: 15.h),
          Column(
            children: [
              for (int i = 0; i < _reminders.length; i++)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.h),
                  child: _buildReminderItem(i + 1, _reminders[i], isTablet),
                ),
            ],
          ),
        ],

        SizedBox(height: 8.h),

        if (_reminders.length < 3)
          customButtonWithImage(
            title: S.of(context).reminder,
            function: () {
              if (_reminders.length < 3) {
                _addReminder(null, 1);
              }
            },
            textStyle: AppTextStyles.font12BlackMediumCairo.copyWith(
              color: AppColors.white,
            ),
            width: 100.w,
            height: 28.h,
            space: 4.w,
            radius: 4.r,
            color: AppColors.black,
            image: Images.plusIcon,
            widthImage: 16.sp,
            heightImage: 16.sp,
            colorBorder: Colors.transparent,
          ),
      ],
    );
  }

  Widget _buildReminderItem(int index, ReminderData reminder, bool isTablet) {
    String title;
    switch (index) {
      case 1:
        title = S.of(context).firstReminder;
        break;
      case 2:
        title = S.of(context).secReminder;
        break;
      case 3:
        title = S.of(context).thirdReminder;
        break;
      default:
        title = '${S.of(context).reminder} $index';
    }

    var isMobile = context.isPhone; // ✅ Use context.isPhone

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
              fontSize: 14.sp,
              fontWeight: AppFontWeights.medium,
              color: AppColors.text),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Container(
              height: 36.h,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Row(
                children: [
                  buildCustomIconButton(
                    function: () {
                      if (reminder.durationCount > 1) {
                        setState(() => reminder.durationCount--);
                      }
                    },
                    isPlus: false,
                    size: 5.sp,
                  ),
                  Text(
                    '${reminder.durationCount}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: AppFontWeights.regular,
                      color: AppColors.text,
                    ),
                  ),
                  buildCustomIconButton(
                    function: () => setState(() => reminder.durationCount++),
                    isPlus: true,
                  ),
                ],
              ),
            ),
            SizedBox(width: 15.w),
            // ✅ Conditionally wrap with Expanded for mobile only
            if (isMobile)
              Expanded(child: _buildReminderItemDropdown(reminder))
            else
              _buildReminderItemDropdown(reminder),
          ],
        ),
      ],
    );
  }
  Widget _buildReminderItemDropdown(ReminderData reminder) {
    final items = [
      {'key': TaskReminder.hour, 'value': S.of(context).hour},
      {'key': TaskReminder.minute, 'value': S.of(context).minute},
      {'key': TaskReminder.second, 'value': S.of(context).second},
    ];

    final bool hasError = _reminders.isNotEmpty &&
        (reminder.durationUnit == null || reminder.durationUnit!.isEmpty);

    var isMobile = context.isPhone; // ✅ Mobile detection

    // ✅ Calculate responsive width based on screen size
    final size = MediaQuery.of(context).size;
    final isTablet = size.shortestSide >= 600;
    final isDesktop = size.width > 1200;

    // ✅ Only set width for tablet/desktop, mobile uses null
    double? dropdownWidth;
    if (isDesktop) {
      dropdownWidth = 365.w;
    } else if (isTablet) {
      dropdownWidth = 335.w;
    }
    // ✅ For mobile, width stays null and will expand to fill available space

    return CustomDropdownFormField(
      width: dropdownWidth, // ✅ Will be null for mobile
      selectedValue: reminder.durationUnit,
      iconPath: "assets/images/arrow_down.svg",
      hint: Text(
        S.of(context).select,
        style: AppTextStyles.font12BlackCairoRegular
            .copyWith(color: AppColors.secondaryText),
      ),
      widthIcon: 16.w,
      heightIcon: 7.h,
      height: 36,
      dropdownColor: AppColors.background,
      items: items,
      onChanged: (val) {
        setState(() {
          reminder.durationUnit = val!;
        });
      },
      hasError: hasError,
    );
  }

  Widget _buildSetFrequencySwitch(isTablet) {
    var lightMode = Theme.of(context).brightness == Brightness.light;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    var isMobile = context.isPhone; // ✅ Use context.isPhone

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: 120.w,
          child: Text(
            S.of(context).setFrequency,
            style: AppTextStyles.font14BlackCairoMedium.copyWith(
              color: lightMode
                  ? AppColors.blackButton
                  : AppColors.white,
            ),
          ),
        ),
        // ✅ Add Spacer only on mobile
        if (isMobile) const Spacer(),
        Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..rotateY(isArabic ? 3.14159 : 0), // 180 degrees = π radians
          child: FlutterSwitch(
            activeColor: AppColors.primary,
            height: 22.sp,
            width: 38.sp,
            padding: 3.sp,
            borderRadius: 20.sp,
            toggleSize: 16.sp,
            toggleColor: Colors.white,
            value: _setFrequency,
            onToggle: (val) {
              setState(() {
                _setFrequency = val;
              });
            },
          ),
        ),
        // ✅ Keep existing spacing only for tablet/desktop
        if (!isMobile)
          SizedBox(
            width: MediaQuery.of(context).size.width * .16,
          ),
      ],
    );
  }

  Widget _buildFrequencyCounter(bool isTablet, bool isLandscape) {
    var isMobile = context.isPhone; // ✅ Add mobile detection

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 36.h,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Row(
                children: [
                  buildCustomIconButton(
                    function: () {
                      if (_frequencyCount > 1) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          setState(() => _frequencyCount--);
                        });
                      }
                    },
                    isPlus: false,
                    size: 5.sp,
                  ),
                  Text(
                    '$_frequencyCount',
                    style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: AppFontWeights.regular,
                        color: AppColors.text),
                  ),
                  buildCustomIconButton(
                    function: () {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        setState(() => _frequencyCount++);
                      });
                    },
                    isPlus: true,
                  ),
                ],
              ),
            ),
            SizedBox(width: 15.w),
            // ✅ Conditionally wrap with Expanded on mobile
            if (isMobile)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFrequencyDropdown(),
                    if (_frequencyUnit == TaskFrequency.weekly) ...[
                      SizedBox(height: 5.h),
                      _buildDaySelector(isLandscape, isTablet),
                    ],
                  ],
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFrequencyDropdown(),
                  if (_frequencyUnit == TaskFrequency.weekly) ...[
                    SizedBox(height: 5.h),
                    _buildDaySelector(isLandscape, isTablet),
                  ],
                ],
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildFrequencyDropdown() {
    final items = [
      {'key': TaskFrequency.monthly, 'value': S.of(context).monthly},
      {'key': TaskFrequency.weekly, 'value': S.of(context).weekly},
      {'key': TaskFrequency.daily, 'value': S.of(context).daily},
    ];

    var isMobile = context.isPhone; // ✅ Mobile detection

    // ✅ Calculate responsive width based on screen size
    final size = MediaQuery.of(context).size;
    final isTablet = size.shortestSide >= 600;
    final isDesktop = size.width > 1200;

    double? dropdownWidth; // ✅ Make nullable
    if (isDesktop) {
      dropdownWidth = 365.w;
    } else if (isTablet) {
      dropdownWidth = 335.w;
    }
    // ✅ For mobile, width stays null and will expand to fill available space

    return CustomDropdownFormField(
      selectedValue: _frequencyUnit,
      width: dropdownWidth, // ✅ Will be null on mobile
      iconPath: "assets/images/arrow_down.svg",
      hint: Text(
        S.of(context).select,
        style: AppTextStyles.font12BlackCairoRegular
            .copyWith(color: AppColors.secondaryText),
      ),
      widthIcon: 16.w,
      heightIcon: 7.h,
      height: 36,
      dropdownColor: AppColors.background,
      items: items,
      onChanged: (val) {
        setState(() => _frequencyUnit = val!);
      },
      hasError: (_frequencyUnit == 'Select'),
    );
  }

  Widget _buildDaySelector(bool isLandscape, isTablet) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    var isMobile = context.isPhone;

    // English short and full day names
    final daysShort = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    final daysFullEnglish = ['Sun', 'Mon', 'Tues', 'Wed', 'Thurs', 'Fri', 'Sat'];

    // Arabic short and full day names
    final daysShortArabic = ['ح', 'ن', 'ث', 'ر', 'خ', 'ج', 'س'];
    final daysFullArabic = ['الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'];

    // Choose display based on language and layout
    final displayDays = isArabic
        ? (isLandscape ? daysFullArabic : daysShortArabic)
        : (isLandscape ? daysFullEnglish : daysShort);

    // Always use English full names as keys for storage
    final storageDays = daysFullEnglish;

    // ✅ Adjusted box size: smaller for mobile, larger for landscape
    final boxSize = isLandscape ? 36.w : (isMobile ? 23.w : 25.w);
    // ✅ Reduced spacing for mobile to fit all days in one row
    final spacing = isMobile ? 6.w : 10.w;
    return Wrap(
      spacing: spacing,
      children: List.generate(displayDays.length, (index) {
        final storageKey = storageDays[index];
        final isSelected = _selectedDays.contains(storageKey);

        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedDays.remove(storageKey);
              } else {
                _selectedDays.add(storageKey);
              }
            });
          },
          child: Container(
            width: boxSize,
            height: boxSize,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.background,
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Center(
              child: Text(
                displayDays[index],
                style: TextStyle(
                  fontSize: 12.sp,
                  color: isSelected
                      ? AppColors.textButton
                      : AppColors.inverseBase,
                  fontWeight: AppFontWeights.regular,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildActionButtons(bool isTablet) {
    var lightMode = Theme.of(context).brightness == Brightness.light;
    return Row(
      children: [
        customButton(
          title: S.of(context).discardTitle,
          width: isTablet ? 135.w : 135.w,
          color: lightMode? Colors.grey[400]:Colors.grey[700],
          height: 38.h,
          textStyle: AppTextStyles.font16BlackMediumCairo.copyWith(
            color: lightMode?Colors.black:Colors.white,
          ),
          radius: 8.r,
          function: () => Navigator.pop(context),
        ),
        const Spacer(),
        customButton(
          title: widget.existingTask != null
              ? S.of(context).saveTitle
              : S.of(context).createTitle,
          width: isTablet ? 135.w : 135.w,
          color:  AppColors.primary,
          height: 38.h,
          textStyle: AppTextStyles.font16BlackMediumCairo.copyWith(
            color:  AppColors.textButton,
          ),
          radius: 8.r,
          function: _validate,
        ),
      ],
    );
  }
}
