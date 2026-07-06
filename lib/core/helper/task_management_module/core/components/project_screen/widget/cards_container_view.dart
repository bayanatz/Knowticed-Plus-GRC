/// Date Created: 17/2/2025
/// by: Islam Diab
/// objective: Display a list of cards, either as a search result or filtered cards.
library;

import 'package:flutter/material.dart';
import 'package:demo_app/core/helper/task_management_module/core/components/task_container_section_project_screen.dart';
import 'package:demo_app/core/helper/task_management_module/core/constant/screen_size.dart';
import 'package:demo_app/core/helper/task_management_module/task/data/model/card_model/card_model.dart';

class CardsContainerView extends StatelessWidget {
  final List<CardModel> cards;
  final dynamic boardModel;
  final String projectName;
  final int selectedIndex;

  const CardsContainerView({
    super.key,
    required this.cards,
    required this.boardModel,
    required this.projectName,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 0.02.h),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: CardsContainer(
                      cards: cards,
                      boardModel: boardModel,
                      filterIndex: selectedIndex,
                      totalLength: cards.length,
                      taskTitle: 'Task Title',
                      onPressed: () {},
                      projectName: projectName,
                      editTime: "14 Apr 2024 at 8:00 am",
                    ),
                  ),
                ],
              ),
              SizedBox(height: 0.02.h),
            ],
          ),
        ),
      ),
    );
  }
}
