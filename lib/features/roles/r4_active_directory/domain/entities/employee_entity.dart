



import '../../data/models/emplyees_model/mobile_phone_model.dart';
import '../../data/models/emplyees_model/new_employee_model.dart';
import '../../data/models/emplyees_model/academic_history_current_entity.dart';
import 'package:grc_module/core/helper/main_helper/phone_number.dart';

class EmployeeEntityController {
  /// Converts NewEmployeeModelHistory to EmployeeEntity (PRIMARY METHOD)
  EmployeeEntityPro fromHistoryModel(NewEmployeeModelHistory model) {
    return EmployeeEntityPro(
      id: model.id,
      firstName: model.firstName.lastOrNull,
      middleName: model.middleName.lastOrNull,
      lastName: model.lastName.lastOrNull,
      firstNameInArabic: model.firstNameInArabic.lastOrNull,
      middleNameInArabic: model.middleNameInArabic.lastOrNull,
      lastNameInArabic: model.lastNameInArabic.lastOrNull,
      nationalId: model.nationalId.lastOrNull,
      nationalIdExpirationDate: model.nationalIdExpirationDate.lastOrNull,
      nationality: model.nationality.lastOrNull,
      passport: model.passport.lastOrNull,
      passportExpirationDate: model.passportExpirationDate.lastOrNull,
      email: model.email.lastOrNull,
      mobilePhone: _extractMobilePhone(model.mobilePhone),
      officePhone: model.officePhone.lastOrNull,
      homePhone: model.homePhone.lastOrNull,
      extension: model.extension.lastOrNull,
      birthDay: model.birthDay.lastOrNull,
      gender: model.gender.lastOrNull,
      country: model.country.lastOrNull,
      province: model.province.lastOrNull,
      city: model.city.lastOrNull,
      postalCode: model.postalCode.lastOrNull,
      street: model.street.lastOrNull,
      maritalStatus: model.maritalStatus.lastOrNull,
      language: model.language.lastOrNull,
      departmentId: model.departmentId.lastOrNull,
      supervisor: model.supervisor.lastOrNull,
      role: model.role.lastOrNull,
      title: model.title.lastOrNull,
      titleInArabic: model.titleInArabic.lastOrNull,
      workLocation: model.workLocation.lastOrNull,
      drivingLicenseId: model.drivingLicenseId.lastOrNull,
      carPlates: model.carPlates.lastOrNull,
      academicHistory: _extractAcademicHistory(model.academicHistory),
      bio: model.bio.lastOrNull,
      photo: model.photo.lastOrNull,
      skills: model.skills.lastOrNull,
      hobbies: model.hobbies.lastOrNull,
      status: model.status.lastOrNull,
      password: model.password,
      defaultPassword: model.defaultPassword,
      firstLogin: model.firstLogin,
      lastLogin: model.lastLogin,
      deactivationDate: model.deactivationDate,
      activationDate: model.activationDate,
    );
  }

  /// Converts List<NewEmployeeModelHistory> to List<EmployeeEntity> (PRIMARY METHOD)
  List<EmployeeEntityPro> fromHistoryModelList(List<NewEmployeeModelHistory> models) {
    return models.map((model) => fromHistoryModel(model)).toList();
  }

  /// Helper method to extract mobile phone from history list
  static PhoneNumber? _extractMobilePhone(List<MobilePhone> mobilePhoneList) {
    if (mobilePhoneList.isEmpty) return null;

    MobilePhone lastPhone = mobilePhoneList.last;
    return PhoneNumber(
      countryISOCode: '',
      number: lastPhone.phones?.toString() ?? '',
      countryCode: lastPhone.countryCode?.toString() ?? '',
      countryApp: lastPhone.countryApp?.toString(),
    );
  }

