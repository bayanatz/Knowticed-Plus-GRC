import 'package:demo_app/core/helper/todo_new_module/core_widgets/main_widget/side_frame_master.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:demo_app/core/helper/form_builder_module/core/widgets/buttons/custom_button.dart';
import 'package:lottie/lottie.dart';

import 'package:demo_app/core/custom/35-custom_search_widget_custom.dart';
import 'package:demo_app/core/custom/circle_progress.dart';
import 'package:demo_app/generated/l10n.dart';
import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/theme/app_text_styles.dart';
import '../../../../core/custom_widgets/custom_button_widget.dart';
import '../../../../core/custom_widgets/custom_filter_tabs.dart';
import '../../../../core/custom_widgets/custom_grid_view.dart';
import '../../../../core/custom_widgets/custom_pop_up.dart';
import '../../../../core/custom_widgets/custom_side_bar_widget.dart';
import '../../../../core/custom_widgets/svg_custom.dart';
import '../../../../core/enums/task_status_enum.dart';
import '../../../../core/utilties/images.dart';
import '../../../data/models/task_model_updates_with_field_history.dart';
import '../../../domain/services/task_services.dart';
import '../../widgets/custom_task_card.dart';
import 'create_to_do_list/create_screen.dart';
import 'details_screen/hr_module/add_new_employee_screen.dart';
import 'details_screen/hr_module/hr_dashboard.dart';
import 'details_screen/hr_module/hr_employee.dart';
import 'details_screen/hr_module/hr_rmployee_details.dart';
import 'details_screen/task_details_screen.dart';

class ToDoListScreen extends StatefulWidget {
  const ToDoListScreen({super.key});

  static String routeName = '/to_do_list';

  @override
  State<ToDoListScreen> createState() => _ToDoListScreenState();
}

