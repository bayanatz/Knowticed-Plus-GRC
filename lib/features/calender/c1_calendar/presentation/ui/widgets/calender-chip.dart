import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grc_module/core/theme/app_colors.dart';

class CalendarFilterChip extends StatelessWidget {
  final String count;
  final String keys;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? color;

  const CalendarFilterChip({
    Key? key,
    required this.count,
    required this.keys,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(right: 8.w),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: color ?? AppColors.primary,
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Count Badge
            Container(
              constraints: BoxConstraints(minWidth: 24.w),
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Center(
                child: Text(
                  count,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(width: 8.w),
            // Label
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Usage in your CalendarTestScreen
class CalendarFilterRow extends StatefulWidget {
  final String selectedFilter;
  final Function(String) onFilterChanged;
  final Map<String, int> filterCounts;

  const CalendarFilterRow({
    Key? key,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.filterCounts,
  }) : super(key: key);

  @override
  State<CalendarFilterRow> createState() => _CalendarFilterRowState();
}

class _CalendarFilterRowState extends State<CalendarFilterRow> {
  final List<Map<String, dynamic>> filters = [
    {
      'key': 'All',
      'label': 'All',
      'color': Color(0xFF0095FF),
    },
    {
      'key': 'Service',
      'label': 'Service',
      'color': Color(0xFF0095FF),
    },
    {
      'key': 'Form',
      'label': 'Form',
      'color': Color(0xFF4BB609),
    },
    {
      'key': 'Inventory',
      'label': 'Inventory',
      'color': Color(0xFFDF1C1C),
    },
    {
      'key': 'Qiyas',
      'label': 'Qiyas',
      'color': Color(0xFF9FADAF),
    },
    {
      'key': 'Time Tracker',
      'label': 'Time Tracker',
      'color': Color(0xFFFF814A),
    },
    {
      'key': 'Database',
      'label': 'Database',
      'color': Color(0xFFBE8F3D),
    },
    {
      'key': 'Events',
      'label': 'Events',
      'color': Color(0xFF586E73),
    },
    {
      'key': 'Risk Register',
      'label': 'Risk Register',
      'color': Color(0xFF3DA282),
    },
    {
      'key': 'Task',
      'label': 'Task',
      'color': Color(0xFFFFCD00),
    },
    {
      'key': 'GRC',
      'label': 'GRC',
      'color': Color(0xFFB5AF3D),
    },
    {
      'key': 'HR',
      'label': 'HR',
      'color': Color(0xFF405162),
    },
    {
      'key': 'Knowledge Hub',
      'label': 'Knowledge Hub',
      'color': Color(0xFFCD7F32),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final count = widget.filterCounts[filter['key']] ?? 0;

          return CalendarFilterChip(
            count: count.toString(),
            keys: filter['key'],
            label: filter['label'],
            isSelected: widget.selectedFilter == filter['key'],
            color: filter['color'],
            onTap: () {
              widget.onFilterChanged(filter['key']);
            },
          );
        },
      ),
    );
  }
}