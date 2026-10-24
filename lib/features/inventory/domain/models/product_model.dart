import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert'; // Add this import for JSON encoding/decoding

class FieldWithTimestamp<T> {
  final T value;
  final DateTime timestamp;

  FieldWithTimestamp({
    required this.value,
    required this.timestamp,
  });

  factory FieldWithTimestamp.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return FieldWithTimestamp<T>(
        value: "N/A" as T,
        timestamp: DateTime.now(),
      );
    }

    // Direct access to value and timestamp
    final dynamic rawValue = json['value'];
    final String? timestampStr = json['timestamp'];

    // Handle List<String> type
    if (T == List<String>) {
      if (rawValue is List) {
        return FieldWithTimestamp<T>(
          value: List<String>.from(rawValue) as T,
          timestamp: DateTime.tryParse(timestampStr ?? "") ?? DateTime.now(),
        );
      }
      return FieldWithTimestamp<T>(
        value: <String>[] as T,
        timestamp: DateTime.tryParse(timestampStr ?? "") ?? DateTime.now(),
      );
    }

    // Handle String and other types
    return FieldWithTimestamp<T>(
      value: (rawValue?.toString() ?? "N/A") as T,
      timestamp: DateTime.tryParse(timestampStr ?? "") ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'value': value,
        'timestamp': timestamp.toIso8601String(),
      };
}

class DropdownFieldWithTimestamp {
  final String value;
  final List<String> options;
  final DateTime timestamp;

  DropdownFieldWithTimestamp({
    required this.value,
    required this.options,
    required this.timestamp,
  });

  factory DropdownFieldWithTimestamp.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return DropdownFieldWithTimestamp(
        value: "N/A",
        options: [],
        timestamp: DateTime.now(),
      );
    }

    return DropdownFieldWithTimestamp(
      value: json['value'] ?? "N/A",
      options: List<String>.from(json['options'] ?? []),
      timestamp: DateTime.tryParse(json['timestamp'] ?? "") ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'value': value,
        'options': options,
        'timestamp': timestamp.toIso8601String(),
      };
}

class EmployeeEntityModel {
  final String? id;
  final String? state;
  final String? firstName;
  final String? middleName;
  final String? lastName;
  final String? firstNameInArabic;
  final String? middleNameInArabic;
  final String? lastNameInArabic;
  final String? email;
  final MobilePhoneEntity? mobilePhone;
  final String? role;
  final String? title;
  final String? titleInArabic;
  final String? gender;
  final String? country;
  final String? departmentId;

  EmployeeEntityModel({
    this.id,
    this.state,
    this.firstName,
    this.middleName,
    this.lastName,
    this.firstNameInArabic,
    this.middleNameInArabic,
    this.lastNameInArabic,
    this.email,
    this.mobilePhone,
    this.role,
    this.title,
    this.titleInArabic,
    this.gender,
    this.country,
    this.departmentId,
  });

  factory EmployeeEntityModel.fromJson(Map<String, dynamic> json) {
    return EmployeeEntityModel(
      id: json['id'],
      state: json['state'],
      firstName: json['firstName'],
      middleName: json['middleName'],
      lastName: json['lastName'],
      firstNameInArabic: json['firstNameInArabic'],
      middleNameInArabic: json['middleNameInArabic'],
      lastNameInArabic: json['lastNameInArabic'],
      departmentId: json['departmentId'],
      email: json['email'],
      mobilePhone: json['mobilePhone'] != null
          ? MobilePhoneEntity.fromJson(json['mobilePhone'])
          : null,
      role: json['role'],
      title: json['title'],
      titleInArabic: json['titleInArabic'],
      gender: json['gender'],
      country: json['country'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'state': state,
      'firstName': firstName,
      'middleName': middleName,
      'lastName': lastName,
      'firstNameInArabic': firstNameInArabic,
      'middleNameInArabic': middleNameInArabic,
      'lastNameInArabic': lastNameInArabic,
      'departmentId': departmentId,
      'email': email,
      'mobilePhone': mobilePhone?.toJson(),
      'role': role,
      'title': title,
      'titleInArabic': titleInArabic,
      'gender': gender,
      'country': country,
    };
  }
}

class AcademicHistoryEntity {
  final String? gpa;
  final String? graduateFrom;
  final String? university;
  final String? yearOfGraduation;
  final String? graduateFromStatus;
  final String? universityStatus;
  final String? yearOfGraduationStatus;
  final String? gpaStatus;