class _ToDoListScreenState extends State<ToDoListScreen>
    with SingleTickerProviderStateMixin {
  final TaskFirebaseService _firebaseService = TaskFirebaseService();
  late TabController _tabController;

  TextEditingController searchController = TextEditingController();

  int selectedPriority = 0;
  bool showSortMenu = false;
  int _selectedSort = -1;
  String searchQuery = "";
  String selectedFilter = '';
  final _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (selectedFilter.isEmpty) {
      selectedFilter = S.of(context).homeScreenAllTitle ?? 'All';
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    searchController.dispose();
    super.dispose();
  }

  Stream<List<TaskModel>> _getStreamForSelectedFilter(BuildContext context) {
    final Map<String, String> filterToEnumMap = {
      S.of(context).homeScreenAllTitle: 'All',
      S.of(context).toDo: TaskStatus.toDo,
      S.of(context).done: TaskStatus.done,
      S.of(context).overdue: TaskStatus.overdue,
      S.of(context).scheduled: TaskStatus.scheduled,
      S.of(context).deleted: TaskStatus.deleted,
    };

    final String selectedFilterEnum = filterToEnumMap[selectedFilter] ?? 'All';

    switch (selectedFilterEnum) {
      case TaskStatus.toDo:
        return _firebaseService.getToDoTasks();
      case TaskStatus.done:
        return _firebaseService.getDoneTasks();
      case TaskStatus.overdue:
        return _firebaseService.getOverdueTasks();
      case TaskStatus.scheduled:
        return _firebaseService.getScheduledTasks();
      case TaskStatus.deleted:
        return _firebaseService.getDeletedTasks();
      default:
        return _firebaseService.getAllTasks();
    }
  }

  @override
  Widget build(BuildContext context) {
    var isMobile = context.isPhone;
    final lightMode = Theme.of(context).brightness == Brightness.light;
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final isLandscape = size.width > size.height;

    return Scaffold(
      body: SideFrameMasterServices(
        titleText: S.of(context).toDoListTitle,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFiltersSection(lightMode, isTablet),
                 SizedBox(height: 15.h),
               isMobile ? Container(
                 height: 400.h,
                 child: _buildTaskList(
                   isTablet,
                   isLandscape,
                   lightMode,
                 ),
               ): Expanded(
                  child: _buildTaskList(
                    isTablet,
                    isLandscape,
                    lightMode,
                  ),
                ),
                // SizedBox(height: 15.h),
              ],
            ),
            if (showSortMenu)
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    if (mounted) {
                      setState(() => showSortMenu = false);
                    }
                  },
                  child: Stack(
                    children: [
                      Container(color: Colors.transparent),
                      Positioned(
                        top: 170.sp,
                        right: isTablet ? 170.sp : 90.sp,
                        child: GestureDetector(
                          onTap: () {},
                          child: _buildSortMenu(lightMode),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersSection(bool lightMode, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StreamBuilder<List<TaskModel>>(
          stream: _firebaseService.getAllTasks(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox(
                height: 50,
                child: Center(child: CircleProgressMaster()),
              );
            }

            final tasks = snapshot.data!;
            final counts = {
              S.of(context).homeScreenAllTitle: tasks.length,
              S.of(context).toDo: tasks
                  .where(
                    (t) =>
                t.taskStatus.current == TaskStatus.toDo &&
                    t.taskStatus.current != TaskStatus.deleted &&
                    !_firebaseService.isTaskOverdue(t, _now),
              )
                  .length,
              S.of(context).done: tasks
                  .where(
                    (t) =>
                t.taskStatus.current == TaskStatus.done &&
                    t.taskStatus.current != TaskStatus.deleted,
              )
                  .length,
              S.of(context).overdue: tasks
                  .where(
                    (t) =>
                t.taskStatus.current != TaskStatus.deleted &&
                    _firebaseService.isTaskOverdue(t, _now),
              )
                  .length,
              S.of(context).scheduled: tasks
                  .where(
                    (t) =>
                t.taskStatus.current == TaskStatus.scheduled &&
                    t.taskStatus.current != TaskStatus.deleted &&
                    !_firebaseService.isTaskOverdue(t, _now),
              )
                  .length,
              S.of(context).deleted: tasks
                  .where((t) => t.taskStatus.current == TaskStatus.deleted)
                  .length,
            };

            return CustomFilterTabs(
              isTablet: isTablet,
              selectedLabel: selectedFilter,
              counts: counts,
              onSelected: (label) {
                if (mounted) {
                  setState(() => selectedFilter = label);
                }
              },
            );
          },
        ),
        SizedBox(height: 20.h),
        // customButton(title: "HR Module", function: (){
        //   Navigator.of(context).push(MaterialPageRoute(builder: (_){
        //     return HrDashboard();
        //   }));
        // }),
        // SizedBox(height: 10.h,),
        _buildSearchAndActions(lightMode, isTablet),
        SizedBox(height: 15.h),
        _buildPriorityFilters(lightMode),
      ],
    );
  }

  Widget _buildSearchAndActions(bool lightMode, bool isTablet) {
    var isMobile = context.isPhone;
    return Row(
      children: [
        Expanded(
          child: AppSearchTextField(
            controller: searchController,
            onChanged: (value) {
              if (mounted) {
                setState(() => searchQuery = value);
              }
            },
          ),
        ),
        SizedBox(width: 15.w),
        isMobile ? SizedBox() :
        CustomPopupMenuButton(
          title: S.of(context).homeScreenSortTitle,
          iconPath: Images.sortIcon,

          backgroundColor: AppColors.card,
          iconColor: AppColors.textButton,
          width: 100.w,
          height: 38.h,
          options: [
            PopupOption(
              value: '0',
              label: S.of(context).homeScreenEndDateTitle,

            ),
            PopupOption(
              value: '1',
              label: S.of(context).homeScreenFrequencyTitle,
            ),
            PopupOption(
              value: '2',
              label: S.of(context).homeScreenScheduleTitle,
            ),
          ],
          selectedValue: _selectedSort == -1 ? null : _selectedSort.toString(),
          keepOpenOnSelect: true,
          onSelected: (value) {
            if (mounted) {
              setState(() {
                _selectedSort = value == null ? -1 : int.parse(value);
              });
            }
          },
        ),

        isMobile ? SizedBox():  SizedBox(width: 15.w),

        InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateToDoScreen()),
          ),
          child: Container(
            height: 38.h,
            width:   isMobile ? 38.w : 150.w,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomSvg(
                  assetPath: Images.toDoBlackIcon,
                  height: 24.h,
                  width: 20.w,
                  color: AppColors.textButton,
                ),
                if (isTablet) ...[
                  SizedBox(width: 8.w),
                  Text(
                    S.current.homeScreenCreateToDoListTitle,
                    style: AppTextStyles.font16BlackMediumCairo.copyWith(
                      color: AppColors.textButton,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSortMenu(bool lightMode) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        width: 110,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSortMenuItem(S.of(context).homeScreenEndDateTitle, 0, lightMode),
            _buildSortMenuItem(S.of(context).homeScreenFrequencyTitle, 1, lightMode),
            _buildSortMenuItem(S.of(context).homeScreenScheduleTitle, 2, lightMode),
          ],
        ),
      ),
    );
  }

  Widget _buildSortMenuItem(String title, int index, bool lightMode) {
    bool isSelected = _selectedSort == index;
    return InkWell(
      onTap: () {
        if (mounted) {
          setState(() => _selectedSort = index);
        }
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.card,
          borderRadius: index == 0
              ? BorderRadius.only(
            topLeft: Radius.circular(10.r),
            topRight: Radius.circular(10.r),
          )
              : index == 2
              ? BorderRadius.only(
            bottomLeft: Radius.circular(10.r),
            bottomRight: Radius.circular(10.r),
          )
              : BorderRadius.zero,
        ),
        child: Text(
          title,
          style: AppTextStyles.font28BlackMediumCairo.copyWith(
            color: isSelected ?AppColors.textButton:AppColors.secondaryText
          ),
        ),
      ),
    );
  }

  Widget _buildTaskList(
      bool isTablet,
      bool isLandscape,
      bool lightMode,
      ) {
    return StreamBuilder<List<TaskModel>>(
      stream: _getStreamForSelectedFilter(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircleProgressMaster());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64.sp, color: AppColors.red),
                SizedBox(height: 15.h),
                Text('Error: ${snapshot.error}'),
              ],
            ),
          );
        }

        List<TaskModel> tasks = snapshot.data ?? [];
        List<TaskModel> filteredTasks = _firebaseService.getTasksFiltersAndSort(
          tasks,
          searchQuery,
          selectedPriority,
          _selectedSort,
        );

        if (filteredTasks.isEmpty) {
          return Center(
            child: Lottie.asset(
              Images.emptyLottie,
              width: 200.w,
              height: 200.h,
            ),
          );
        }


          return GridView.builder(
            key: ValueKey('grid_${selectedFilter}_${searchQuery}_$selectedPriority'),
            physics: const AlwaysScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount:
              CrossAxisCountHelper.getCrossAxisCountForDefaultTablet2(
                context,
              ),
              crossAxisSpacing: 15.sp,
              mainAxisSpacing: 15.sp,
              mainAxisExtent: 168.h,
            ),
            itemCount: filteredTasks.length,
            itemBuilder: (context, index) {
              final task = filteredTasks[index];
              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ToDoDetailsScreen(task: task),
                  ),
                ),
                child: TaskCard(
                  key: ValueKey(task.taskId.current),
                  task: task,
                  updateTaskStatus: () =>
                      _firebaseService.updateTaskStatusUi(task),
                  isSameDay: (task.currentScheduled?.taskEndDate != null)
                      ? _firebaseService.isSameDay(
                    task.currentScheduled!.taskEndDate!,
                  )
                      : false,
                ),
              );
            },
          );



      },
    );
  }

  Widget _buildPriorityFilters(bool lightMode) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildPriorityChip(S.of(context).homeScreenAllTitle, 0, '', lightMode),
          _buildPriorityChip(S.of(context).priorityHigh, 1, Images.highIcon, lightMode),
          _buildPriorityChip(S.of(context).medium, 2, Images.mediumIcon, lightMode),
          _buildPriorityChip(S.of(context).low, 3, Images.lowIcon, lightMode),
        ],
      ),
    );
  }

  Widget _buildPriorityChip(String label, int index, String icon, bool lightMode) {
    final isSelected = index == selectedPriority;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: customButtonWithImage(
        title: label,
        function: () {
          if (mounted) {
            setState(() => selectedPriority = index);
          }
        },
        textStyle: AppTextStyles.font14BlackCairoRegular.copyWith(
          color: isSelected
              ? AppColors.textButton
              : AppColors.text
        ),
        padding: EdgeInsets.symmetric(horizontal: 6.w,vertical: 4.h),
        height: 28.h,
        space: 5.w,
        radius: 4.r,
        color: isSelected ?  AppColors.primary : AppColors.card,
        image: icon,
        widthImage: 16.sp,
        heightImage: 16.sp,
        colorBorder: Colors.transparent,
      ),
    );
  }
}
