import 'package:cloud_firestore/cloud_firestore.dart';

class RequestsModel {
  String? department;
  String? role;
  String? section;
  String? whatChanged;
  String? status;
  Timestamp? dateRequest;
  String? requestId;
  String? currentData;
  String? newData;
  String? image;

  String? firstName;
  // String? newFirstName;
  String? lastName;
  // String? newLastName;
  String? email;
  // String? newEmail;
  // String? phone;
  // String? newPhone;
  // String? address;
  // String? newAddress;
  // String? gender;
  // String? newGender;
  // String? birthDay;
  // String? newBirthDay;
  // String? nationality;
  // String? newNationality;
  // String? maritalStatus;
  // String? newMaritalStatus;

  // String? insuranceName;
  // String? newInsuranceName;
  // String? insurancePolice;
  // String? newInsurancePolice;
  // String? insurancePhone;
  // String? newInsurancePhone;
  // String? connectionName;
  // String? newConnectionName;
  // String? connectionRelation;
  // String? newConnectionRelation;
  // String? connectionPhone;
  // String? newConnectionPhone;

  // String? educationCertificate;
  // String? newEducationCertificate;
  // String? idPhoto;
  // String? newIdPhoto;
  // String? armyCertificate;
  // String? newArmyCertificate;
  // String? drivingLicense;
  // String? newDrivingLicense;
  // String? maritalCertificate;
  // String? newMaritalCertificate;
  // String? insuranceCard;
  // String? newInsuranceCard;

  // Constructor
  RequestsModel({
    this.department,
    this.role,
    this.section,
    this.whatChanged,
    this.status,
    this.dateRequest,
    this.requestId,
    this.currentData,
    this.newData,
    this.firstName,
    // this.newFirstName,
    this.lastName,
    // this.newLastName,
    this.email,
    this.image,
    // this.newEmail,
    // this.phone,
    // this.newPhone,
    // this.address,
    // this.newAddress,
    // this.gender,
    // this.newGender,
    // this.birthDay,
    // this.newBirthDay,
    // this.nationality,
    // this.newNationality,
    // this.maritalStatus,
    // this.newMaritalStatus,
    // this.insuranceName,
    // this.newInsuranceName,
    // this.insurancePolice,
    // this.newInsurancePolice,
    // this.insurancePhone,
    // this.newInsurancePhone,
    // this.connectionName,
    // this.newConnectionName,
    // this.connectionRelation,
    // this.newConnectionRelation,
    // this.connectionPhone,
    // this.newConnectionPhone,
    // this.educationCertificate,
    // this.newEducationCertificate,
    // this.idPhoto,
    // this.newIdPhoto,
    // this.armyCertificate,
    // this.newArmyCertificate,
    // this.drivingLicense,
    // this.newDrivingLicense,
    // this.maritalCertificate,
    // this.newMaritalCertificate,
    // this.insuranceCard,
    // this.newInsuranceCard,
  });
  factory RequestsModel.fromMap(Map data) {
    return RequestsModel(
      department: data['Department'],
      role: data['Role'],
      image: data['Image'],
      firstName: data['First_Name'],
      // newFirstName: data['New_First_Name'],
      lastName: data['Last_Name'],
      // newLastName: data['New_Last_Name'],
      email: data['Email'],
      // newEmail: data['New_Email'],
      section: data['Section'],

      // phone: data['Phone'],
      // newPhone: data['New_Phone'],
      // address: data['Address'],
      // newAddress: data['New_Address'],
      // gender: data['Gender'],
      // newGender: data['New_Gender'],
      whatChanged: data['What_Changed'],
      status: data['Status'],
      dateRequest: data['Date_Request'],
      requestId: data['Request_Id'],
      currentData: data['Current_Data'],
      newData: data['New_Data'],
      // birthDay: data['Birth_Day'],
      // newBirthDay: data['New_Birth_Day'],
      // nationality: data['Nationality'],
      // newNationality: data['New_Nationality'],
      // maritalStatus: data['Marital_Status'],
      // newMaritalStatus: data['New_Marital_Status'],
      // insuranceName: data['Insurance_Name'],
      // newInsuranceName: data['New_Insurance_Name'],
      // insurancePolice: data['Insurance_Police'],
      // newInsurancePolice: data['New_Insurance_Police'],
      // insurancePhone: data['Insurance_Phone'],
      // newInsurancePhone: data['New_Insurance_Phone'],
      // connectionName: data['Connection_Name'],
      // newConnectionName: data['New_Connection_Name'],
      // connectionRelation: data['Connection_Relation'],
      // newConnectionRelation: data['New_Connection_Relation'],
      // connectionPhone: data['Connection_Phone'],
      // newConnectionPhone: data['New_Connection_Phone'],
      // educationCertificate: data['Education_Certificate'],
      // newEducationCertificate: data['New_Education_Certificate'],
      // idPhoto: data['Id_Photo'],
      // newIdPhoto: data['New_Id_Photo'],
      // armyCertificate: data['Army_Certificate'],
      // newArmyCertificate: data['New_Army_Certificate'],
      // drivingLicense: data['Driving_License'],
      // newDrivingLicense: data['New_Driving_License'],
      // maritalCertificate: data['Marital_Certificate'],
      // newMaritalCertificate: data['New_Marital_Certificate'],
      // insuranceCard: data['Insurance_Card'],
      // newInsuranceCard: data['New_Insurance_Card'],
    );
  }