  /// Helper method to extract academic history from history list
  static AcademicHistoryEntity? _extractAcademicHistory(List<Map<String, dynamic>> academicHistoryList) {
    if (academicHistoryList.isEmpty) return null;

    Map<String, dynamic> lastHistory = academicHistoryList.last;
    return AcademicHistoryEntity(
      gpa: lastHistory['gpa']?.toString(),
      graduateFrom: lastHistory['graduateFrom']?.toString(),
      university: lastHistory['university']?.toString(),
      yearOfGraduation: lastHistory['yearOfGraduation']?.toString(),
      graduateFromStatus: lastHistory['graduateFromStatus']?.toString(),
      universityStatus: lastHistory['universityStatus']?.toString(),
      yearOfGraduationStatus: lastHistory['yearOfGraduationStatus']?.toString(),
      gpaStatus: lastHistory['gpaStatus']?.toString(),
    );
  }

  // ========================================================================
  // LEGACY SUPPORT (Keep for backward compatibility if needed)
  // ========================================================================

  /// Converts NewEmployeeModel to EmployeeEntity (Legacy support)
  EmployeeEntityPro fromModel(NewEmployeeModel model) {
    return EmployeeEntityPro(
      id: model.id,
      firstName: model.firstName?.firstNames?.lastOrNull,
      middleName: model.middleName?.middleName?.lastOrNull,
      lastName: model.lastName?.lastNames?.lastOrNull,
      firstNameInArabic:
      model.firstNameInArabic?.firstNamesInArabic?.lastOrNull,
      middleNameInArabic:
      model.middleNameInArabic?.middleNameInArabic?.lastOrNull,
      lastNameInArabic: model.lastNameInArabic?.lastNamesInArabic?.lastOrNull,
      nationalId: model.nationalId?.nationalId?.lastOrNull,
      nationalIdExpirationDate:
      model.nationalIdExpirationDate?.nationalIdExpirationDate?.lastOrNull,
      nationality: model.nationality?.nationality?.lastOrNull,
      passport: model.passport?.passport?.lastOrNull,
      passportExpirationDate:
      model.passportExpirationDate?.passportExpirationDate?.lastOrNull,
      email: model.email?.emails?.lastOrNull,
      mobilePhone: PhoneNumber(
          countryISOCode: '',
          number: model.mobilePhone?.phones?.lastOrNull ?? '',
          countryCode: model.mobilePhone?.countryCode?.lastOrNull ?? '',
          countryApp: model.mobilePhone?.countryApp?.lastOrNull),
      officePhone: model.officePhone?.phones?.lastOrNull,
      homePhone: model.homePhone?.phones?.lastOrNull,
      extension: model.extension?.extension?.lastOrNull,
      birthDay: model.birthDay?.birthDays?.lastOrNull,
      gender: model.gender?.gender?.lastOrNull,
      country: model.country?.country?.lastOrNull,
      province: model.province?.province?.lastOrNull,
      city: model.city?.city?.lastOrNull,
      postalCode: model.postalCode?.postalCode?.lastOrNull,
      street: model.street?.street?.lastOrNull,
      maritalStatus: model.maritalStatus?.maritalStatus?.lastOrNull,
      language: model.language?.languages?.lastOrNull,
      departmentId: model.departmentid?.departmentId?.lastOrNull,
      supervisor: model.supervisor?.supervisors?.lastOrNull,
      role: model.role?.role?.lastOrNull,
      title: model.title?.title?.lastOrNull,
      titleInArabic: model.titleInArabic?.titleInArabic?.lastOrNull,
      workLocation: model.workLocation?.workLocation?.lastOrNull,
      drivingLicenseId: model.drivingLicenseId?.drivingLicenseId?.lastOrNull,
      carPlates: model.carPlates?.carPlates,
      academicHistory: AcademicHistoryEntity(
        gpa: model.academicHistory?.gpa?.lastOrNull,
        graduateFrom: model.academicHistory?.graduateFrom?.lastOrNull,
        university: model.academicHistory?.university?.lastOrNull,
        yearOfGraduation: model.academicHistory?.yearOfGraduation?.lastOrNull,
        graduateFromStatus:
        model.academicHistory?.graduateFromStatus?.lastOrNull,
        universityStatus: model.academicHistory?.universityStatus?.lastOrNull,
        yearOfGraduationStatus:
        model.academicHistory?.yearOfGraduationStatus?.lastOrNull,
        gpaStatus: model.academicHistory?.gpaStatus?.lastOrNull,
      ),
      bio: model.bio?.bio?.lastOrNull,
      photo: model.photo?.photos?.lastOrNull,
      skills: model.skills?.skills,
      hobbies: model.hobbies?.hobbies,
      status: model.status?.status?.lastOrNull,
      password: model.password,
      defaultPassword: model.defaultPassword,
      firstLogin: model.firstLogin,
      lastLogin: model.lastLogin,
      deactivationDate: model.deactivationDate,
      activationDate: model.activationDate,
    );
  }

