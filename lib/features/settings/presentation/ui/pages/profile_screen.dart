// Shared mutable global state for the settings personal-info / additional-info
// update widgets. These top-level globals previously lived in the (now removed)
// legacy profile screen and are still referenced by the settings update widgets.
import 'package:demo_app/features/settings/core_widgets/main_widget/phone_number.dart';

// Contact info
String? email2;
PhoneNumber? phone2;

// Additional info (uploaded document URLs)
String? educationCertificate2;
String? idPhoto2;
String? armyCertificate2;
String? drivingLicense2;
String? maritalCertificate2;
String? insuranceCard2;

// Personal info
String? firstName2;
String? middleName2;
String? lastName2;
String? address2;
String? country2;
String? city2;
String? province2;
String? birthDate2;
String? selectedGender;
String? selectedNationality;
String? selectedMaritalStatus;

// Health insurance
String? insuranceName2;
String? insurancePolice2;
PhoneNumber? insurancePhone2;

// Emergency contact
String? connectionName2;
String? connectionMiddleName2;
String? connectionLastName2;
String? connecntionRelation2;
PhoneNumber? connecntionPhone2;
String? connecntionEmail2;
String? connecntionCountry2;
String? connecntionProvince2;
String? connecntionCity2;
String? connecntionAddress2;
String? connecntionPostalCode2;

final List<String> contact = [];
