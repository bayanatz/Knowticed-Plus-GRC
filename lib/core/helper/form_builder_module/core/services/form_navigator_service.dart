import 'package:flutter/material.dart';

class FormBuilderNavigatorService {
  // ✅ Singleton pattern
  static final FormBuilderNavigatorService _instance = FormBuilderNavigatorService._internal();
  factory FormBuilderNavigatorService() => _instance;
  FormBuilderNavigatorService._internal();

  // ✅ Navigator key
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // ✅ Helper methods
  NavigatorState? get currentState => navigatorKey.currentState;

  bool get isReady => currentState != null;

  Future<T?>? navigateTo<T>(String routeName, {Object? arguments}) {
    if (currentState != null) {
      return currentState!.pushNamed<T>(routeName, arguments: arguments);
    }
    
    return null;
  }

  void pop<T>([T? result]) {
    if (currentState != null && currentState!.canPop()) {
      currentState!.pop(result);
    }
  }

  void popToFirst() {
    if (currentState != null) {
      currentState!.popUntil((route) => route.isFirst);
    }
  }
}