part of './main_core_department_cubit.dart';

sealed class MainCoreDepartmentState {
  const MainCoreDepartmentState();
}

final class MainCoreDepartmentInitial extends MainCoreDepartmentState {
  const MainCoreDepartmentInitial();
}

final class MainCoreDepartmentLoading extends MainCoreDepartmentState {
  const MainCoreDepartmentLoading();
}

final class MainCoreDepartmentLoaded extends MainCoreDepartmentState {
  final List<DepartmentModelPro> departments;
  final List<String> englishNames;
  final List<String> arabicNames;
  final List<String> departmentIds;

  const MainCoreDepartmentLoaded({
    required this.departments,
    required this.englishNames,
    required this.arabicNames,
    required this.departmentIds,
  });
}

final class MainCoreDepartmentError extends MainCoreDepartmentState {
  final String message;

  const MainCoreDepartmentError(this.message);
}
