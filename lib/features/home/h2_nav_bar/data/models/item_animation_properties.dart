/// Module: home/h2_nav_bar
///
///*************************** FILE INFO ****************************///
/// File Name: item_animation_properties.dart
/// Purpose: Declares `ItemAnimationProperties`.
/// Author: Knowticed Plus team
/// Updated: 11/8/2026 - Extracted from the oversized model.dart as part of
///          breaking up the vendored persistent-nav-bar god files.
library;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ItemAnimationProperties {
  const ItemAnimationProperties({this.duration, this.curve});
  final Duration? duration;
  final Curve? curve;
}
