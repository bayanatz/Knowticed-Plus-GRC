import 'package:flutter/material.dart';
import 'package:demo_app/features/settings/presentation/ui/pages/mark_down.dart';
import 'package:demo_app/features/settings/core_widgets/main_widget/filters_appbar.dart';
import 'package:demo_app/core/theme/app_font_size.dart';

/// Full-screen Terms & Conditions page.
/// Replaces the removed demo_app version; reuses the same MarkDownWidget
/// that TermsDialog shows in dialog form.
class TermsConditions extends StatefulWidget {
  const TermsConditions({super.key});

  @override
  State<TermsConditions> createState() => _TermsConditionsState();
}

class _TermsConditionsState extends State<TermsConditions> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 0.04.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 0.02.h),
                child: const FiltersAppBar(
                  hideIcon: true,
                  imageUrl: "assets/icons_assets/inventory_assets/requests.svg",
                  title: "Terms And Conditions",
                ),
              ),
              const Expanded(child: MarkDownWidget()),
            ],
          ),
        ),
      ),
    );
  }
}