  Map<String, dynamic> toMap() => {
        'Request_Id': requestId,
        'Current_Data': currentData,
        'New_Data': newData,
        'Image': image,
        'Date_Request': dateRequest,
        'Section': section,
        'Status': status,
        'Department': department,
        'Role': role,
        'First_Name': firstName,
        // 'New_First_Name': newFirstName,
        'Last_Name': lastName,
        // 'New_Last_Name': newLastName,
        'Email': email,
        // 'New_Email': newEmail,
        // 'Phone': phone,
        // 'New_Phone': newPhone,
        // 'Address': address,
        // 'New_Address': newAddress,
        // 'Gender': gender,
        // 'New_Gender': newGender,
        'What_Changed': whatChanged,
        // 'Birth_Day': birthDay,
        // 'New_Birth_Day': newBirthDay,
        // 'Nationality': nationality,
        // 'New_Nationality': newNationality,
        // 'Insurance_Name': insuranceName,
        // 'Marital_Status': maritalStatus,
        // 'New_Marital_Status': newMaritalStatus,
        // 'Insurance_Police': insurancePolice,
        // 'New_Insurance_Name': newInsuranceName,
        // 'New_Insurance_Police': newInsurancePolice,
        // 'Insurance_Phone': insurancePhone,
        // 'New_Insurance_Phone': newInsurancePhone,
        // 'Connection_Name': connectionName,
        // 'New_Connection_Name': newConnectionName,
        // 'Connection_Relation': connectionRelation,
        // 'New_Connection_Relation': newConnectionRelation,
        // 'Connection_Phone': connectionPhone,
        // 'New_Connection_Phone': newConnectionPhone,
        // 'Education_Certificate': educationCertificate,
        // 'New_Education_Certificate': newEducationCertificate,
        // 'Id_Photo': idPhoto,
        // 'New_Id_Photo': newIdPhoto,
        // 'Army_Certificate': armyCertificate,
        // 'New_Army_Certificate': newArmyCertificate,
        // 'Driving_License': drivingLicense,
        // 'New_Driving_License': newDrivingLicense,
        // 'Marital_Certificate': maritalCertificate,
        // 'New_Marital_Certificate': newMaritalCertificate,
        // 'Insurance_Card': insuranceCard,
        // 'New_Insurance_Card': newInsuranceCard,
      };
}
