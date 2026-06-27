part of '../pages/uoload_file_details.dart';

class CustomExcelTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? errorText;
  final double width;
  final double height;
  final bool showHeader;
  final FocusNode? focusNode;
  final String headerLabel;
  final String placeholder;
  final Function(String value)? onChanged;
  final int? rowIndex;
  final Function(String key, int index)? validator;

  const CustomExcelTextField({
    super.key,
    required this.controller,
    required this.placeholder,
    this.errorText,
    this.width = 200,
    this.height = 36,
    this.showHeader = false,
    this.headerLabel = '',
    this.onChanged,
    this.focusNode,
    this.rowIndex,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final isEmail = placeholder.toLowerCase().contains('email');
    final isPhone = placeholder.toLowerCase().contains('phone');

    return Container(
      width: width, // Example: 250
      child:
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showHeader)
            Padding(
              padding: const EdgeInsets.only(bottom: 8,),
              child: Align(
                alignment: headerLabel.trim().contains(RegExp(r'[\u0600-\u06FF]'))
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Text(
                  headerLabel,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),

          SizedBox(
            width: width,
            child: Directionality(
              textDirection: placeholder.trim().contains(RegExp(r'[\u0600-\u06FF]')) ? TextDirection.rtl : TextDirection.ltr,
              child: Row(
                children: [
                  // ❗ Always reserve icon space (clickable if errorText exists)
                  GestureDetector(
                    onTap: () {
                      if (errorText != null) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            contentPadding: EdgeInsets.symmetric(vertical: 24.sp, horizontal: 16.sp),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                            content: Container(
                              width: 410.sp,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Lottie.asset('assets/lottie/rejected.json', width: 70.sp, height: 70.sp),
                                  SizedBox(height: 16.sp),
                                  Text(
                                    'Warning $placeholder',
                                    style: StyleText.fontSize20Weight600.copyWith(
                                      color: Theme.of(context).brightness == Brightness.light
                                          ? AppColors.blackButton
                                          : AppColors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 16.sp),
                                  Text(
                                    'The specified $placeholder $errorText! .Please verify the entry',
                                    style: StyleText.fontSize14Weight400.copyWith(color: Colors.grey.shade600),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                    },
                    child: errorText != null
                        ? Container(
                      width: 20.sp,
                      height: height,
                      alignment: Alignment.center,
                      child: SvgPicture.asset(
                        "assets/error.svg",
                        width: 20.sp,
                        height: 20.sp,
                        fit: BoxFit.cover,
                      ),
                    )
                        : SizedBox(),
                  ),

                  errorText != null? SizedBox(width: 8.sp) : SizedBox(),

                  // 📦 TextField
                  Expanded(
                    child: SizedBox(
                      height: height,
                      child: TextFormField(
                        controller: controller,
                        focusNode: focusNode,
                        onChanged: (value) {
                          if (validator != null && rowIndex != null) {
                            validator!(placeholder, rowIndex!);
                          }
                          if (onChanged != null) onChanged!(value);
                        },
                        style: StyleText.fontSize14Weight500.copyWith(
                            color: Theme.of(context).brightness == Brightness.light ? AppColors.blackButton : AppColors.white
                        ),
                        inputFormatters: isEmail
                            ? [FilteringTextInputFormatter.deny(RegExp(r'\s'))]
                            : null,
                        keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
                        decoration: InputDecoration(
                          hintText: placeholder,
                          hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                          contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          filled: true,
                          fillColor: Theme.of(context).brightness == Brightness.light
                              ? AppColors.background
                              : AppColors.background,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: errorText != null ? Colors.red : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: errorText != null ? Colors.red : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.red, width: 1.5),
                          ),
                          errorText: null, // No default error text
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
