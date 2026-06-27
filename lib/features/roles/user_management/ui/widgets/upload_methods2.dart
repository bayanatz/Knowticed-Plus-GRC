part of '../pages/uoload_file_details.dart';

extension UploadMethods2 on _UploadFileDetailsTabletRolesState {
  // ✅ UPDATE ERROR LOCATION LIST
  void updateErrorLocations() {
    errorLocations.clear();
    for (int row = 0; row < validationErrors.length; row++) {
      validationErrors[row].forEach((header, error) {
        errorLocations.add(MapEntry(row, header));
      });
    }

    // Reset current index if no errors or index is out of bounds
    if (errorLocations.isEmpty) {
      currentErrorIndex = -1;
    } else if (currentErrorIndex >= errorLocations.length || currentErrorIndex < 0) {
      currentErrorIndex = 0;
    }

  }
  void focusErrorField(bool forward) {
    if (errorLocations.isEmpty) {
      return;
    }

    setState(() {
      if (forward) {
        currentErrorIndex = (currentErrorIndex + 1) % errorLocations.length;
      } else {
        currentErrorIndex = (currentErrorIndex - 1 + errorLocations.length) % errorLocations.length;
      }
    });

    final entry = errorLocations[currentErrorIndex];
    final rowIndex = entry.key;
    final header = entry.value;


    final controller = formData[rowIndex][header];
    final node = focusNodes[rowIndex][header];
    final key = fieldKeys[rowIndex][header];

    // Scroll to the field first, then focus
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 100), () {
        final contextToScroll = key?.currentContext;
        if (contextToScroll != null) {
          Scrollable.ensureVisible(
            contextToScroll,
            duration: const Duration(milliseconds: 500),
            alignment: 0.3,
            curve: Curves.easeInOut,
          ).then((_) {
            // Focus after scrolling is complete
            if (controller != null && node != null) {
              controller.selection = TextSelection(baseOffset: 0, extentOffset: controller.text.length);
              FocusScope.of(context).requestFocus(node);
            }
          });
        } else {
        }
      });
    });
  }
  void showErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Container(
          height: 100,
          width: 250,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 50,
                child: Lottie.asset('assets/lottie/rejected.json'),
              ),
              SizedBox(height: 20),
              Text(
                "You must solve these errors",
                style: StyleText.fontSize20Weight600.copyWith(
                  color: AppColors.red,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        actions: [
          customButton(
            title: "Ok ",
            function: () {
              Navigator.pop(context);
            },
            textStyle: StyleText.fontSize16Weight500.copyWith(
                color: AppColors.blackButton
            ),
            width: 150.sp,
            height: 38.sp,
            radius: 8.r,
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }

}
