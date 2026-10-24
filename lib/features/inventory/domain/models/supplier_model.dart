class SupplierModel {
  // Basic Supplier Info
  final String supplierID;
  final String imageSupplier;
  final String supplierName;
  final String businessType;
  final String taxNumber;
  final String businessRegistrationNumber;
  final String supplierRank;
  final String contactBy;
  final String dateAdded;

  // Contact Details
  final String firstName;
  final String middleName;
  final String lastName;
  final String title;
  final String phoneNumber;
  final String faxNumber;
  final String email;
  final String preferredLanguage;

  // Bank Transfer Details
  final String beneficiaryName;
  final String beneficiaryBankName;
  final String bankSWIFTBICCode;
  final String beneficiaryBankAccountNumberIBAN;
  final String bankAddress;

  // Address Details
  final String country;
  final String stateOrProvince;
  final String city;
  final String postalCode;
  final String streetName;
  final String warehouseAddress;

  // Alternative Address Details
  final String altCountry;
  final String altStateOrProvince;
  final String altCity;
  final String altPostalCode;
  final String altStreetName;
  final String altWarehouseAddress;

  // Warehouse Details
  final String enable;
  final String warehouseCountry;
  final String warehouseStateOrProvince;
  final String warehouseCity;
  final String warehousePostalCode;
  final String warehouseStreetName;

  // Contract Details
  final String contractStartDate;
  final String contractEndDate;
  final String contractStatus;

  // Document Info - Tax Certificate
  final String taxCertificateFileName;
  final String taxCertificateUploadStatus;
  final String taxCertificateFileUrl;

  // Document Info - Registration Document
  final String registrationDocumentFileName;
  final String registrationDocumentUploadStatus;
  final String registrationDocumentFileUrl;

  // Document Info - Attachments
  final String attachmentsFileName;
  final String attachmentsUploadStatus;
  final String attachmentsFileUrl;

  final String contractDocumentFileName;
  final String contractDocumentUploadStatus;
  final String contractDocumentFileUrl;

  // Metadata
  final String createdAt;
  final String addedOn;
  final String createdBy;
  final bool isActive;
  final bool automaticOrders;

  SupplierModel({
    required this.supplierID,
    required this.imageSupplier,
    required this.supplierName,
    required this.businessType,
    required this.taxNumber,
    required this.businessRegistrationNumber,
    required this.supplierRank,
    required this.contactBy,
    required this.dateAdded,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.title,
    required this.phoneNumber,
    required this.faxNumber,
    required this.email,
    required this.preferredLanguage,
    required this.beneficiaryName,
    required this.beneficiaryBankName,
    required this.bankSWIFTBICCode,
    required this.beneficiaryBankAccountNumberIBAN,
    required this.bankAddress,
    required this.country,
    required this.stateOrProvince,
    required this.city,
    required this.postalCode,
    required this.streetName,
    required this.warehouseAddress,
    required this.altCountry,
    required this.altStateOrProvince,
    required this.altCity,
    required this.altPostalCode,
    required this.altStreetName,
    required this.enable,
    required this.altWarehouseAddress,
    required this.warehouseCountry,
    required this.warehouseStateOrProvince,
    required this.warehouseCity,
    required this.warehousePostalCode,
    required this.warehouseStreetName,
    required this.contractStartDate,
    required this.contractEndDate,
    required this.contractStatus,
    required this.taxCertificateFileName,
    required this.taxCertificateUploadStatus,
    required this.taxCertificateFileUrl,
    required this.registrationDocumentFileName,
    required this.registrationDocumentUploadStatus,
    required this.registrationDocumentFileUrl,
    required this.attachmentsFileName,
    required this.attachmentsUploadStatus,
    required this.attachmentsFileUrl,
    required this.createdAt,
    required this.addedOn,
    required this.createdBy,
    required this.isActive,
    required this.automaticOrders,
    required this.contractDocumentFileName,
    required this.contractDocumentUploadStatus,
    required this.contractDocumentFileUrl,
  });

  factory SupplierModel.fromJson(Map<String, dynamic> json) {
    return SupplierModel(
      supplierID: json['supplierID'] ?? '',
      imageSupplier: json['imageSupplier'] ?? '',
      supplierName: json['supplierName'] ?? '',
      businessType: json['businessType'] ?? '',
      taxNumber: json['taxNumber'] ?? '',
      businessRegistrationNumber: json['businessRegistrationNumber'] ?? '',
      supplierRank: json['supplierRank'] ?? '',
      contactBy: json['contactBy'] ?? '',
      dateAdded: json['dateAdded'] ?? '',
      firstName: json['firstName'] ?? '',
      middleName: json['middleName'] ?? '',
      lastName: json['lastName'] ?? '',
      title: json['title'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      faxNumber: json['faxNumber'] ?? '',
      email: json['email'] ?? '',
      preferredLanguage: json['preferredLanguage'] ?? '',
      beneficiaryName: json['beneficiaryName'] ?? '',
      beneficiaryBankName: json['beneficiaryBankName'] ?? '',
      bankSWIFTBICCode: json['bankSWIFTBICCode'] ?? '',
      beneficiaryBankAccountNumberIBAN:
          json['beneficiaryBankAccountNumberIBAN'] ?? '',
      bankAddress: json['bankAddress'] ?? '',
      country: json['country'] ?? '',
      stateOrProvince: json['stateOrProvince'] ?? '',
      city: json['city'] ?? '',
      postalCode: json['postalCode'] ?? '',
      streetName: json['streetName'] ?? '',
      warehouseAddress: json['warehouseAddress'] ?? '',
      altCountry: json['altCountry'] ?? '',
      altStateOrProvince: json['altStateOrProvince'] ?? '',
      altCity: json['altCity'] ?? '',
      altPostalCode: json['altPostalCode'] ?? '',
      altStreetName: json['altStreetName'] ?? '',
      altWarehouseAddress: json['altWarehouseAddress'] ?? '',
      warehouseCountry: json['warehouseCountry'] ?? '',
      warehouseStateOrProvince: json['warehouseStateOrProvince'] ?? '',
      enable: json['enable'] ?? '',
      warehouseCity: json['warehouseCity'] ?? '',
      warehousePostalCode: json['warehousePostalCode'] ?? '',
      warehouseStreetName: json['warehouseStreetName'] ?? '',
      contractStartDate: json['contractStartDate'] ?? '',
      contractEndDate: json['contractEndDate'] ?? '',
      contractStatus: json['contractStatus'] ?? 'active',
      taxCertificateFileName: json['taxCertificateFileName'] ?? '',
      taxCertificateUploadStatus:
          json['taxCertificateUploadStatus'] ?? 'pending',
      taxCertificateFileUrl: json['taxCertificateFileUrl'] ?? '',
      registrationDocumentFileName: json['registrationDocumentFileName'] ?? '',
      registrationDocumentUploadStatus:
          json['registrationDocumentUploadStatus'] ?? 'pending',
      registrationDocumentFileUrl: json['registrationDocumentFileUrl'] ?? '',
      attachmentsFileName: json['attachmentsFileName'] ?? '',
      attachmentsUploadStatus: json['attachmentsUploadStatus'] ?? 'pending',
      attachmentsFileUrl: json['attachmentsFileUrl'] ?? '',
      createdAt: json['createdAt'] ?? '',
      addedOn: json['addedOn'] ?? '',
      createdBy: json['createdBy'] ?? '',
      isActive: json['isActive'] ?? true,
      automaticOrders: json['automaticOrders'] ?? false,
      contractDocumentFileName: json['contractDocumentFileName'] ?? '',
      contractDocumentUploadStatus:
          json['contractDocumentUploadStatus'] ?? 'pending',
      contractDocumentFileUrl: json['contractDocumentFileUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'supplierID': supplierID,
      'imageSupplier': imageSupplier,
      'supplierName': supplierName,
      'businessType': businessType,
      'taxNumber': taxNumber,
      'businessRegistrationNumber': businessRegistrationNumber,
      'supplierRank': supplierRank,
      'contactBy': contactBy,
      'dateAdded': dateAdded,
      'firstName': firstName,
      'middleName': middleName,
      'lastName': lastName,
      'title': title,
      'phoneNumber': phoneNumber,
      'faxNumber': faxNumber,
      'email': email,
      'preferredLanguage': preferredLanguage,
      'beneficiaryName': beneficiaryName,
      'beneficiaryBankName': beneficiaryBankName,
      'bankSWIFTBICCode': bankSWIFTBICCode,
      'beneficiaryBankAccountNumberIBAN': beneficiaryBankAccountNumberIBAN,
      'bankAddress': bankAddress,
      'country': country,
      'stateOrProvince': stateOrProvince,
      'city': city,
      'postalCode': postalCode,
      'streetName': streetName,
      'warehouseAddress': warehouseAddress,
      'altCountry': altCountry,
      'altStateOrProvince': altStateOrProvince,
      'altCity': altCity,
      'altPostalCode': altPostalCode,
      'altStreetName': altStreetName,
      'enable': enable,
      'altWarehouseAddress': altWarehouseAddress,
      'warehouseCountry': warehouseCountry,
      'warehouseStateOrProvince': warehouseStateOrProvince,
      'warehouseCity': warehouseCity,
      'warehousePostalCode': warehousePostalCode,
      'warehouseStreetName': warehouseStreetName,
      'contractStartDate': contractStartDate,
      'contractEndDate': contractEndDate,
      'contractStatus': contractStatus,
      'taxCertificateFileName': taxCertificateFileName,
      'taxCertificateUploadStatus': taxCertificateUploadStatus,
      'taxCertificateFileUrl': taxCertificateFileUrl,
      'registrationDocumentFileName': registrationDocumentFileName,
      'registrationDocumentUploadStatus': registrationDocumentUploadStatus,
      'registrationDocumentFileUrl': registrationDocumentFileUrl,
      'attachmentsFileName': attachmentsFileName,
      'attachmentsUploadStatus': attachmentsUploadStatus,
      'attachmentsFileUrl': attachmentsFileUrl,
      'createdAt': createdAt,
      'addedOn': addedOn,
      'createdBy': createdBy,
      'isActive': isActive,
      'automaticOrders': automaticOrders,
      'contractDocumentFileName': contractDocumentFileName,
      'contractDocumentUploadStatus': contractDocumentUploadStatus,
      'contractDocumentFileUrl': contractDocumentFileUrl,
    };
  }
}
