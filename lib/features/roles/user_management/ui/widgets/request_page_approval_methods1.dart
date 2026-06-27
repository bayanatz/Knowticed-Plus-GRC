part of '../pages/request_page_approval.dart';

extension RequestPageApprovalMethods1 on _RequestPageApprovalState {
  // ─── NEW: Update a single request status in Firestore ───────────────────────
  Future<void> _updateRequestStatus(String requestId, String newStatus) async {
    // Mark as loading
    setState(() => _actioningIds.add(requestId));

    try {
      final String basePath = getBaseUrl('Modules');

      await FirebaseFirestore.instance
          .doc('$basePath/roles')
          .collection('Employees_Request')
          .doc(requestId)
          .update({
        'status': newStatus,
        'actionDate': FieldValue.serverTimestamp(),
      });

      // Update local list so UI reflects immediately without full reload
      setState(() {
        final idx = allRequests.indexWhere((r) => r['id'] == requestId);
        if (idx != -1) {
          allRequests[idx]['status'] = newStatus;
        }
        _updateCounts();
        _filterRequests();
        _actioningIds.remove(requestId);
      });

      Get.snackbar(
        newStatus == 'approved' ? 'Approved ✓' : 'Rejected ✗',
        'Request has been ${newStatus} successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor:
        newStatus == 'approved' ? AppColors.green : Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      setState(() => _actioningIds.remove(requestId));
      Get.snackbar(
        'Error'.tr,
        'Failed to update request: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
  // ─── NEW: Confirmation dialog before approve / reject ───────────────────────
  Future<void> _showConfirmDialog({
    required String requestId,
    required String action, // 'approved' | 'rejected'
  }) async {
    final isApprove = action == 'approved';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        title: Row(
          children: [
            Icon(
              isApprove ? Icons.check_circle_outline : Icons.cancel_outlined,
              color: isApprove ? Colors.green : Colors.red,
              size: 24.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              isApprove ? 'Approve Request' : 'Reject Request',
              style: StyleText.fontSize16Weight500,
            ),
          ],
        ),
        content: Text(
          isApprove
              ? 'Are you sure you want to approve this request?'
              : 'Are you sure you want to reject this request?',
          style: StyleText.fontSize14Weight400,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Cancel',
              style: StyleText.fontSize14Weight400.copyWith(
                  color: AppColors.secondaryText),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:
              isApprove ? AppColors.green : Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r)),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              isApprove ? 'Approve' : 'Reject',
              style: StyleText.fontSize14Weight500
                  .copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      RoleLogService.log(action == 'approved'
          ? RoleLogService.actionApproveRequest
          : RoleLogService.actionRejectRequest);
      await _updateRequestStatus(requestId, action);
    }
  }
  void _updateCounts() {
    totalRequests = allRequests.length;
    pendingCount = allRequests.where((r) => r['status'] == 'pending').length;
    approvedCount = allRequests.where((r) => r['status'] == 'approved').length;
    rejectedCount = allRequests.where((r) => r['status'] == 'rejected').length;
  }
  void _filterRequests() {
    List<Map<String, dynamic>> filtered = List.from(allRequests);

    if (selectStatus != "All") {
      filtered = filtered.where((request) {
        if (selectStatus == S.of(context).Approved) {
          return request['status'] == 'approved';
        } else if (selectStatus == 'Pending') {
          return request['status'] == 'pending';
        } else if (selectStatus == 'Rejected') {
          return request['status'] == 'rejected';
        }
        return true;
      }).toList();
    }

    if (searchController.text.isNotEmpty) {
      final searchText = searchController.text.toLowerCase();
      filtered = filtered.where((request) {
        final title = request['title'].toString().toLowerCase();
        return title.contains(searchText);
      }).toList();
    }

    setState(() {
      filteredRequests = filtered;
    });
  }
  String _formatDate(int timestamp) {
    if (timestamp == 0) return '-';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('dd MMM yyyy').format(date);
  }
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return AppColors.green;
      case 'pending':
        return AppColors.yellow;
      case 'rejected':
        return Colors.red[500]!;
      default:
        return AppColors.secondaryText;
    }
  }
  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return S.of(context).Approved;
      case 'pending':
        return 'Pending';
      case 'rejected':
        return 'Rejected';
      default:
        return status;
    }
  }
  // ─── Reusable info row ───────────────────────────────────────────────────────
  Widget _infoRow({
    required String icon,
    required String label,
    required String value,
    required bool lightMode,
    bool ellipsis = false,
  }) {
    return Row(
      children: [
        CustomSvg(
          assetPath: icon,
          width: 14.w,
          height: 14.h,
          fit: BoxFit.scaleDown,
        ),
        SizedBox(width: 4.w),
        Text(
          label,
          style: StyleText.fontSize12Weight400.copyWith(
              color:
              AppColors.text),
        ),
        ellipsis
            ? Expanded(
          child: Text(
            value,
            style: StyleText.fontSize12Weight400.copyWith(
                color: AppColors.text),
            overflow: TextOverflow.ellipsis,
          ),
        )
            : Text(
          value,
          style: StyleText.fontSize12Weight400.copyWith(
              color: AppColors.text),
        ),
      ],
    );
  }
  Widget filterSection() {
    final s = S.of(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _statusChip("$totalRequests", s.all,
              isSelected: selectStatus == s.all,
              onTap: () {
                setState(() {
                  selectStatus = s.all;
                  _filterRequests();
                });
              },
              labelColor: AppColors.text),
          _statusChip("$approvedCount", s.Approved,
              isSelected: selectStatus == s.Approved,
              onTap: () {
                setState(() {
                  selectStatus = s.Approved;
                  _filterRequests();
                });
              },
              labelColor: AppColors.green),
          _statusChip("$pendingCount", 'Pending',
              isSelected: selectStatus == 'Pending',
              onTap: () {
                setState(() {
                  selectStatus = 'Pending';
                  _filterRequests();
                });
              },
              labelColor: AppColors.primary,),
          _statusChip("$rejectedCount", 'Rejected',
              isSelected: selectStatus == 'Rejected',
              onTap: () {
                setState(() {
                  selectStatus = 'Rejected';
                  _filterRequests();
                });
              },
              labelColor: Colors.red[500]!),
        ],
      ),
    );
  }
  Widget _statusChip(String count, String label,
      {required bool isSelected,
        required Color labelColor,
        required VoidCallback onTap}) {
    var light = Theme.of(context).brightness == Brightness.light;
    var isMobile = context.isPhone;

    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: isMobile ? 35.sp : 45.sp,
            height: isMobile ? 35.sp : 45.sp,
            decoration: BoxDecoration(
              color: light
                  ? isSelected
                  ? AppColors.primary
                  : AppColors.white
                  : isSelected
                  ? AppColors.primary
                  : AppColors.card,
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Center(
              child: Text(
                count,
                style: isMobile
                    ? StyleText.fontSize14Weight400.copyWith(
                  color: light
                      ? isSelected
                      ? AppColors.textButton
                      : AppColors.secondaryText
                      : isSelected
                      ? AppColors.textButton
                      : AppColors.text,
                )
                    : StyleText.fontSize20Weight500.copyWith(
                  color: light
                      ? isSelected
                      ? AppColors.textButton
                      : AppColors.secondaryText
                      : isSelected
                      ? AppColors.textButton
                      : AppColors.text,
                ),
              ),
            ),
          ),
          SizedBox(width: 16.sp),
          SizedBox(
            child: Text(
              label,
              style: isMobile
                  ? StyleText.fontSize14Weight600.copyWith(color: labelColor)
                  : StyleText.fontSize16Weight600.copyWith(color: labelColor),
            ),
          ),
          SizedBox(width: 30.sp),
        ],
      ),
    );
  }
}