  /// Converts List<NewEmployeeModel> to List<EmployeeEntity> (Legacy support)
  List<EmployeeEntityPro> fromModelList(List<NewEmployeeModel> models) {
    return models
        .map((model) => EmployeeEntityPro(
      id: model.id,
      firstName: model.firstName?.firstNames?.lastOrNull,
      middleName: model.middleName?.middleName?.lastOrNull,
      lastName: model.lastName?.lastNames?.lastOrNull,
      firstNameInArabic:
      model.firstNameInArabic?.firstNamesInArabic?.lastOrNull,
      middleNameInArabic:
      model.middleNameInArabic?.middleNameInArabic?.lastOrNull,
      lastNameInArabic:
      model.lastNameInArabic?.lastNamesInArabic?.lastOrNull,
      nationalId: model.nationalId?.nationalId?.lastOrNull,
      nationalIdExpirationDate: model.nationalIdExpirationDate
          ?.nationalIdExpirationDate?.lastOrNull,
      nationality: model.nationality?.nationality?.lastOrNull,
      passport: model.passport?.passport?.lastOrNull,
      passportExpirationDate: model
          .passportExpirationDate?.passportExpirationDate?.lastOrNull,
      email: model.email?.emails?.lastOrNull,
      mobilePhone: PhoneNumber(
        countryISOCode: '',
        number: model.mobilePhone?.phones?.lastOrNull ?? '',
        countryCode: model.mobilePhone?.countryCode?.lastOrNull ?? '',
        countryApp: model.mobilePhone?.countryApp?.lastOrNull,
      ),
      officePhone: model.officePhone?.phones?.lastOrNull,
      homePhone: model.homePhone?.phones?.lastOrNull,
      extension: model.extension?.extension?.lastOrNull,
      birthDay: model.birthDay?.birthDays?.lastOrNull,
      gender: model.gender?.gender?.lastOrNull,
      country: model.country?.country?.lastOrNull,
      province: model.province?.province?.lastOrNull,
      city: model.city?.city?.lastOrNull,
      postalCode: model.postalCode?.postalCode?.lastOrNull,
      street: model.street?.street?.lastOrNull,
      maritalStatus: model.maritalStatus?.maritalStatus?.lastOrNull,
      language: model.language?.languages?.lastOrNull,
      departmentId: model.departmentid?.departmentId?.lastOrNull,
      supervisor: model.supervisor?.supervisors?.lastOrNull,
      role: model.role?.role?.lastOrNull,
      title: model.title?.title?.lastOrNull,
      titleInArabic: model.titleInArabic?.titleInArabic?.lastOrNull,
      workLocation: model.workLocation?.workLocation?.lastOrNull,
      drivingLicenseId:
      model.drivingLicenseId?.drivingLicenseId?.lastOrNull,
      carPlates: model.carPlates?.carPlates,
      academicHistory: AcademicHistoryEntity(
        gpa: model.academicHistory?.gpa?.lastOrNull,
        graduateFrom: model.academicHistory?.graduateFrom?.lastOrNull,
        university: model.academicHistory?.university?.lastOrNull,
        yearOfGraduation:
        model.academicHistory?.yearOfGraduation?.lastOrNull,
        graduateFromStatus:
        model.academicHistory?.graduateFromStatus?.lastOrNull,
        universityStatus:
        model.academicHistory?.universityStatus?.lastOrNull,
        yearOfGraduationStatus:
        model.academicHistory?.yearOfGraduationStatus?.lastOrNull,
        gpaStatus: model.academicHistory?.gpaStatus?.lastOrNull,
      ),
      bio: model.bio?.bio?.lastOrNull,
      photo: model.photo?.photos?.lastOrNull,
      skills: model.skills?.skills,
      hobbies: model.hobbies?.hobbies,
      status: model.status?.status?.lastOrNull,
      password: model.password,
      defaultPassword: model.defaultPassword,
      firstLogin: model.firstLogin,
      lastLogin: model.lastLogin,
      deactivationDate: model.deactivationDate,
      activationDate: model.activationDate,
    ))
        .toList();
  }
}

