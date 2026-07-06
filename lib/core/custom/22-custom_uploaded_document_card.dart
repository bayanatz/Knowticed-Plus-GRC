// Figma node 6550:9945 — product warranty / attachment card with
// removable file row and expiry date.
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:demo_app/core/custom/32-custom_svg.dart';

import 'package:demo_app/core/theme/app_colors.dart';
import 'package:demo_app/core/helper/knowledge_hub_module/core/shared_functions/get_file_icon.dart';
import 'package:demo_app/core/custom/16-custom_card_styles.dart';

/// Attachment card: title + file row (thumbnail, name, size, remove badge)
/// + trailing date.
///
/// ```dart
/// ProductWarrantyCard(
///   title: 'Product Warranty',
///   fileName: 'Watermark.png',
///   fileSize: '2.5 MB',
///   date: '29 Dec 2023',
///   onRemove: () {},
///   onTapFile: () {},
/// )
/// ```
class ProductWarrantyCard extends StatelessWidget {
  final String title;
  final String fileName;
  final String? fileSize;
  final String? date;
  final Widget? fileIcon;
  final VoidCallback? onRemove;
  final VoidCallback? onTapFile;
  final double? width;

  const ProductWarrantyCard({
    super.key,
    required this.title,
    required this.fileName,
    this.fileSize,
    this.date,
    this.fileIcon,
    this.onRemove,
    this.onTapFile,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? 283.w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: CardStyles.label(12)),
          SizedBox(height: 6.h),
          InkWell(
            onTap: onTapFile,
            borderRadius: CardStyles.radius(),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: CardStyles.radius(),
                boxShadow: CardStyles.shadow,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // File thumbnail box.
                  Container(
                    width: 30.r,
                    height: 30.r,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Center(
                      child: SizedBox(
                        width: 18.r,
                        height: 18.r,
                        child: FittedBox(
                          child: fileIcon ?? _defaultFileIcon(),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  // File name + size
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          fileName,
                          style: CardStyles.value(12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (fileSize != null)
                          Text(fileSize!, style: CardStyles.label(10)),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  // Date + Remove stacked vertically
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [

                      if (onRemove != null) ...[
                        SizedBox(height: 2.h),
                        InkWell(
                          onTap: onRemove,
                          customBorder: const CircleBorder(),
                          child: SizedBox(
                            width: 15.r,
                            height: 15.r,
                            child: CustomSvg(assetPath: CardSvg.remove),
                          ),
                        ),
                      ],

                      SizedBox(height: 2.h),

                      if (date != null)
                        Text(date!, style: CardStyles.label(10)),

                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Picks the SVG by file extension (pdf, doc, xlsx, image, video...).
  Widget _defaultFileIcon() {
    final ext = fileName.contains('.') ? fileName.split('.').last : '';
    return CardSvg.icon(getFileIcon(ext));
  }
}