  AcademicHistoryEntity({
    this.gpa,
    this.graduateFrom,
    this.university,
    this.yearOfGraduation,
    this.graduateFromStatus,
    this.universityStatus,
    this.yearOfGraduationStatus,
    this.gpaStatus,
  });

  factory AcademicHistoryEntity.fromJson(Map<String, dynamic> json) {
    return AcademicHistoryEntity(
      gpa: json['gpa'],
      graduateFrom: json['graduateFrom'],
      university: json['university'],
      yearOfGraduation: json['yearOfGraduation'],
      graduateFromStatus: json['graduateFromStatus'],
      universityStatus: json['universityStatus'],
      yearOfGraduationStatus: json['yearOfGraduationStatus'],
      gpaStatus: json['gpaStatus'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gpa': gpa,
      'graduateFrom': graduateFrom,
      'university': university,
      'yearOfGraduation': yearOfGraduation,
      'graduateFromStatus': graduateFromStatus,
      'universityStatus': universityStatus,
      'yearOfGraduationStatus': yearOfGraduationStatus,
      'gpaStatus': gpaStatus,
    };
  }
}

class MobilePhoneEntity {
  final String? phone;
  final String? countryCode;
  final String? countryApp;

  MobilePhoneEntity({
    this.phone,
    this.countryCode,
    this.countryApp,
  });

  factory MobilePhoneEntity.fromJson(Map<String, dynamic> json) {
    return MobilePhoneEntity(
      phone: json['phone'],
      countryCode: json['countryCode'],
      countryApp: json['countryApp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'countryCode': countryCode,
      'countryApp': countryApp,
    };
  }
}

class ProductModel {
  final FieldWithTimestamp<String> firstNameCreator;
  final FieldWithTimestamp<String> lastNameCreator;
  final FieldWithTimestamp<String> firstNameArCreator;
  final FieldWithTimestamp<String> lastNameArCreator;
  final FieldWithTimestamp<String> departmentCreator;
  final FieldWithTimestamp<String> departmentArCreator;
  final FieldWithTimestamp<String> jobTitleCreator;
  final FieldWithTimestamp<String> jobTitleArCreator;
  final FieldWithTimestamp<String> emailCreator;
  final FieldWithTimestamp<String> phoneCreator;
  final FieldWithTimestamp<String> orderId;
  final FieldWithTimestamp<String> orderType;
  final FieldWithTimestamp<String> productId;
  final FieldWithTimestamp<String> category;
  final FieldWithTimestamp<String> orderNote;
  final FieldWithTimestamp<String> subCategory;
  final FieldWithTimestamp<String> brand;
  final FieldWithTimestamp<String> model;
  final FieldWithTimestamp<String> quantity;
  final FieldWithTimestamp<String> unitCost;
  final FieldWithTimestamp<String> currency;
  final FieldWithTimestamp<String> supplierName;
  final FieldWithTimestamp<String> expectedLifetime;
  final FieldWithTimestamp<String> expectedDelivery;
  final FieldWithTimestamp<String> deliverySelectedData;
  final FieldWithTimestamp<String> reorderLevel;
  final FieldWithTimestamp<String> reorderQuantity;
  final FieldWithTimestamp<String> additionalNote;
  final FieldWithTimestamp<String> productQuantity;
  final FieldWithTimestamp<String>
      storageAllocations; // This stores JSON string of storage allocations

  final FieldWithTimestamp<String> usageFrequency;
  final FieldWithTimestamp<String> unitOfMeasurement;

  final FieldWithTimestamp<String> productName;
  final FieldWithTimestamp<String> orderDate;
  final FieldWithTimestamp<String> receivingDate;

  final DropdownFieldWithTimestamp storageRequirement;
  final DropdownFieldWithTimestamp year;
  final DropdownFieldWithTimestamp maintenanceFrequency;
  final DropdownFieldWithTimestamp storageLocation;

  final DropdownFieldWithTimestamp status;