class EmployeeEntityPro {
  final String? id;
  final String? firstName;
  final String? middleName;
  final String? lastName;
  final String? firstNameInArabic;
  final String? middleNameInArabic;
  final String? lastNameInArabic;
  final String? nationalId;
  final String? nationalIdExpirationDate;
  final String? nationality;
  final String? passport;
  final String? passportExpirationDate;
  final String? email;
  final PhoneNumber? mobilePhone;
  final String? officePhone;
  final String? homePhone;
  final String? extension;
  final String? birthDay;
  final String? gender;
  final String? country;
  final String? province;
  final String? city;
  final String? postalCode;
  final String? street;
  final String? maritalStatus;
  final String? language;
  final String? departmentId;
  final String? supervisor;
  final String? role;
  final String? title;
  final String? titleInArabic;
  final String? workLocation;
  final String? drivingLicenseId;
  final List<String?>? carPlates;
  final AcademicHistoryEntity? academicHistory;
  final String? bio;
  final String? photo;
  final List<String?>? skills;
  final List<String?>? hobbies;
  final String? status;
  final String? password;
  final String? defaultPassword;
  final String? firstLogin;
  final String? lastLogin;
  final String? deactivationDate;
  final String? activationDate;

  EmployeeEntityPro({
    this.id,
    this.firstName,
    this.middleName,
    this.lastName,
    this.firstNameInArabic,
    this.middleNameInArabic,
    this.lastNameInArabic,
    this.nationalId,
    this.nationalIdExpirationDate,
    this.nationality,
    this.passport,
    this.passportExpirationDate,
    this.email,
    this.mobilePhone,
    this.officePhone,
    this.homePhone,
    this.extension,
    this.birthDay,
    this.gender,
    this.country,
    this.province,
    this.city,
    this.postalCode,
    this.street,
    this.maritalStatus,
    this.language,
    this.departmentId,
    this.supervisor,
    this.role,
    this.title,
    this.titleInArabic,
    this.workLocation,
    this.drivingLicenseId,
    this.carPlates,
    this.academicHistory,
    this.bio,
    this.photo,
    this.skills,
    this.hobbies,
    this.status,
    this.password,
    this.defaultPassword,
    this.firstLogin,
    this.lastLogin,
    this.deactivationDate,
    this.activationDate,
  });

  /// Checks if the employee is a manager
  bool isManager() {
    return title?.toLowerCase().contains('manager') ?? false;
  }

  /// Gets full name in English
  String getFullName() {
    return '${firstName ?? ''} ${middleName ?? ''} ${lastName ?? ''}'.trim();
  }

  /// Gets full name in Arabic
  String getFullNameArabic() {
    return '${firstNameInArabic ?? ''} ${middleNameInArabic ?? ''} ${lastNameInArabic ?? ''}'.trim();
  }

  /// Checks if employee is active
  bool isActive() {
    return status?.toLowerCase() == 'active';
  }

  /// Checks if employee is deactivated
  bool isDeactivated() {
    return status?.toLowerCase() == 'deactivated';
  }
}
