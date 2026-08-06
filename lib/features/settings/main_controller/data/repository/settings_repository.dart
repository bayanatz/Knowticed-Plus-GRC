
import 'package:grc_module/features/roles/r4_active_directory/data/models/emplyees_model/new_employee_model.dart';
import 'package:grc_module/features/settings/main_controller/data/data_source/settings_remot_data_source.dart';


class SettingsRepository{
  SettingsRemoteDataSource _remoteDataSource = SettingsRemoteDataSource();
updateEmployee(NewEmployeeModelHistory employee) async
{
return await _remoteDataSource.updateEmployeeModel(employee:employee, employeeId:employee.id!);
}
}