  final FieldWithTimestamp<List<String>> requestType;
  final List<EmployeeEntityModel> approvalCycle;

  final FieldWithTimestamp<String> productSpecificationImage;
  final FieldWithTimestamp<String> productWarrantyImage;
  final FieldWithTimestamp<String> attachmentsImage;

  final DropdownFieldWithTimestamp paymentMethod;
  final DropdownFieldWithTimestamp deliveryMethod;
  final FieldWithTimestamp<String> vat;
  final FieldWithTimestamp<String> discountPercentage;
  final FieldWithTimestamp<String> shipping;
  final FieldWithTimestamp<String> orderValue;

  final FieldWithTimestamp<String> supplierId;
  final DropdownFieldWithTimestamp advancedPayment;
  final DropdownFieldWithTimestamp methodOfPayment;
  final FieldWithTimestamp<String> beneficiaryName;
  final FieldWithTimestamp<String> beneficiaryBankName;
  final FieldWithTimestamp<String> beneficiaryAccountIban;
  final FieldWithTimestamp<String> bankSwiftBicCode;
  final FieldWithTimestamp<String> bankAddress;

  final FieldWithTimestamp<String> transactionId;

  ProductModel({
    required this.firstNameCreator,
    required this.lastNameCreator,
    required this.firstNameArCreator,
    required this.lastNameArCreator,
    required this.departmentCreator,
    required this.departmentArCreator,
    required this.jobTitleCreator,
    required this.jobTitleArCreator,
    required this.emailCreator,
    required this.phoneCreator,
    required this.orderId,
    required this.orderType,
    required this.productId,
    required this.orderNote,
    required this.category,
    required this.subCategory,
    required this.brand,
    required this.model,
    required this.storageAllocations,
    required this.quantity,
    required this.unitCost,
    required this.currency,
    required this.supplierName,
    required this.expectedLifetime,
    required this.expectedDelivery,
    required this.reorderLevel,
    required this.deliveryMethod,
    required this.deliverySelectedData,
    required this.reorderQuantity,
    required this.additionalNote,
    required this.productQuantity,
    required this.usageFrequency,
    required this.unitOfMeasurement,
    required this.productName,
    required this.orderDate,
    required this.receivingDate,
    required this.storageRequirement,
    required this.year,
    required this.maintenanceFrequency,
    required this.storageLocation,
    required this.status,
    required this.requestType,
    required this.approvalCycle,
    required this.productSpecificationImage,
    required this.productWarrantyImage,
    required this.attachmentsImage,
    required this.paymentMethod,
    required this.vat,
    required this.discountPercentage,
    required this.shipping,
    required this.orderValue,
    required this.supplierId,
    required this.advancedPayment,
    required this.methodOfPayment,
    required this.beneficiaryName,
    required this.beneficiaryBankName,
    required this.beneficiaryAccountIban,
    required this.bankSwiftBicCode,
    required this.bankAddress,
    required this.transactionId,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    String extractValue(dynamic field) {
      if (field == null) return "N/A";

      // If Firestore Timestamp slipped through
      if (field is Timestamp) return field.toDate().toIso8601String();

      // Recursively unwrap {value: ...} (even if nested)
      if (field is Map<String, dynamic>) {
        final dynamic inner = field['value'];
        return extractValue(inner);
      }

      // Lists (e.g., requestType) as comma-separated
      if (field is List) {
        return field.map((e) => extractValue(e)).join(', ');
      }

      // Numbers/bools/strings
      return field.toString();
    }

    FieldWithTimestamp<String> createField(dynamic fieldData) {
      // Handle null case first
      if (fieldData == null) {
        return FieldWithTimestamp<String>(
          value: "N/A",
          timestamp: DateTime.now(),
        );
      }

      if (fieldData is Map<String, dynamic>) {
        // Extract value and timestamp from the map
        final extractedValue = extractValue(fieldData['value']);
        final timestampStr = fieldData['timestamp'] as String?;

        return FieldWithTimestamp<String>(
          value: extractedValue,
          timestamp: DateTime.tryParse(timestampStr ?? "") ?? DateTime.now(),
        );
      }

      // For direct values (string, number, etc.)
      return FieldWithTimestamp<String>(
        value: extractValue(fieldData),
        timestamp: DateTime.now(),
      );
    }

    // Special function for List<String> fields
    FieldWithTimestamp<List<String>> createListField(dynamic fieldData) {
      if (fieldData == null) {
        return FieldWithTimestamp<List<String>>(
          value: <String>[],
          timestamp: DateTime.now(),
        );
      }

      if (fieldData is Map<String, dynamic>) {
        final dynamic rawValue = fieldData['value'];
        final String? timestampStr = fieldData['timestamp'];

        List<String> listValue = <String>[];
        if (rawValue is List) {
          listValue =
              List<String>.from(rawValue.map((e) => e?.toString() ?? ""));
        }

        return FieldWithTimestamp<List<String>>(
          value: listValue,
          timestamp: DateTime.tryParse(timestampStr ?? "") ?? DateTime.now(),
        );
      }

      // Handle direct list
      if (fieldData is List) {
        return FieldWithTimestamp<List<String>>(
          value: List<String>.from(fieldData.map((e) => e?.toString() ?? "")),
          timestamp: DateTime.now(),
        );
      }

      return FieldWithTimestamp<List<String>>(
        value: <String>[],
        timestamp: DateTime.now(),
      );
    }

    return ProductModel(
      firstNameCreator: createField(json['firstNameCreator']),
      firstNameArCreator: createField(json['firstNameArCreator']),
      lastNameCreator: createField(json['lastNameCreator']),
      lastNameArCreator: createField(json['lastNameArCreator']),
      departmentCreator: createField(json['departmentCreator']),
      departmentArCreator: createField(json['departmentArCreator']),
      jobTitleCreator: createField(json['jobTitleCreator']),
      jobTitleArCreator: createField(json['jobTitleArCreator']),
      emailCreator: createField(json['emailCreator']),
      phoneCreator: createField(json['phoneCreator']),
      orderId: createField(json['orderId']),
      orderType: createField(json['orderType']),
      productId: createField(json['productId']),
      orderNote: createField(json['orderNote']),
      category: createField(json['category']),
      subCategory: createField(json['subCategory']),
      brand: createField(json['brand']),
      model: createField(json['model']),
      quantity: createField(json['quantity']),
      unitCost: createField(json['unitCost']),
      currency: createField(json['currency']),
      supplierName: createField(json['supplierName']),
      expectedLifetime: createField(json['expectedLifetime']),
      expectedDelivery: createField(json['expectedDelivery']),
      deliverySelectedData: createField(json['deliverySelectedData']),
      reorderLevel: createField(json['reorderLevel']),
      reorderQuantity: createField(json['reorderQuantity']),
      additionalNote: createField(json['additionalNote']),
      productQuantity: createField(json['productQuantity']),
      usageFrequency: createField(json['usageFrequency']),
      unitOfMeasurement: createField(json['unitOfMeasurement']),
      productName: createField(json['productName']),
      orderDate: createField(json['orderDate']),
      receivingDate: createField(json['receivingDate']),
      storageRequirement:
          DropdownFieldWithTimestamp.fromJson(json['storageRequirement']),
      year: DropdownFieldWithTimestamp.fromJson(json['year']),
      deliveryMethod:
          DropdownFieldWithTimestamp.fromJson(json['deliveryMethod']),
      maintenanceFrequency:
          DropdownFieldWithTimestamp.fromJson(json['maintenanceFrequency']),
      storageLocation:
          DropdownFieldWithTimestamp.fromJson(json['storageLocation']),
      status: _parseDropdownMaybeString(json['status']),
      requestType: createListField(json['requestType']),
      approvalCycle: (json['approvalCycle'] as List?)
              ?.map((e) =>
                  EmployeeEntityModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      productSpecificationImage: createField(json['productSpecificationImage']),
      productWarrantyImage: createField(json['productWarrantyImage']),
      attachmentsImage: createField(json['attachmentsImage']),
      paymentMethod: _parseDropdownMaybeString(json['paymentMethod']),
      vat: createField(json['vat']),
      discountPercentage: createField(json['discountPercentage']),
      shipping: createField(json['shipping']),
      orderValue: createField(json['orderValue']),
      supplierId: createField(json['supplierId']),
      advancedPayment: _parseDropdownMaybeString(json['advancedPayment']),
      methodOfPayment: _parseDropdownMaybeString(json['methodOfPayment']),
      beneficiaryName: createField(json['beneficiaryName']),
      beneficiaryBankName: createField(json['beneficiaryBankName']),
      beneficiaryAccountIban: createField(json['beneficiaryAccountIban']),
      bankSwiftBicCode: createField(json['bankSwiftBicCode']),
      bankAddress: createField(json['bankAddress']),
      transactionId: createField(json['transactionId']),
      storageAllocations: createField(json['storageAllocations']),
    );
  }

  static DropdownFieldWithTimestamp _parseDropdownMaybeString(dynamic value) {
    if (value is String) {
      return DropdownFieldWithTimestamp(
        value: value,
        options: const [],
        timestamp: DateTime.now(),
      );
    } else if (value is Map<String, dynamic>) {
      return DropdownFieldWithTimestamp.fromJson(value);
    } else {
      return DropdownFieldWithTimestamp(
        value: "N/A",
        options: const [],
        timestamp: DateTime.now(),
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'firstNameCreator': firstNameCreator.toJson(),
      'firstNameArCreator': firstNameArCreator.toJson(),
      'lastNameCreator': lastNameCreator.toJson(),
      'lastNameArCreator': lastNameArCreator.toJson(),
      'departmentCreator': departmentCreator.toJson(),
      'departmentArCreator': departmentArCreator.toJson(),
      'jobTitleCreator': jobTitleCreator.toJson(),
      'jobTitleArCreator': jobTitleArCreator.toJson(),
      'emailCreator': emailCreator.toJson(),
      'phoneCreator': phoneCreator.toJson(),
      'productId': productId.toJson(),
      'orderId': orderId.toJson(),
      'orderType': orderType.toJson(),
      'category': category.toJson(),
      'subCategory': subCategory.toJson(),
      'brand': brand.toJson(),
      'model': model.toJson(),
      'orderNote': orderNote.toJson(),
      'quantity': quantity.toJson(),
      'unitCost': unitCost.toJson(),
      'currency': currency.toJson(),
      'supplierName': supplierName.toJson(),
      'deliveryMethod': deliveryMethod.toJson(),
      'expectedLifetime': expectedLifetime.toJson(),
      'expectedDelivery': expectedDelivery.toJson(),
      'deliverySelectedData': deliverySelectedData.toJson(),
      'reorderLevel': reorderLevel.toJson(),
      'reorderQuantity': reorderQuantity.toJson(),
      'additionalNote': additionalNote.toJson(),
      'productQuantity': productQuantity.toJson(),
      'usageFrequency': usageFrequency.toJson(),
      'unitOfMeasurement': unitOfMeasurement.toJson(),
      'productName': productName.toJson(),
      'orderDate': orderDate.toJson(),
      'receivingDate': receivingDate.toJson(),
      'storageRequirement': storageRequirement.toJson(),
      'year': year.toJson(),
      'maintenanceFrequency': maintenanceFrequency.toJson(),
      'storageLocation': storageLocation.toJson(),
      'status': status.toJson(),
      'requestType': requestType.toJson(),
      'approvalCycle': approvalCycle.map((e) => e.toJson()).toList(),
      'productSpecificationImage': productSpecificationImage.toJson(),
      'productWarrantyImage': productWarrantyImage.toJson(),
      'attachmentsImage': attachmentsImage.toJson(),
      'paymentMethod': paymentMethod.toJson(),
      'vat': vat.toJson(),
      'discountPercentage': discountPercentage.toJson(),
      'shipping': shipping.toJson(),
      'orderValue': orderValue.toJson(),
      'supplierId': supplierId.toJson(),
      'advancedPayment': advancedPayment.toJson(),
      'methodOfPayment': methodOfPayment.toJson(),
      'beneficiaryName': beneficiaryName.toJson(),
      'beneficiaryBankName': beneficiaryBankName.toJson(),
      'beneficiaryAccountIban': beneficiaryAccountIban.toJson(),
      'bankSwiftBicCode': bankSwiftBicCode.toJson(),
      'bankAddress': bankAddress.toJson(),
      'transactionId': transactionId.toJson(),
      'storageAllocations': storageAllocations.toJson(), // Add this line
    };
  }

  ProductModel copyWith({
    // existing
    FieldWithTimestamp<String>? firstNameCreator,
    FieldWithTimestamp<String>? lastNameCreator,
    FieldWithTimestamp<String>? firstNameArCreator,
    FieldWithTimestamp<String>? lastNameArCreator,
    FieldWithTimestamp<String>? departmentCreator,
    FieldWithTimestamp<String>? departmentArCreator,
    FieldWithTimestamp<String>? jobTitleCreator,
    FieldWithTimestamp<String>? jobTitleArCreator,
    FieldWithTimestamp<String>? emailCreator,
    FieldWithTimestamp<String>? phoneCreator,
    FieldWithTimestamp<String>? orderId,
    FieldWithTimestamp<String>? productId,
    FieldWithTimestamp<String>? category,
    FieldWithTimestamp<String>? orderType,
    FieldWithTimestamp<String>? subCategory,
    FieldWithTimestamp<String>? brand,
    FieldWithTimestamp<String>? orderNote,
    FieldWithTimestamp<String>? model,
    FieldWithTimestamp<String>? quantity,
    FieldWithTimestamp<String>? unitCost,
    FieldWithTimestamp<String>? currency,
    FieldWithTimestamp<String>? supplierName,
    FieldWithTimestamp<String>? expectedLifetime,
    FieldWithTimestamp<String>? deliverySelectedData,
    FieldWithTimestamp<String>? reorderLevel,
    FieldWithTimestamp<String>? reorderQuantity,
    FieldWithTimestamp<String>? additionalNote,
    FieldWithTimestamp<String>? productQuantity,
    FieldWithTimestamp<String>? usageFrequency,
    FieldWithTimestamp<String>? unitOfMeasurement,
    FieldWithTimestamp<String>? productName,
    FieldWithTimestamp<String>? orderDate,
    FieldWithTimestamp<String>? receivingDate,
    DropdownFieldWithTimestamp? storageRequirement,
    DropdownFieldWithTimestamp? year,
    DropdownFieldWithTimestamp? maintenanceFrequency,
    DropdownFieldWithTimestamp? storageLocation,
    DropdownFieldWithTimestamp? status,
    FieldWithTimestamp<List<String>>? requestType,
    List<EmployeeEntityModel>? approvalCycle,
    FieldWithTimestamp<String>? productSpecificationImage,
    FieldWithTimestamp<String>? productWarrantyImage,
    FieldWithTimestamp<String>? attachmentsImage,

    // new
    DropdownFieldWithTimestamp? paymentMethod,
    DropdownFieldWithTimestamp? deliveryMethod,
    FieldWithTimestamp<String>? vat,
    FieldWithTimestamp<String>? discountPercentage,
    FieldWithTimestamp<String>? shipping,
    FieldWithTimestamp<String>? orderValue,
    FieldWithTimestamp<String>? supplierId,
    DropdownFieldWithTimestamp? advancedPayment,
    DropdownFieldWithTimestamp? methodOfPayment,
    FieldWithTimestamp<String>? beneficiaryName,
    FieldWithTimestamp<String>? beneficiaryBankName,
    FieldWithTimestamp<String>? beneficiaryAccountIban,
    FieldWithTimestamp<String>? bankSwiftBicCode,
    FieldWithTimestamp<String>? bankAddress,
    FieldWithTimestamp<String>? transactionId,
    FieldWithTimestamp<String>? expectedDelivery,
    FieldWithTimestamp<String>? storageAllocations, // Add this line
  }) {
    // firstNameCreator
    // lastNameCreator
    // firstNameArCreator
    // lastNameArCreator
    // departmentCreator
    // departmentArCreator
    // jobTitleCreator
    // jobTitleArCreator
    // emailCreator
    // phoneCreator

    return ProductModel(
      // existing
      firstNameCreator: firstNameCreator ?? this.firstNameCreator,
      lastNameCreator: lastNameCreator ?? this.lastNameCreator,
      firstNameArCreator: firstNameArCreator ?? this.firstNameArCreator,
      lastNameArCreator: lastNameArCreator ?? this.lastNameArCreator,
      departmentCreator: departmentCreator ?? this.departmentCreator,
      departmentArCreator: departmentArCreator ?? this.departmentArCreator,
      jobTitleCreator: jobTitleCreator ?? this.jobTitleCreator,
      jobTitleArCreator: jobTitleArCreator ?? this.jobTitleArCreator,
      emailCreator: emailCreator ?? this.emailCreator,
      phoneCreator: phoneCreator ?? this.phoneCreator,

      orderId: orderId ?? this.orderId,
      orderType: orderType ?? this.orderType,
      productId: productId ?? this.productId,
      category: category ?? this.category,
      subCategory: subCategory ?? this.subCategory,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      quantity: quantity ?? this.quantity,
      deliveryMethod: deliveryMethod ?? this.deliveryMethod,
      unitCost: unitCost ?? this.unitCost,
      currency: currency ?? this.currency,
      orderNote: orderNote ?? this.orderNote,
      supplierName: supplierName ?? this.supplierName,
      expectedLifetime: expectedLifetime ?? this.expectedLifetime,
      expectedDelivery: expectedDelivery ?? this.expectedDelivery,
      deliverySelectedData: deliverySelectedData ?? this.deliverySelectedData,
      reorderLevel: reorderLevel ?? this.reorderLevel,
      reorderQuantity: reorderQuantity ?? this.reorderQuantity,
      additionalNote: additionalNote ?? this.additionalNote,
      productQuantity: productQuantity ?? this.productQuantity,
      usageFrequency: usageFrequency ?? this.usageFrequency,
      unitOfMeasurement: unitOfMeasurement ?? this.unitOfMeasurement,
      productName: productName ?? this.productName,
      orderDate: orderDate ?? this.orderDate,
      receivingDate: receivingDate ?? this.receivingDate,
      storageRequirement: storageRequirement ?? this.storageRequirement,
      year: year ?? this.year,
      maintenanceFrequency: maintenanceFrequency ?? this.maintenanceFrequency,
      storageLocation: storageLocation ?? this.storageLocation,
      status: status ?? this.status,
      requestType: requestType ?? this.requestType,
      approvalCycle: approvalCycle ?? this.approvalCycle,
      productSpecificationImage:
          productSpecificationImage ?? this.productSpecificationImage,
      productWarrantyImage: productWarrantyImage ?? this.productWarrantyImage,
      attachmentsImage: attachmentsImage ?? this.attachmentsImage,

      // new
      paymentMethod: paymentMethod ?? this.paymentMethod,
      vat: vat ?? this.vat,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      shipping: shipping ?? this.shipping,
      orderValue: orderValue ?? this.orderValue,
      supplierId: supplierId ?? this.supplierId,
      advancedPayment: advancedPayment ?? this.advancedPayment,
      methodOfPayment: methodOfPayment ?? this.methodOfPayment,
      beneficiaryName: beneficiaryName ?? this.beneficiaryName,
      beneficiaryBankName: beneficiaryBankName ?? this.beneficiaryBankName,
      beneficiaryAccountIban:
          beneficiaryAccountIban ?? this.beneficiaryAccountIban,
      bankSwiftBicCode: bankSwiftBicCode ?? this.bankSwiftBicCode,
      bankAddress: bankAddress ?? this.bankAddress,
      transactionId: transactionId ?? this.transactionId,
      storageAllocations:
          storageAllocations ?? this.storageAllocations, // Add this line
    );
  }

  // Helper method to decode storage allocations from JSON string
  List<Map<String, dynamic>> getStorageAllocations() {
    try {
      if (storageAllocations.value.isEmpty ||
          storageAllocations.value == "N/A") {
        return [];
      }
      final decoded = jsonDecode(storageAllocations.value);
      if (decoded is List) {
        return List<Map<String, dynamic>>.from(decoded);
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}

class StorageAllocationEntity {
  final String storageLocationId;
  final String quantity;

  StorageAllocationEntity({
    required this.storageLocationId,
    required this.quantity,
  });

  factory StorageAllocationEntity.fromJson(Map<String, dynamic> json) {
    return StorageAllocationEntity(
      storageLocationId: json['storageLocationId'] ?? '',
      quantity: json['quantity'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'storageLocationId': storageLocationId,
      'quantity': quantity,
    };
  }
}
