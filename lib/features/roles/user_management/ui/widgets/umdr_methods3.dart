part of '../pages/user_mangement_details_request.dart';

extension UmdrMethods3 on _UserManagementDetailsRequestSettingsState {
  Widget _buildSection({
    required bool lightMode,
    required String sectionTitle,
    required bool isMobile,
    required String fieldName,
    required String oldValue,
    required String newValue,
  }) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.r),
            color: AppColors.card,
          ),
          child: Padding(
            padding: EdgeInsets.only(
                right: 15.sp, left: 15.sp, top: 5.sp, bottom: 15.sp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 15.h),
                _buildSectionHeader(lightMode, sectionTitle),
                SizedBox(height: 20.h),
                isMobile
                    ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDataColumn(
                      lightMode: lightMode,
                      title: S.of(context).current_details,
                      titleColor: AppColors.text,
                      value: oldValue,
                      fieldName: fieldName,
                    ),
                    SizedBox(height: 12.h),
                    _buildDataColumn(
                      lightMode: lightMode,
                      title: S.of(context).new_details,
                      titleColor: Colors.green,
                      value: newValue,
                      fieldName: fieldName,
                    ),
                  ],
                )
                    : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildDataColumn(
                        lightMode: lightMode,
                        title: S.of(context).current_details,
                        titleColor: lightMode
                            ? AppColors.blackButton
                            : AppColors.white,
                        value: oldValue,
                        fieldName: fieldName,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: _buildDataColumn(
                        lightMode: lightMode,
                        title: S.of(context).new_details,
                        titleColor: Colors.green,
                        value: newValue,
                        fieldName: fieldName,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 16.h),
      ],
    );
  }
  Widget _buildSectionHeader(bool lightMode, String sectionTitle) {
    bool isInsuranceSection =
        sectionTitle.contains('Insurance') || sectionTitle.contains('التأمين');

    return Row(
      children: [
        Container(
          width: 30.w,
          height: 30.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.r),
            color: AppColors.primary.withOpacity(.15),
          ),
          child: Center(
            child: CustomSvg(
              assetPath: isInsuranceSection
                  ? "assets/icons_assets/main_icons_assets/Insurance Details.svg"
                  : "assets/icons_assets/main_icons_assets/Emergency Contact.svg",
              width: 16.w,
              height: 16.h,
              fit: BoxFit.fill,
              color: AppColors.primary,
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          FormatHelper.capitalize(sectionTitle),
          style: StyleText.fontSize18Weight500.copyWith(
            color: lightMode
                ? AppColors.blackButton
                : AppColors.white,
          ),
        ),
      ],
    );
  }
  Widget _buildDataColumn({
    required bool lightMode,
    required String title,
    required Color titleColor,
    required String value,
    required String fieldName,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          FormatHelper.capitalize(title),
          style: StyleText.fontSize16Weight600.copyWith(color: titleColor),
        ),
        SizedBox(height: 15.h),
        CustomTextField(
          label: FormatHelper.capitalize(_getFieldLabel(fieldName)),
          hint: _getFieldLabel(fieldName),
          controller:
          TextEditingController(text: value.isEmpty ? '-' : value),
          enabled: false,
          fillColor: title.contains('current') || title.contains('الحالية')
              ? (lightMode ? AppColors.background : AppColors.background)
              : null,
        ),
      ],
    );
  }
  Widget _buildRequestNoteSection(bool lightMode) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.r), color: AppColors.card),
      child: Padding(
        padding: EdgeInsets.all(15.sp),
        child: Column(
          children: [
            CustomValidatedTextField(
              hint: S.of(context).requestNote,
              controller: requestNoteController,
              enabled: false,
              label: S.of(context).requestNote,
              submitted: submitted,
              maxLines: 3,
              height: 72,
              textDirection:
              isArabic ? ui.TextDirection.rtl : ui.TextDirection.ltr,
              showCharCount: true,
            ),
            SizedBox(height: 20.h),

            // ── Shows Approve+Reject when pending, badge otherwise ────────
            _buildStatusButton(),
          ],
        ),
      ),
    );
  }
}
