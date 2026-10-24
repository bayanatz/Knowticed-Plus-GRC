import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/inventory/helpers/inventory_paths.dart';

// supplier_model.dart

class SupplierModel {
  final String supplierID;
  final SupplierDetails supplierDetails;
  final ContactDetails contactDetails;
  final BankTransferDetails bankTransferDetails;
  final AddressDetails addressDetails;
  final AddressDetails alternativeAddressDetails;
  final WarehouseDetails warehouseDetails;
  final ContractDetails contractDetails;
  final Metadata metadata;

  SupplierModel({
    required this.supplierID,
    required this.supplierDetails,
    required this.contactDetails,
    required this.bankTransferDetails,
    required this.addressDetails,
    required this.alternativeAddressDetails,
    required this.warehouseDetails,
    required this.contractDetails,
    required this.metadata,
  });

  factory SupplierModel.fromJson(Map<String, dynamic> json) {
    return SupplierModel(
      supplierID: json['supplierID'] ?? '',
      supplierDetails: SupplierDetails.fromJson(json['supplierDetails'] ?? {}),
      contactDetails: ContactDetails.fromJson(json['contactDetails'] ?? {}),
      bankTransferDetails:
          BankTransferDetails.fromJson(json['bankTransferDetails'] ?? {}),
      addressDetails: AddressDetails.fromJson(json['addressDetails'] ?? {}),
      alternativeAddressDetails:
          AddressDetails.fromJson(json['alternativeAddressDetails'] ?? {}),
      warehouseDetails:
          WarehouseDetails.fromJson(json['warehouseDetails'] ?? {}),
      contractDetails: ContractDetails.fromJson(json['contractDetails'] ?? {}),
      metadata: Metadata.fromJson(json['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'supplierID': supplierID,
      'supplierDetails': supplierDetails.toJson(),
      'contactDetails': contactDetails.toJson(),
      'bankTransferDetails': bankTransferDetails.toJson(),
      'addressDetails': addressDetails.toJson(),
      'alternativeAddressDetails': alternativeAddressDetails.toJson(),
      'warehouseDetails': warehouseDetails.toJson(),
      'contractDetails': contractDetails.toJson(),
      'metadata': metadata.toJson(),
    };
  }
}

class SupplierDetails {
  final String supplierID;
  final String supplierName;
  final String businessType;
  final String taxNumber;
  final String businessRegistrationNumber;
  final String supplierRank;
  final String contactBy;
  final String dateAdded;

  SupplierDetails({
    required this.supplierID,
    required this.supplierName,
    required this.businessType,
    required this.taxNumber,
    required this.businessRegistrationNumber,
    required this.supplierRank,
    required this.contactBy,
    required this.dateAdded,
  });

  factory SupplierDetails.fromJson(Map<String, dynamic> json) {
    return SupplierDetails(
      supplierID: json['supplierID'] ?? '',
      supplierName: json['supplierName'] ?? '',
      businessType: json['businessType'] ?? '',
      taxNumber: json['taxNumber'] ?? '',
      businessRegistrationNumber: json['businessRegistrationNumber'] ?? '',
      supplierRank: json['supplierRank'] ?? '',
      contactBy: json['contactBy'] ?? '',
      dateAdded: json['dateAdded'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'supplierID': supplierID,
      'supplierName': supplierName,
      'businessType': businessType,
      'taxNumber': taxNumber,
      'businessRegistrationNumber': businessRegistrationNumber,
      'supplierRank': supplierRank,
      'contactBy': contactBy,
      'dateAdded': dateAdded,
    };
  }
}

class ContactDetails {
  final String firstName;
  final String middleName;
  final String lastName;
  final String title;
  final String phoneNumber;
  final String faxNumber;
  final String email;
  final String preferredLanguage;

  ContactDetails({
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.title,
    required this.phoneNumber,
    required this.faxNumber,
    required this.email,
    required this.preferredLanguage,
  });

  factory ContactDetails.fromJson(Map<String, dynamic> json) {
    return ContactDetails(
      firstName: json['firstName'] ?? '',
      middleName: json['middleName'] ?? '',
      lastName: json['lastName'] ?? '',
      title: json['title'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      faxNumber: json['faxNumber'] ?? '',
      email: json['email'] ?? '',
      preferredLanguage: json['preferredLanguage'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'middleName': middleName,
      'lastName': lastName,
      'title': title,
      'phoneNumber': phoneNumber,
      'faxNumber': faxNumber,
      'email': email,
      'preferredLanguage': preferredLanguage,
    };
  }
}

class BankTransferDetails {
  final String beneficiaryName;
  final String beneficiaryBankName;
  final String bankSWIFTBICCode;
  final String beneficiaryBankAccountNumberIBAN;
  final String bankAddress;

  BankTransferDetails({
    required this.beneficiaryName,
    required this.beneficiaryBankName,
    required this.bankSWIFTBICCode,
    required this.beneficiaryBankAccountNumberIBAN,
    required this.bankAddress,
  });

  factory BankTransferDetails.fromJson(Map<String, dynamic> json) {
    return BankTransferDetails(
      beneficiaryName: json['beneficiaryName'] ?? '',
      beneficiaryBankName: json['beneficiaryBankName'] ?? '',
      bankSWIFTBICCode: json['bankSWIFTBICCode'] ?? '',
      beneficiaryBankAccountNumberIBAN:
          json['beneficiaryBankAccountNumberIBAN'] ?? '',
      bankAddress: json['bankAddress'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'beneficiaryName': beneficiaryName,
      'beneficiaryBankName': beneficiaryBankName,
      'bankSWIFTBICCode': bankSWIFTBICCode,
      'beneficiaryBankAccountNumberIBAN': beneficiaryBankAccountNumberIBAN,
      'bankAddress': bankAddress,
    };
  }
}

class AddressDetails {
  final String country;
  final String stateOrProvince;
  final String city;
  final String postalCode;
  final String streetName;
  final String warehouseAddress;

  AddressDetails({
    required this.country,
    required this.stateOrProvince,
    required this.city,
    required this.postalCode,
    required this.streetName,
    required this.warehouseAddress,
  });

  factory AddressDetails.fromJson(Map<String, dynamic> json) {
    return AddressDetails(
      country: json['country'] ?? '',
      stateOrProvince: json['stateOrProvince'] ?? '',
      city: json['city'] ?? '',
      postalCode: json['postalCode'] ?? '',
      streetName: json['streetName'] ?? '',
      warehouseAddress: json['warehouseAddress'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'country': country,
      'stateOrProvince': stateOrProvince,
      'city': city,
      'postalCode': postalCode,
      'streetName': streetName,
      'warehouseAddress': warehouseAddress,
    };
  }
}

class WarehouseDetails {
  final String country;
  final String stateOrProvince;
  final String city;
  final String postalCode;
  final String streetName;

  WarehouseDetails({
    required this.country,
    required this.stateOrProvince,
    required this.city,
    required this.postalCode,
    required this.streetName,
  });

  factory WarehouseDetails.fromJson(Map<String, dynamic> json) {
    return WarehouseDetails(
      country: json['country'] ?? '',
      stateOrProvince: json['stateOrProvince'] ?? '',
      city: json['city'] ?? '',
      postalCode: json['postalCode'] ?? '',
      streetName: json['streetName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'country': country,
      'stateOrProvince': stateOrProvince,
      'city': city,
      'postalCode': postalCode,
      'streetName': streetName,
    };
  }
}

class ContractDetails {
  final String contractStartDate;
  final String contractEndDate;
  final String status;
  final DocumentInfo taxCertificate;
  final DocumentInfo registrationDocument;
  final DocumentInfo attachments;

  ContractDetails({
    required this.contractStartDate,
    required this.contractEndDate,
    required this.status,
    required this.taxCertificate,
    required this.registrationDocument,
    required this.attachments,
  });

  factory ContractDetails.fromJson(Map<String, dynamic> json) {
    return ContractDetails(
      contractStartDate: json['contractStartDate'] ?? '',
      contractEndDate: json['contractEndDate'] ?? '',
      status: json['status'] ?? '',
      taxCertificate: DocumentInfo.fromJson(json['taxCertificate'] ?? {}),
      registrationDocument:
          DocumentInfo.fromJson(json['registrationDocument'] ?? {}),
      attachments: DocumentInfo.fromJson(json['attachments'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'contractStartDate': contractStartDate,
      'contractEndDate': contractEndDate,
      'status': status,
      'taxCertificate': taxCertificate.toJson(),
      'registrationDocument': registrationDocument.toJson(),
      'attachments': attachments.toJson(),
    };
  }
}

class DocumentInfo {
  final String fileName;
  final String uploadStatus;
  final String fileUrl;

  DocumentInfo({
    required this.fileName,
    required this.uploadStatus,
    required this.fileUrl,
  });

  factory DocumentInfo.fromJson(Map<String, dynamic> json) {
    return DocumentInfo(
      fileName: json['fileName'] ?? '',
      uploadStatus: json['uploadStatus'] ?? '',
      fileUrl: json['fileUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fileName': fileName,
      'uploadStatus': uploadStatus,
      'fileUrl': fileUrl,
    };
  }
}

class Metadata {
  final String createdAt;
  final String updatedAt;
  final String createdBy;
  final bool isActive;
  final bool automaticOrders;

  Metadata({
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    required this.isActive,
    required this.automaticOrders,
  });

  factory Metadata.fromJson(Map<String, dynamic> json) {
    return Metadata(
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      createdBy: json['createdBy'] ?? '',
      isActive: json['isActive'] ?? true,
      automaticOrders: json['automaticOrders'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'createdBy': createdBy,
      'isActive': isActive,
      'automaticOrders': automaticOrders,
    };
  }
}

// supplier_service.dart

class SupplierService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String basePath =
      'Demo/${InventoryPaths.companyId}/supplier/user/${InventoryPaths.userEmail}';

  // Upload a single supplier
  Future<bool> uploadSupplier(SupplierModel supplier) async {
    try {
      await _firestore
          .collection(basePath)
          .doc(supplier.supplierID)
          .set(supplier.toJson());

      debugPrint('Supplier ${supplier.supplierID} uploaded successfully');
      return true;
    } catch (e) {
      debugPrint('Error uploading supplier ${supplier.supplierID}: $e');
      return false;
    }
  }

  // Upload multiple suppliers
  Future<bool> uploadMultipleSuppliers(List<SupplierModel> suppliers) async {
    try {
      debugPrint('Starting upload of ${suppliers.length} suppliers...');
      debugPrint('Upload path: $basePath');

      if (suppliers.isEmpty) {
        debugPrint('No suppliers to upload');
        return false;
      }

      WriteBatch batch = _firestore.batch();

      for (SupplierModel supplier in suppliers) {
        DocumentReference docRef =
            _firestore.collection(basePath).doc(supplier.supplierID);

        debugPrint(
            'Adding ${supplier.supplierID} to batch: ${supplier.supplierDetails.supplierName}');
        batch.set(docRef, supplier.toJson());
      }

      debugPrint('Committing batch...');
      await batch.commit();
      debugPrint(
          'Batch committed successfully! ${suppliers.length} suppliers uploaded');
      return true;
    } catch (e) {
      debugPrint('Error uploading suppliers: $e');
      debugPrint('Error type: ${e.runtimeType}');
      return false;
    }
  }

  // Get a single supplier
  Future<SupplierModel?> getSupplier(String supplierID) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection(basePath).doc(supplierID).get();

      if (doc.exists) {
        return SupplierModel.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting supplier $supplierID: $e');
      return null;
    }
  }

  // Get all suppliers
  Future<List<SupplierModel>> getAllSuppliers() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection(basePath).get();

      return querySnapshot.docs
          .map((doc) =>
              SupplierModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error getting all suppliers: $e');
      return [];
    }
  }

  // Delete a supplier
  Future<bool> deleteSupplier(String supplierID) async {
    try {
      await _firestore.collection(basePath).doc(supplierID).delete();

      debugPrint('Supplier $supplierID deleted successfully');
      return true;
    } catch (e) {
      debugPrint('Error deleting supplier $supplierID: $e');
      return false;
    }
  }

  // Update a supplier
  Future<bool> updateSupplier(SupplierModel supplier) async {
    try {
      await _firestore
          .collection(basePath)
          .doc(supplier.supplierID)
          .update(supplier.toJson());

      debugPrint('Supplier ${supplier.supplierID} updated successfully');
      return true;
    } catch (e) {
      debugPrint('Error updating supplier ${supplier.supplierID}: $e');
      return false;
    }
  }
}

// supplier_upload_page.dart

class SupplierUploadPage extends StatefulWidget {
  const SupplierUploadPage({super.key});

  @override
  State<SupplierUploadPage> createState() => _SupplierUploadPageState();
}

class _SupplierUploadPageState extends State<SupplierUploadPage> {
  final SupplierService _supplierService = SupplierService();
  bool _isUploading = false;

  // Sample data - replace with your actual supplier data
  final List<Map<String, dynamic>> _supplierData = [
    {
      "supplierID": "SUP001",
      "supplierDetails": {
        "supplierID": "SUP001",
        "supplierName": "Cairo Electronics Trading Co.",
        "businessType": "Electronics Distributor",
        "taxNumber": "100-245-789",
        "businessRegistrationNumber": "CR-2019-4567",
        "supplierRank": "Gold",
        "contactBy": "Phone/Email",
        "dateAdded": "2024-01-15"
      },
      "contactDetails": {
        "firstName": "Ahmed",
        "middleName": "Mohamed",
        "lastName": "Hassan",
        "title": "Sales Manager",
        "phoneNumber": "+20-2-23456789",
        "faxNumber": "+20-2-23456790",
        "email": "ahmed.hassan@cairoelectronics.com",
        "preferredLanguage": "Arabic"
      },
      "bankTransferDetails": {
        "beneficiaryName": "Cairo Electronics Trading Co.",
        "beneficiaryBankName": "National Bank of Egypt",
        "bankSWIFTBICCode": "NBEGEGCX",
        "beneficiaryBankAccountNumberIBAN": "EG380003000012345678901234",
        "bankAddress": "Tahrir Square Branch, Cairo, Egypt"
      },
      "addressDetails": {
        "country": "Egypt",
        "stateOrProvince": "Cairo Governorate",
        "city": "Cairo",
        "postalCode": "11511",
        "streetName": "15 Tahrir Square",
        "warehouseAddress": "Industrial Zone A, 6th October City"
      },
      "alternativeAddressDetails": {
        "country": "Egypt",
        "stateOrProvince": "Giza Governorate",
        "city": "6th October City",
        "postalCode": "12566",
        "streetName": "Industrial Zone A, Block 12",
        "warehouseAddress": "Same as alternative address"
      },
      "warehouseDetails": {
        "country": "Egypt",
        "stateOrProvince": "Giza Governorate",
        "city": "6th October City",
        "postalCode": "12566",
        "streetName": "Industrial Zone A, Block 12"
      },
      "contractDetails": {
        "contractStartDate": "2024-01-01",
        "contractEndDate": "2024-12-31",
        "status": "Active",
        "taxCertificate": {
          "fileName": "tax_certificate_SUP001.pdf",
          "uploadStatus": "Uploaded",
          "fileUrl": "https://storage.firebase.com/tax_cert_SUP001.pdf"
        },
        "registrationDocument": {
          "fileName": "registration_SUP001.pdf",
          "uploadStatus": "Uploaded",
          "fileUrl": "https://storage.firebase.com/registration_SUP001.pdf"
        },
        "attachments": {
          "fileName": "product_catalog_SUP001.pdf",
          "uploadStatus": "Uploaded",
          "fileUrl": "https://storage.firebase.com/catalog_SUP001.pdf"
        }
      },
      "metadata": {
        "createdAt": "2024-01-15T10:30:00Z",
        "updatedAt": "2024-08-20T14:25:00Z",
        "createdBy": "admin@company.com",
        "isActive": true,
        "automaticOrders": true
      }
    },
    {
      "supplierID": "SUP002",
      "supplierDetails": {
        "supplierID": "SUP002",
        "supplierName": "Alexandria Textiles Industries",
        "businessType": "Textile Manufacturer",
        "taxNumber": "200-567-123",
        "businessRegistrationNumber": "CR-2020-7890",
        "supplierRank": "Silver",
        "contactBy": "Email",
        "dateAdded": "2024-02-20"
      },
      "contactDetails": {
        "firstName": "Fatima",
        "middleName": "Ali",
        "lastName": "Mahmoud",
        "title": "Export Manager",
        "phoneNumber": "+20-3-45678901",
        "faxNumber": "+20-3-45678902",
        "email": "fatima.mahmoud@alextextiles.com",
        "preferredLanguage": "English"
      },
      "bankTransferDetails": {
        "beneficiaryName": "Alexandria Textiles Industries",
        "beneficiaryBankName": "Commercial International Bank",
        "bankSWIFTBICCode": "CIBEEGCX",
        "beneficiaryBankAccountNumberIBAN": "EG210037000023456789012345",
        "bankAddress": "Corniche Branch, Alexandria, Egypt"
      },
      "addressDetails": {
        "country": "Egypt",
        "stateOrProvince": "Alexandria Governorate",
        "city": "Alexandria",
        "postalCode": "21511",
        "streetName": "45 Corniche Road",
        "warehouseAddress": "Borg El Arab Industrial Zone"
      },
      "alternativeAddressDetails": {
        "country": "Egypt",
        "stateOrProvince": "Alexandria Governorate",
        "city": "Borg El Arab",
        "postalCode": "23511",
        "streetName": "Industrial Zone, Block C",
        "warehouseAddress": "Same as alternative address"
      },
      "warehouseDetails": {
        "country": "Egypt",
        "stateOrProvince": "Alexandria Governorate",
        "city": "Borg El Arab",
        "postalCode": "23511",
        "streetName": "Industrial Zone, Block C"
      },
      "contractDetails": {
        "contractStartDate": "2024-02-01",
        "contractEndDate": "2025-01-31",
        "status": "Active",
        "taxCertificate": {
          "fileName": "tax_certificate_SUP002.pdf",
          "uploadStatus": "Uploaded",
          "fileUrl": "https://storage.firebase.com/tax_cert_SUP002.pdf"
        },
        "registrationDocument": {
          "fileName": "registration_SUP002.pdf",
          "uploadStatus": "Uploaded",
          "fileUrl": "https://storage.firebase.com/registration_SUP002.pdf"
        },
        "attachments": {
          "fileName": "fabric_samples_SUP002.pdf",
          "uploadStatus": "Uploaded",
          "fileUrl": "https://storage.firebase.com/samples_SUP002.pdf"
        }
      },
      "metadata": {
        "createdAt": "2024-02-20T09:15:00Z",
        "updatedAt": "2024-08-18T16:40:00Z",
        "createdBy": "procurement@company.com",
        "isActive": true,
        "automaticOrders": false
      }
    },
    {
      "supplierID": "SUP003",
      "supplierDetails": {
        "supplierID": "SUP003",
        "supplierName": "Delta Food Processing LLC",
        "businessType": "Food Manufacturer",
        "taxNumber": "300-789-456",
        "businessRegistrationNumber": "CR-2021-1234",
        "supplierRank": "Platinum",
        "contactBy": "Phone",
        "dateAdded": "2024-03-10"
      },
      "contactDetails": {
        "firstName": "Omar",
        "middleName": "Khaled",
        "lastName": "Ibrahim",
        "title": "Business Development Director",
        "phoneNumber": "+20-50-12345678",
        "faxNumber": "+20-50-12345679",
        "email": "omar.ibrahim@deltafood.com",
        "preferredLanguage": "Arabic"
      },
      "bankTransferDetails": {
        "beneficiaryName": "Delta Food Processing LLC",
        "beneficiaryBankName": "Banque Misr",
        "bankSWIFTBICCode": "BMISEGCX",
        "beneficiaryBankAccountNumberIBAN": "EG660020000034567890123456",
        "bankAddress": "Mansoura Main Branch, Dakahlia, Egypt"
      },
      "addressDetails": {
        "country": "Egypt",
        "stateOrProvince": "Dakahlia Governorate",
        "city": "Mansoura",
        "postalCode": "35511",
        "streetName": "78 El Galaa Street",
        "warehouseAddress": "Mansoura Industrial Zone"
      },
      "alternativeAddressDetails": {
        "country": "Egypt",
        "stateOrProvince": "Dakahlia Governorate",
        "city": "Mansoura",
        "postalCode": "35566",
        "streetName": "Industrial Zone, Sector 5",
        "warehouseAddress": "Same as alternative address"
      },
      "warehouseDetails": {
        "country": "Egypt",
        "stateOrProvince": "Dakahlia Governorate",
        "city": "Mansoura",
        "postalCode": "35566",
        "streetName": "Industrial Zone, Sector 5"
      },
      "contractDetails": {
        "contractStartDate": "2024-03-01",
        "contractEndDate": "2025-02-28",
        "status": "Active",
        "taxCertificate": {
          "fileName": "tax_certificate_SUP003.pdf",
          "uploadStatus": "Uploaded",
          "fileUrl": "https://storage.firebase.com/tax_cert_SUP003.pdf"
        },
        "registrationDocument": {
          "fileName": "registration_SUP003.pdf",
          "uploadStatus": "Uploaded",
          "fileUrl": "https://storage.firebase.com/registration_SUP003.pdf"
        },
        "attachments": {
          "fileName": "quality_certificates_SUP003.pdf",
          "uploadStatus": "Uploaded",
          "fileUrl": "https://storage.firebase.com/quality_SUP003.pdf"
        }
      },
      "metadata": {
        "createdAt": "2024-03-10T11:20:00Z",
        "updatedAt": "2024-08-25T13:15:00Z",
        "createdBy": "admin@company.com",
        "isActive": true,
        "automaticOrders": true
      }
    },
    {
      "supplierID": "SUP004",
      "supplierDetails": {
        "supplierID": "SUP004",
        "supplierName": "Red Sea Pharmaceuticals",
        "businessType": "Pharmaceutical Distributor",
        "taxNumber": "400-321-654",
        "businessRegistrationNumber": "CR-2022-5678",
        "supplierRank": "Gold",
        "contactBy": "Email/Phone",
        "dateAdded": "2024-04-05"
      },
      "contactDetails": {
        "firstName": "Mona",
        "middleName": "Said",
        "lastName": "Abdel Rahman",
        "title": "Regional Sales Manager",
        "phoneNumber": "+20-65-34567890",
        "faxNumber": "+20-65-34567891",
        "email": "mona.abdel@redseapharma.com",
        "preferredLanguage": "English"
      },
      "bankTransferDetails": {
        "beneficiaryName": "Red Sea Pharmaceuticals",
        "beneficiaryBankName": "Arab African International Bank",
        "bankSWIFTBICCode": "ARAIEGCX",
        "beneficiaryBankAccountNumberIBAN": "EG890076000045678901234567",
        "bankAddress": "Hurghada Branch, Red Sea, Egypt"
      },
      "addressDetails": {
        "country": "Egypt",
        "stateOrProvince": "Red Sea Governorate",
        "city": "Hurghada",
        "postalCode": "84511",
        "streetName": "23 Sheraton Road",
        "warehouseAddress": "Medical City Complex, Hurghada"
      },
      "alternativeAddressDetails": {
        "country": "Egypt",
        "stateOrProvince": "Red Sea Governorate",
        "city": "Hurghada",
        "postalCode": "84522",
        "streetName": "Medical City Complex, Building 7",
        "warehouseAddress": "Same as alternative address"
      },
      "warehouseDetails": {
        "country": "Egypt",
        "stateOrProvince": "Red Sea Governorate",
        "city": "Hurghada",
        "postalCode": "84522",
        "streetName": "Medical City Complex, Building 7"
      },
      "contractDetails": {
        "contractStartDate": "2024-04-01",
        "contractEndDate": "2025-03-31",
        "status": "Active",
        "taxCertificate": {
          "fileName": "tax_certificate_SUP004.pdf",
          "uploadStatus": "Uploaded",
          "fileUrl": "https://storage.firebase.com/tax_cert_SUP004.pdf"
        },
        "registrationDocument": {
          "fileName": "registration_SUP004.pdf",
          "uploadStatus": "Uploaded",
          "fileUrl": "https://storage.firebase.com/registration_SUP004.pdf"
        },
        "attachments": {
          "fileName": "pharma_licenses_SUP004.pdf",
          "uploadStatus": "Uploaded",
          "fileUrl": "https://storage.firebase.com/licenses_SUP004.pdf"
        }
      },
      "metadata": {
        "createdAt": "2024-04-05T08:45:00Z",
        "updatedAt": "2024-08-22T10:30:00Z",
        "createdBy": "pharma@company.com",
        "isActive": true,
        "automaticOrders": false
      }
    },
    {
      "supplierID": "SUP005",
      "supplierDetails": {
        "supplierID": "SUP005",
        "supplierName": "Suez Steel Industries",
        "businessType": "Steel Manufacturer",
        "taxNumber": "500-654-987",
        "businessRegistrationNumber": "CR-2019-9876",
        "supplierRank": "Silver",
        "contactBy": "Phone",
        "dateAdded": "2024-05-12"
      },
      "contactDetails": {
        "firstName": "Mahmoud",
        "middleName": "Farouk",
        "lastName": "El Shamy",
        "title": "Operations Manager",
        "phoneNumber": "+20-62-56789012",
        "faxNumber": "+20-62-56789013",
        "email": "mahmoud.elshamy@suezsteel.com",
        "preferredLanguage": "Arabic"
      },
      "bankTransferDetails": {
        "beneficiaryName": "Suez Steel Industries",
        "beneficiaryBankName": "Bank of Alexandria",
        "bankSWIFTBICCode": "ALEXEGCX",
        "beneficiaryBankAccountNumberIBAN": "EG120014000056789012345678",
        "bankAddress": "Suez Branch, Suez Governorate, Egypt"
      },
      "addressDetails": {
        "country": "Egypt",
        "stateOrProvince": "Suez Governorate",
        "city": "Suez",
        "postalCode": "43511",
        "streetName": "Industrial Area, Zone 3",
        "warehouseAddress": "Heavy Industries Complex, Suez"
      },
      "alternativeAddressDetails": {
        "country": "Egypt",
        "stateOrProvince": "Suez Governorate",
        "city": "Suez",
        "postalCode": "43533",
        "streetName": "Heavy Industries Complex, Block A",
        "warehouseAddress": "Same as alternative address"
      },
      "warehouseDetails": {
        "country": "Egypt",
        "stateOrProvince": "Suez Governorate",
        "city": "Suez",
        "postalCode": "43533",
        "streetName": "Heavy Industries Complex, Block A"
      },
      "contractDetails": {
        "contractStartDate": "2024-05-01",
        "contractEndDate": "2024-10-31",
        "status": "Active",
        "taxCertificate": {
          "fileName": "tax_certificate_SUP005.pdf",
          "uploadStatus": "Uploaded",
          "fileUrl": "https://storage.firebase.com/tax_cert_SUP005.pdf"
        },
        "registrationDocument": {
          "fileName": "registration_SUP005.pdf",
          "uploadStatus": "Uploaded",
          "fileUrl": "https://storage.firebase.com/registration_SUP005.pdf"
        },
        "attachments": {
          "fileName": "steel_specifications_SUP005.pdf",
          "uploadStatus": "Uploaded",
          "fileUrl": "https://storage.firebase.com/specs_SUP005.pdf"
        }
      },
      "metadata": {
        "createdAt": "2024-05-12T14:20:00Z",
        "updatedAt": "2024-08-15T09:50:00Z",
        "createdBy": "materials@company.com",
        "isActive": true,
        "automaticOrders": false
      }
    },
    {
      "supplierID": "SUP006",
      "supplierDetails": {
        "supplierID": "SUP006",
        "supplierName": "Aswan Granite Export Co.",
        "businessType": "Natural Stone Exporter",
        "taxNumber": "600-147-258",
        "businessRegistrationNumber": "CR-2020-3456",
        "supplierRank": "Bronze",
        "contactBy": "Email",
        "dateAdded": "2024-06-18"
      },
      "contactDetails": {
        "firstName": "Nadia",
        "middleName": "Mostafa",
        "lastName": "Ali",
        "title": "Export Coordinator",
        "phoneNumber": "+20-97-67890123",
        "faxNumber": "+20-97-67890124",
        "email": "nadia.ali@aswangranite.com",
        "preferredLanguage": "English"
      },
      "bankTransferDetails": {
        "beneficiaryName": "Aswan Granite Export Co.",
        "beneficiaryBankName": "Agricultural Bank of Egypt",
        "bankSWIFTBICCode": "AGRIEGCX",
        "beneficiaryBankAccountNumberIBAN": "EG350061000067890123456789",
        "bankAddress": "Aswan Main Branch, Aswan Governorate, Egypt"
      },
      "addressDetails": {
        "country": "Egypt",
        "stateOrProvince": "Aswan Governorate",
        "city": "Aswan",
        "postalCode": "81511",
        "streetName": "12 Quarries Road",
        "warehouseAddress": "Granite Quarries Area, Aswan"
      },
      "alternativeAddressDetails": {
        "country": "Egypt",
        "stateOrProvince": "Aswan Governorate",
        "city": "Aswan",
        "postalCode": "81544",
        "streetName": "Granite Quarries Area, Site 15",
        "warehouseAddress": "Same as alternative address"
      },
      "warehouseDetails": {
        "country": "Egypt",
        "stateOrProvince": "Aswan Governorate",
        "city": "Aswan",
        "postalCode": "81544",
        "streetName": "Granite Quarries Area, Site 15"
      },
      "contractDetails": {
        "contractStartDate": "2024-06-01",
        "contractEndDate": "2025-05-31",
        "status": "Active",
        "taxCertificate": {
          "fileName": "tax_certificate_SUP006.pdf",
          "uploadStatus": "Pending",
          "fileUrl": ""
        },
        "registrationDocument": {
          "fileName": "registration_SUP006.pdf",
          "uploadStatus": "Uploaded",
          "fileUrl": "https://storage.firebase.com/registration_SUP006.pdf"
        },
        "attachments": {
          "fileName": "stone_catalog_SUP006.pdf",
          "uploadStatus": "Uploaded",
          "fileUrl": "https://storage.firebase.com/catalog_SUP006.pdf"
        }
      },
      "metadata": {
        "createdAt": "2024-06-18T12:35:00Z",
        "updatedAt": "2024-08-10T15:20:00Z",
        "createdBy": "construction@company.com",
        "isActive": true,
        "automaticOrders": false
      }
    },
    {
      "supplierID": "SUP007",
      "supplierDetails": {
        "supplierID": "SUP007",
        "supplierName": "Minya Agricultural Supplies",
        "businessType": "Agricultural Equipment",
        "taxNumber": "700-963-741",
        "businessRegistrationNumber": "CR-2023-7410",
        "supplierRank": "Silver",
        "contactBy": "Phone/Email",
        "dateAdded": "2024-07-22"
      },
      "contactDetails": {
        "firstName": "Hassan",
        "middleName": "Ahmed",
        "lastName": "Farid",
        "title": "Agricultural Consultant",
        "phoneNumber": "+20-86-78901234",
        "faxNumber": "+20-86-78901235",
        "email": "hassan.farid@minyaagri.com",
        "preferredLanguage": "Arabic"
      },
      "bankTransferDetails": {
        "beneficiaryName": "Minya Agricultural Supplies",
        "beneficiaryBankName": "Credit Agricole Egypt",
        "bankSWIFTBICCode": "AGRIEGCX",
        "beneficiaryBankAccountNumberIBAN": "EG470111000078901234567890",
        "bankAddress": "Minya Branch, Minya Governorate, Egypt"
      },
      "addressDetails": {
        "country": "Egypt",
        "stateOrProvince": "Minya Governorate",
        "city": "Minya",
        "postalCode": "61511",
        "streetName": "34 Agricultural Road",
        "warehouseAddress": "Agricultural Equipment Center, Minya"
      },
      "alternativeAddressDetails": {
        "country": "Egypt",
        "stateOrProvince": "Minya Governorate",
        "city": "Minya",
        "postalCode": "61555",
        "streetName": "Agricultural Equipment Center, Hall 8",
        "warehouseAddress": "Same as alternative address"
      },
      "warehouseDetails": {
        "country": "Egypt",
        "stateOrProvince": "Minya Governorate",
        "city": "Minya",
        "postalCode": "61555",
        "streetName": "Agricultural Equipment Center, Hall 8"
      },
      "contractDetails": {
        "contractStartDate": "2024-07-01",
        "contractEndDate": "2025-06-30",
        "status": "Active",
        "taxCertificate": {
          "fileName": "tax_certificate_SUP007.pdf",
          "uploadStatus": "Uploaded",
          "fileUrl": "https://storage.firebase.com/tax_cert_SUP007.pdf"
        },
        "registrationDocument": {
          "fileName": "registration_SUP007.pdf",
          "uploadStatus": "Uploaded",
          "fileUrl": "https://storage.firebase.com/registration_SUP007.pdf"
        },
        "attachments": {
          "fileName": "equipment_manual_SUP007.pdf",
          "uploadStatus": "Uploaded",
          "fileUrl": "https://storage.firebase.com/manual_SUP007.pdf"
        }
      },
      "metadata": {
        "createdAt": "2024-07-22T16:10:00Z",
        "updatedAt": "2024-08-28T11:45:00Z",
        "createdBy": "agriculture@company.com",
        "isActive": true,
        "automaticOrders": true
      }
    },
    {
      "supplierID": "SUP008",
      "supplierDetails": {
        "supplierID": "SUP008",
        "supplierName": "Port Said Logistics Hub",
        "businessType": "Logistics & Shipping",
        "taxNumber": "800-852-963",
        "businessRegistrationNumber": "CR-2021-8520",
        "supplierRank": "Gold",
        "contactBy": "Email",
        "dateAdded": "2024-08-15"
      },
      "contactDetails": {
        "firstName": "Youssef",
        "middleName": "Mahmoud",
        "lastName": "Saleh",
        "title": "Logistics Director",
        "phoneNumber": "+20-66-89012345",
        "faxNumber": "+20-66-89012346",
        "email": "youssef.saleh@portsaidlogistics.com",
        "preferredLanguage": "English"
      },
      "bankTransferDetails": {
        "beneficiaryName": "Port Said Logistics Hub",
        "beneficiaryBankName": "Suez Canal Bank",
        "bankSWIFTBICCode": "SCBLEGCX",
        "beneficiaryBankAccountNumberIBAN": "EG590055000089012345678901",
        "bankAddress": "Port Said Main Branch, Port Said, Egypt"
      },
      "addressDetails": {
        "country": "Egypt",
        "stateOrProvince": "Port Said Governorate",
        "city": "Port Said",
        "postalCode": "42511",
        "streetName": "56 Port Authority Street",
        "warehouseAddress": "Free Trade Zone, Port Said"
      },
      "alternativeAddressDetails": {
        "country": "Egypt",
        "stateOrProvince": "Port Said Governorate",
        "city": "Port Said",
        "postalCode": "42566",
        "streetName": "Free Trade Zone, Warehouse Complex 15",
        "warehouseAddress": "Same as alternative address"
      },
      "warehouseDetails": {
        "country": "Egypt",
        "stateOrProvince": "Port Said Governorate",
        "city": "Port Said",
        "postalCode": "42566",
        "streetName": "Free Trade Zone, Warehouse Complex 15"
      },
      "contractDetails": {
        "contractStartDate": "2024-08-01",
        "contractEndDate": "2025-07-31",
        "status": "Active",
        "taxCertificate": {
          "fileName": "tax_certificate_SUP008.pdf",
          "uploadStatus": "Uploaded",
          "fileUrl": "https://storage.firebase.com/tax_cert_SUP008.pdf"
        },
        "registrationDocument": {
          "fileName": "registration_SUP008.pdf",
          "uploadStatus": "Uploaded",
          "fileUrl": "https://storage.firebase.com/registration_SUP008.pdf"
        },
        "attachments": {
          "fileName": "shipping_rates_SUP008.pdf",
          "uploadStatus": "Uploaded",
          "fileUrl": "https://storage.firebase.com/rates_SUP008.pdf"
        }
      },
      "metadata": {
        "createdAt": "2024-08-15T13:25:00Z",
        "updatedAt": "2024-08-28T17:30:00Z",
        "createdBy": "logistics@company.com",
        "isActive": true,
        "automaticOrders": false
      }
    }
  ];

  Future<void> _uploadSuppliers() async {
    setState(() {
      _isUploading = true;
    });

    try {
      debugPrint('=== DEBUG INFO ===');
      debugPrint('_supplierData.length: ${_supplierData.length}');
      debugPrint('First supplier ID: ${_supplierData[0]['supplierID']}');
      debugPrint('=================');

      if (_supplierData.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No supplier data found to upload'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Convert JSON data to SupplierModel objects
      List<SupplierModel> suppliers = [];

      debugPrint('Starting conversion of ${_supplierData.length} suppliers...');

      for (int i = 0; i < _supplierData.length; i++) {
        try {
          debugPrint('Converting supplier ${i + 1}/${_supplierData.length}...');
          SupplierModel supplier = SupplierModel.fromJson(_supplierData[i]);
          suppliers.add(supplier);
          debugPrint(
              '✓ Converted supplier ${i + 1}: ${supplier.supplierID} - ${supplier.supplierDetails.supplierName}');
        } catch (e) {
          debugPrint('✗ Error converting supplier ${i + 1}: $e');
          debugPrint('Supplier data: ${_supplierData[i]}');
        }
      }

      debugPrint('=== CONVERSION COMPLETE ===');
      debugPrint('Successfully converted ${suppliers.length} suppliers');

      if (suppliers.isEmpty) {
        debugPrint('ERROR: No suppliers were successfully converted');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to convert supplier data'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      debugPrint('Starting Firebase upload...');
      // Upload to Firebase
      bool success = await _supplierService.uploadMultipleSuppliers(suppliers);

      debugPrint('Upload result: $success');

      if (success) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('${suppliers.length} suppliers uploaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to upload suppliers'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint('Upload error: $e');
      debugPrint('Error stack trace: ${e.toString()}');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _loadSuppliers() async {
    try {
      List<SupplierModel> suppliers = await _supplierService.getAllSuppliers();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Loaded ${suppliers.length} suppliers'),
          backgroundColor: Colors.blue,
        ),
      );

      // You can use the loaded suppliers here
      for (var supplier in suppliers) {
        debugPrint('Supplier: ${supplier.supplierDetails.supplierName}');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading suppliers: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supplier Management'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          physics: ClampingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.cloud_upload,
                        size: 48,
                        color: AppColors.blue,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Upload Suppliers to Firebase',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Path: /Demo/${InventoryPaths.companyId}/supplier/user/${InventoryPaths.userEmail}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 24),
                      customButton(
                        title: 'Upload All Suppliers',
                        function: _uploadSuppliers,
                        isLoading: _isUploading,
                        wrapContent: true,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.download,
                        size: 48,
                        color: AppColors.orange,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Load Suppliers from Firebase',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      customButton(
                        title: 'Load All Suppliers',
                        function: _loadSuppliers,
                        wrapContent: true,
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Instructions:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('1. Make sure Firebase is properly configured'),
                    Text('2. Add your supplier data to _supplierData list'),
                    Text(
                        '3. Click "Upload All Suppliers" to upload to Firebase'),
                    Text('4. Use "Load All Suppliers" to retrieve data'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Don't forget to add these dependencies to pubspec.yaml:
/*
dependencies:
  flutter:
    sdk: flutter
  cloud_firestore: ^4.13.6
  firebase_core: ^2.24.2
*/

// Initialize Firebase in your main.dart:
/*

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}
*/
