part of '../pages/user_mangement_details_request.dart';

extension UmdrMethods2 on _UserManagementDetailsRequestSettingsState {
  // ─── Status / action button area ─────────────────────────────────────────
  Widget _buildStatusButton() {
    // Already actioned → show read-only badge
    if (status != 'pending') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: _getStatusColor(status)),
            ),
            width: 200.w,
            height: 36.h,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomSvg(
                  assetPath: _getStatusIcon(status),
                  width: 24.w,
                  height: 24.h,
                  fit: BoxFit.scaleDown,
                ),
                SizedBox(width: 8.w),
                Text(
                  _getStatusLabel(status),
                  style: StyleText.fontSize16Weight500.copyWith(
                    color: _getStatusColor(status),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    // Saving in progress
    if (isProcessing) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            width: 24.w,
            height: 24.h,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ],
      );
    }

    // ── Pending → Approve + Reject buttons ───────────────────────────────────
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Reject
        GestureDetector(
          onTap: () => _showConfirmDialog(action: 'rejected'),
          child: Container(
            width: 150.w,
            height: 38.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Colors.red, width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomSvg(
                    assetPath: "assets/state/reject.svg",
                    width: 18.w,
                    height: 18.h,
                    fit: BoxFit.scaleDown),
                SizedBox(width: 6.w),
                Text(
                  S.of(context).reject,
                  style: StyleText.fontSize16Weight500
                      .copyWith(color: Colors.red),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 12.w),
        // Approve
        GestureDetector(
          onTap: () => _showConfirmDialog(action: 'approved'),
          child: Container(
            width: 150.w,
            height: 38.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Color(0xFF34C759), width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomSvg(
                    assetPath: "assets/state/approved.svg",
                    width: 18.w,
                    height: 18.h,
                    fit: BoxFit.scaleDown),
                SizedBox(width: 6.w),
                Text(
                  S.of(context).approve,
                  style: StyleText.fontSize16Weight500
                      .copyWith(color: Color(0xFF34C759)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  Widget _buildContent(
      bool lightMode,
      bool isMobile,
      bool isArabic,
      String creatorName,
      String creatorTitle,
      String creatorDepartment,
      String creatorPhone,
      String creatorEmail,
      String creatorPhoto,
      bool isNetworkPhoto,
      ) {
    if (isLoading) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(50.sp),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (changes.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(50.sp),
          child: Text(
            'No changes found in this request',
            style: StyleText.fontSize16Weight500.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(lightMode),
        SizedBox(height: 8.h),
        Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
                color: AppColors.card,
              ),
              child: Padding(
                padding: EdgeInsets.all(15.sp),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 65.w,
                      height: 80.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey.shade200,
                      ),
                      child: ClipOval(
                        child: !isNetworkPhoto
                            ? Image.network(
                          creatorPhoto,
                          width: 80.w,
                          height: 80.h,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return CustomSvg(
                              assetPath: "assets/images/male.svg",
                              width: 80.w,
                              height: 80.h,
                              fit: BoxFit.cover,
                            );
                          },
                        )
                            : CustomSvg(
                          assetPath: creatorPhoto,
                          width: 80.w,
                          height: 80.h,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(width: 14.sp),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            FormatHelper.capitalize(creatorName),
                            style: StyleText.fontSize16Weight500.copyWith(
                              color: AppColors.text,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 16.sp),
                          isMobile
                              ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDetailRow(
                                  lightMode,
                                  "assets/images/case.svg",
                                  S.of(context).title,
                                  creatorTitle),
                              SizedBox(height: 12.h),
                              _buildDetailRow(
                                  lightMode,
                                  "assets/images/department.svg",
                                  S.of(context).department,
                                  creatorDepartment),
                              SizedBox(height: 12.h),
                              _buildDetailRow(
                                  lightMode,
                                  "assets/images/phone_number.svg",
                                  S.of(context).phoneNumber,
                                  creatorPhone),
                              SizedBox(height: 12.h),
                              _buildDetailRow(
                                  lightMode,
                                  "assets/images/email.svg",
                                  S.of(context).email,
                                  creatorEmail),
                            ],
                          )
                              : Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    _buildDetailRow(
                                        lightMode,
                                        "assets/svg/job_title_new.svg",
                                        S.of(context).title,
                                        creatorTitle),
                                    SizedBox(height: 18.h),
                                    _buildDetailRow(
                                        lightMode,
                                        "assets/images/department.svg",
                                        S.of(context).department,
                                        creatorDepartment),
                                  ],
                                ),
                              ),
                              SizedBox(width: 24.sp),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    _buildDetailRow(
                                        lightMode,
                                        "assets/images/phone_number.svg",
                                        S.of(context).phoneNumber,
                                        creatorPhone),
                                    SizedBox(height: 18.h),
                                    _buildDetailRow(
                                        lightMode,
                                        "assets/images/email.svg",
                                        S.of(context).email,
                                        creatorEmail),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 10.sp,
              left: isArabic ? 10.sp : null,
              right: isArabic ? null : 10.sp,
              child: customButtonWithImage(
                title: isMobile ? "" : "Chat".tr,
                function: () {},
                color: AppColors.primary,
                width: isMobile ? 38.w : 150.w,
                height: 38.h,
                radius: 4.r,
                space: 8.sp,
                heightImage: 25.sp,
                colorBorder: Colors.transparent,
                widthImage: 25.sp,
                image: 'assets/roles_icons/Messages.svg',
                textStyle: StyleText.fontSize14Weight400
                    .copyWith(color: AppColors.textButton),
              ),
            ),
          ],
        ),
        SizedBox(height: 15.h),
        ...changes
            .map((change) => _buildSection(
          lightMode: lightMode,
          sectionTitle: _translateSectionTitle(section),
          isMobile: isMobile,
          fieldName: change['fieldName']!,
          oldValue: change['oldValue']!,
          newValue: change['newValue']!,
        ))
            .toList(),
        _buildRequestNoteSection(lightMode),
        SizedBox(height: 16.h),
      ],
    );
  }
  Widget _buildDetailRow(
      bool lightMode, String iconPath, String label, String value) {
    return Row(
      children: [
        CustomSvg(
            assetPath: iconPath, width: 15.w, height: 15.h, fit: BoxFit.fill),
        SizedBox(width: 8.sp),
        Text(
          "$label: ",
          style: StyleText.fontSize14Weight500
              .copyWith(color: AppColors.secondaryText),
        ),
        Expanded(
          child: Text(
            FormatHelper.capitalize(value),
            style:
            StyleText.fontSize14Weight500.copyWith(color: AppColors.text),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }
  Widget _buildHeader(bool lightMode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          S.of(context).requestDetails,
          style: StyleText.fontSize16Weight600.copyWith(
            color: lightMode
                ? AppColors.blackButton
                : AppColors.white,
          ),
        ),
        Spacer(),
        Text(
          "${S.of(context).requestedDate}: ",
          style: StyleText.fontSize12Weight400.copyWith(
            color: lightMode
                ? AppColors.secondaryText
                : AppColors.grey,
          ),
        ),
        Text(
          _formatDate(requestTime),
          style: StyleText.fontSize12Weight400.copyWith(
            color: lightMode
                ? AppColors.blackButton
                : AppColors.white,
          ),
        ),
      ],
    );
  }
}
