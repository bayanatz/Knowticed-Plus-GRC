import 'package:flutter/foundation.dart';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:knowticed_plus/core/helper/access/main_core_employee_controller.dart';
import 'package:knowticed_plus/features/inventory/domain/models/supplier_model.dart';
import 'package:knowticed_plus/features/inventory/inv10_supplier/presentation/ui/pages/add_new_supplier.dart';
import 'package:knowticed_plus/features/inventory/inv10_supplier/presentation/ui/pages/add_new_supplier_second.dart';
import 'package:knowticed_plus/features/inventory/helpers/inventory_paths.dart';

class SupplierDraftStore {
  SupplierDraftStore._();
  static final SupplierDraftStore instance = SupplierDraftStore._();
  List<File> attachmentFiles = [];
  // Add separate variables for both contract documents
  File? contractDocument1File;
  File? contractDocument2File;

  // ----- Page 1 -----
  String supplierID = '';
  String supplierName = '';
  String businessType = '';
  String taxNumber = '';
  String businessRegistrationNumber = '';
  String supplierRank = '';
  String createdBy = '';
  String dateAdded = '';
  List<ContactFormData> contacts = [];
  File? supplierImageFile; // Add supplier image file

  // ----- Page 2 -----
  String beneficiaryName = '';
  String beneficiaryBankName = '';
  String bankSWIFTBICCode = '';
  String beneficiaryBankAccountNumberIBAN = '';
  String bankAddress = '';
  List<AddressFormData> addresses = [];

  // ----- Page 3 (warehouses + contract) -----
  List<WarehouseDraft> warehouses = [WarehouseDraft()];
  String contractStartDate = '';
  String contractEndDate = '';
  File? taxCertificateFile; // شهادة ضريبية
  File? registrationDocumentFile; // عقد / تسجيل
  File? attachmentsFile; // مرفقات
  bool warehouseEnabled = false; // Warehouse switch state

  // Add these properties to preserve existing file URLs
  String? existingTaxCertificateUrl;
  String? existingRegistrationDocumentUrl;
  String? existingAttachmentsUrl;
  String? existingSupplierImageUrl; // Add existing supplier image URL
  String? existingContractDocument1Url; // Add existing contract document 1 URL
  String? existingContractDocument2Url; // Add existing contract document 2 URL

  // Optional metadata
  bool isActive = true;
  bool automaticOrders = false;

  // Helpers to fill from each page
  void setFromPage1({
    required String supplierID,
    required String supplierName,
    required String businessType,
    required String taxNumber,
    required String businessRegistrationNumber,
    required String supplierRank,
    required String createdBy,
    required String dateAdded,
    required List<ContactFormData> contacts,
    File? supplierImageFile, // Add this parameter
  }) {
    this.supplierID = supplierID;
    this.supplierName = supplierName;
    this.businessType = businessType;
    this.taxNumber = taxNumber;
    this.businessRegistrationNumber = businessRegistrationNumber;
    this.supplierRank = supplierRank;
    this.createdBy = createdBy;
    this.dateAdded = dateAdded;
    this.contacts = contacts.map((c) => _cloneContact(c)).toList();
    this.supplierImageFile = supplierImageFile; // Add this line
  }

  void setFromPage2({
    required String beneficiaryName,
    required String beneficiaryBankName,
    required String bankSWIFTBICCode,
    required String beneficiaryBankAccountNumberIBAN,
    required String bankAddress,
    required List<AddressFormData> addresses,
  }) {
    this.beneficiaryName = beneficiaryName;
    this.beneficiaryBankName = beneficiaryBankName;
    this.bankSWIFTBICCode = bankSWIFTBICCode;
    this.beneficiaryBankAccountNumberIBAN = beneficiaryBankAccountNumberIBAN;
    this.bankAddress = bankAddress;
    this.addresses = addresses.map((a) => _cloneAddress(a)).toList();
  }

  void setFromPage3({
    required List<WarehouseDraft> warehouses,
    required String contractStartDate,
    required String contractEndDate,
    File? taxCertificateFile,
    File? contractDocument1File, // First contract
    File? contractDocument2File, // Second contract
    List<File>? attachmentFiles, // Multiple attachments
    String? existingTaxCertificateUrl,
    String? existingRegistrationDocumentUrl,
    String? existingAttachmentsUrl,
    String? existingContractDocument1Url, // Add this parameter
    String? existingContractDocument2Url, // Add this parameter
    bool warehouseEnabled = false,
  }) {
    this.warehouses = warehouses.map((w) => w.copy()).toList();
    this.contractStartDate = contractStartDate;
    this.contractEndDate = contractEndDate;
    this.taxCertificateFile = taxCertificateFile;
    this.warehouseEnabled = warehouseEnabled;

    // ✅ Correct assignments
    this.contractDocument1File = contractDocument1File;
    this.contractDocument2File = contractDocument2File;
    this.attachmentFiles = attachmentFiles ?? [];

    // Store existing URLs
    this.existingTaxCertificateUrl = existingTaxCertificateUrl;
    this.existingRegistrationDocumentUrl = existingRegistrationDocumentUrl;
    this.existingAttachmentsUrl = existingAttachmentsUrl;
    this.existingContractDocument1Url = existingContractDocument1Url;
    this.existingContractDocument2Url = existingContractDocument2Url;
  }

  // Helper method to get current user email
  String _getCurrentUserEmail() {
    try {
      final employeeEntity =
          Get.find<MainCoreEmployeeController>().employeeEntity;
      return employeeEntity?.email ?? '';
    } catch (e) {
      debugPrint('Error getting employee email: $e');
      return ''; // Return empty string if controller not found
    }
  }

  Future<bool> deleteSupplierFromFirebase({
    required String supplierId,
  }) async {
    try {
      final currentUserEmail = _getCurrentUserEmail();
      if (currentUserEmail.isEmpty) {
        debugPrint('❌ No user email available');
        return false;
      }

      debugPrint('🗑️ Starting delete process for supplier: $supplierId');

      final docRef = FirebaseFirestore.instance
          .collection('Demo')
          .doc(InventoryPaths.companyId)
          .collection('supplier')
          .doc(supplierId);

      // Delete sub-collections first

      // Delete all contacts
      final contactsQuery = await docRef.collection('contacts').get();
      for (var doc in contactsQuery.docs) {
        await doc.reference.delete();
        debugPrint('✅ Deleted contact: ${doc.id}');
      }

      // Delete all addresses
      final addressesQuery = await docRef.collection('addresses').get();
      for (var doc in addressesQuery.docs) {
        await doc.reference.delete();
        debugPrint('✅ Deleted address: ${doc.id}');
      }

      // Delete all warehouses
      final warehousesQuery = await docRef.collection('warehouses').get();
      for (var doc in warehousesQuery.docs) {
        await doc.reference.delete();
        debugPrint('✅ Deleted warehouse: ${doc.id}');
      }

      // Get main document to retrieve file URLs for cleanup
      final supplierDoc = await docRef.get();
      if (supplierDoc.exists) {
        final data = supplierDoc.data()!;

        // Delete files from Firebase Storage
        final filesToDelete = [
          data['imageSupplier'],
          data['taxCertificateFileUrl'],
          data['registrationDocumentFileUrl'],
          data['attachmentsFileUrl'],
          data['contractDocument1FileUrl'],
          data['contractDocument2FileUrl'],
          data['contractDocumentFileUrl'],
        ];

        for (String? fileUrl in filesToDelete) {
          if (fileUrl != null && fileUrl.isNotEmpty) {
            try {
              final ref = FirebaseStorage.instance.refFromURL(fileUrl);
              await ref.delete();
              debugPrint('✅ Deleted file: ${ref.name}');
            } catch (e) {
              debugPrint('⚠️ Could not delete file $fileUrl: $e');
            }
          }
        }
      }

      // Finally, delete the main document
      await docRef.delete();
      debugPrint('✅ Deleted main supplier document: $supplierId');

      debugPrint('🗑️ Supplier deletion completed successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Error deleting supplier: $e');
      return false;
    }
  }

  Future<String> _uploadSingleFile(
      File file, String fileName, String docId) async {
    try {
      final storagePath = 'inventory/supplier/$docId/$fileName';
      final ref = FirebaseStorage.instance.ref().child(storagePath);

      debugPrint('Uploading: $fileName to $storagePath');

      final uploadTask = await ref.putFile(file);
      final url = await uploadTask.ref.getDownloadURL();

      debugPrint('✅ Upload successful: $fileName -> $url');
      return url;
    } catch (e) {
      debugPrint('❌ Upload failed: $fileName - Error: $e');
      return '';
    }
  }

  Future<void> uploadAllToFirebase() async {
    debugPrint('🚀 Starting uploadAllToFirebase...');

    try {
      final currentUserEmail = _getCurrentUserEmail();
      debugPrint('📧 Current user email: "$currentUserEmail"');

      if (currentUserEmail.isEmpty) {
        debugPrint('❌ No user email - throwing exception');
        throw Exception('No user email available for upload');
      }

      final nowIso = DateTime.now().toIso8601String();
      debugPrint('⏰ Current time: $nowIso');

      // Auto-populate createdBy and dateAdded if they're empty
      final creator = createdBy.isNotEmpty ? createdBy : currentUserEmail;
      final addedDate =
          dateAdded.isNotEmpty ? dateAdded : _formatDate(DateTime.now());

      final docId = supplierID.isNotEmpty
          ? supplierID
          : FirebaseFirestore.instance.collection('temp').doc().id;
      debugPrint('📄 Document ID: "$docId"');

      // Test Firebase connection
      debugPrint('🔥 Testing Firebase connection...');
      final testRef = FirebaseFirestore.instance
          .collection('Demo')
          .doc(InventoryPaths.companyId);
      await testRef.get();
      debugPrint('✅ Firebase connection successful');

      debugPrint('=== STARTING FILE UPLOADS ===');

      // Upload contract documents
      String contractDoc1Url = '';
      String contractDoc2Url = '';

      if (contractDocument1File != null) {
        debugPrint('📤 Uploading contract document 1...');
        contractDoc1Url = await _uploadSingleFile(
            contractDocument1File!, 'contract_document_1.png', docId);
        debugPrint('✅ Contract doc 1 uploaded: $contractDoc1Url');
      } else if (existingContractDocument1Url != null &&
          existingContractDocument1Url!.isNotEmpty) {
        contractDoc1Url = existingContractDocument1Url!;
        debugPrint(
            '🔗 Preserving existing contract document 1: $contractDoc1Url');
      }

      if (contractDocument2File != null) {
        debugPrint('📤 Uploading contract document 2...');
        contractDoc2Url = await _uploadSingleFile(
            contractDocument2File!, 'contract_document_2.png', docId);
        debugPrint('✅ Contract doc 2 uploaded: $contractDoc2Url');
      } else if (existingContractDocument2Url != null &&
          existingContractDocument2Url!.isNotEmpty) {
        contractDoc2Url = existingContractDocument2Url!;
        debugPrint(
            '🔗 Preserving existing contract document 2: $contractDoc2Url');
      }

      // Upload supplier image if present or preserve existing one
      String supplierImageUrl = '';
      if (supplierImageFile != null) {
        debugPrint('📤 Uploading supplier image...');
        final imageStoragePath = 'inventory/supplier/$docId/supplier_image.png';
        final imageRef = FirebaseStorage.instance.ref().child(imageStoragePath);

        try {
          final uploadTask = await imageRef.putFile(supplierImageFile!);
          supplierImageUrl = await uploadTask.ref.getDownloadURL();
          debugPrint('✅ Supplier image uploaded: $supplierImageUrl');
        } catch (e) {
          debugPrint('❌ Error uploading supplier image: $e');
          supplierImageUrl = existingSupplierImageUrl ?? '';
        }
      } else if (existingSupplierImageUrl != null &&
          existingSupplierImageUrl!.isNotEmpty) {
        supplierImageUrl = existingSupplierImageUrl!;
        debugPrint('🔗 Preserving existing supplier image: $supplierImageUrl');
      }

      // Upload files or preserve existing ones
      Future<Map<String, String>> uploadOrPreserveFile(
          File? newFile, String fileName, String? existingUrl) async {
        if (newFile != null) {
          debugPrint('📤 Uploading $fileName...');
          final storagePath = 'inventory/supplier/$docId/$fileName';
          final ref = FirebaseStorage.instance.ref().child(storagePath);

          try {
            final uploadTask = await ref.putFile(newFile);
            final url = await uploadTask.ref.getDownloadURL();
            debugPrint('✅ File uploaded: $fileName -> $url');
            return {'url': url, 'name': fileName};
          } catch (e) {
            debugPrint('❌ Error uploading $fileName: $e');
            return {'url': existingUrl ?? '', 'name': fileName};
          }
        }

        if (existingUrl != null && existingUrl.isNotEmpty) {
          debugPrint('🔗 Preserving existing file: $fileName -> $existingUrl');
          return {'url': existingUrl, 'name': fileName};
        }

        return {'url': '', 'name': ''};
      }

      final taxUpload = await uploadOrPreserveFile(
          taxCertificateFile, 'tax_certificate.png', existingTaxCertificateUrl);

      final regUpload = await uploadOrPreserveFile(registrationDocumentFile,
          'registration_document.png', existingRegistrationDocumentUrl);

      // Upload all attachment files
      List<String> attachmentUrls = [];
      for (int i = 0; i < attachmentFiles.length; i++) {
        try {
          debugPrint('📤 Uploading attachment ${i + 1}...');
          final url = await _uploadSingleFile(
              attachmentFiles[i], 'attachment_${i + 1}.png', docId);
          if (url.isNotEmpty) {
            attachmentUrls.add(url);
            debugPrint('✅ Attachment ${i + 1} uploaded: $url');
          }
        } catch (e) {
          debugPrint('❌ Error uploading attachment ${i + 1}: $e');
        }
      }

      final String primaryContractUrl = contractDoc1Url.isNotEmpty
          ? contractDoc1Url
          : (contractDoc2Url.isNotEmpty ? contractDoc2Url : '');

      final String primaryContractName = contractDoc1Url.isNotEmpty
          ? 'contract_document_1.png'
          : (contractDoc2Url.isNotEmpty ? 'contract_document_2.png' : '');

      final Map<String, String> contractDocUpload = {
        'url': primaryContractUrl,
        'name': primaryContractName,
      };

      final attUpload = await uploadOrPreserveFile(
          attachmentFiles.isNotEmpty ? attachmentFiles.first : null,
          'attachments.png',
          existingAttachmentsUrl);

      // Get main contact/address/warehouse data for backwards compatibility
      final mainContact = contacts.isNotEmpty ? contacts.first : null;
      final mainAddress = addresses.isNotEmpty ? addresses.first : null;
      final altAddress = addresses.length > 1 ? addresses[1] : null;
      final mainWarehouse =
          warehouseEnabled && warehouses.isNotEmpty ? warehouses.first : null;

      debugPrint('=== BUILDING SUPPLIER MODEL ===');
      debugPrint(
          'Main Contact: ${mainContact?.firstNameController.text ?? "N/A"}');
      debugPrint(
          'Main Address: ${mainAddress?.countryController.text ?? "N/A"}, ${mainAddress?.cityController.text ?? "N/A"}');
      debugPrint(
          'Main Warehouse: ${mainWarehouse?.country ?? "N/A"}, ${mainWarehouse?.city ?? "N/A"}');

      // Build the flattened supplier model (with primary contact/address/warehouse)
      final supplierModel = SupplierModel(
        // Basic Supplier Info
        supplierID: docId,
        imageSupplier: supplierImageUrl,
        supplierName: supplierName,
        businessType: businessType,
        taxNumber: taxNumber,
        businessRegistrationNumber: businessRegistrationNumber,
        supplierRank: supplierRank.isEmpty ? '-' : supplierRank,
        contactBy: creator,
        dateAdded: addedDate,

        // Contact Details (Primary Contact Only)
        firstName: mainContact?.firstNameController.text ?? '',
        middleName: mainContact?.middleNameController.text ?? '',
        lastName: mainContact?.lastNameController.text ?? '',
        title: mainContact?.titleController.text ?? '',
        phoneNumber: mainContact?.phoneNumberController.text ?? '',
        faxNumber: mainContact?.faxNumberController.text ?? '',
        email: mainContact?.emailController.text ?? '',
        preferredLanguage: mainContact?.preferredLanguageController.text ?? '',

        // Bank Transfer Details
        beneficiaryName: beneficiaryName,
        beneficiaryBankName: beneficiaryBankName,
        bankSWIFTBICCode: bankSWIFTBICCode,
        beneficiaryBankAccountNumberIBAN: beneficiaryBankAccountNumberIBAN,
        bankAddress: bankAddress,

        // Address Details (Primary Address Only)
        country: mainAddress?.countryController.text ?? '',
        stateOrProvince: mainAddress?.stateOrProvinceController.text ?? '',
        city: mainAddress?.cityController.text ?? '',
        postalCode: mainAddress?.postalCodeController.text ?? '',
        streetName: mainAddress?.streetNameController.text ?? '',
        warehouseAddress: mainAddress?.warehouseAddressController.text ?? '',

        // Alternative Address Details (Second Address Only)
        altCountry: altAddress?.countryController.text ?? '',
        altStateOrProvince: altAddress?.stateOrProvinceController.text ?? '',
        altCity: altAddress?.cityController.text ?? '',
        altPostalCode: altAddress?.postalCodeController.text ?? '',
        altStreetName: altAddress?.streetNameController.text ?? '',
        altWarehouseAddress: altAddress?.warehouseAddressController.text ?? '',

        // Warehouse Details (Primary Warehouse Only)
        warehouseCountry:
            warehouseEnabled ? (mainWarehouse?.country ?? '') : '',
        warehouseStateOrProvince:
            warehouseEnabled ? (mainWarehouse?.stateOrProvince ?? '') : '',
        warehouseCity: warehouseEnabled ? (mainWarehouse?.city ?? '') : '',
        warehousePostalCode:
            warehouseEnabled ? (mainWarehouse?.postalCode ?? '') : '',
        warehouseStreetName:
            warehouseEnabled ? (mainWarehouse?.streetName ?? '') : '',

        // Contract Details
        contractStartDate: contractStartDate,
        contractEndDate: contractEndDate,
        contractStatus: 'active',

        // Contract Document (3 fields)
        contractDocumentFileName: contractDocUpload['name'] ?? '',
        contractDocumentUploadStatus:
            (contractDocUpload['url'] ?? '').isEmpty ? 'pending' : 'uploaded',
        contractDocumentFileUrl: contractDocUpload['url'] ?? '',

        // Document Info - Tax Certificate
        taxCertificateFileName: taxUpload['name'] ?? '',
        taxCertificateUploadStatus:
            (taxUpload['url'] ?? '').isEmpty ? 'pending' : 'uploaded',
        taxCertificateFileUrl: taxUpload['url'] ?? '',

        // Document Info - Registration Document
        registrationDocumentFileName: regUpload['name'] ?? '',
        registrationDocumentUploadStatus:
            (regUpload['url'] ?? '').isEmpty ? 'pending' : 'uploaded',
        registrationDocumentFileUrl: regUpload['url'] ?? '',

        // Document Info - Attachments
        attachmentsFileName: attUpload['name'] ?? '',
        attachmentsUploadStatus:
            (attUpload['url'] ?? '').isEmpty ? 'pending' : 'uploaded',
        attachmentsFileUrl: attUpload['url'] ?? '',

        // Metadata
        createdAt: nowIso,
        addedOn: nowIso,
        createdBy: creator,
        isActive: isActive,
        automaticOrders: automaticOrders,

        // Warehouse switch state
        enable: warehouseEnabled ? 'warehouse_enabled' : 'warehouse_disabled',
      );

      debugPrint('=== SAVING TO FIRESTORE ===');
      debugPrint(
          'Firestore path: Demo/${InventoryPaths.companyId}/supplier/user/$currentUserEmail/$docId');

      // Get document reference
      final docRef = FirebaseFirestore.instance
          .collection('Demo')
          .doc(InventoryPaths.companyId)
          .collection('supplier')
          .doc(docId);

      // Save main supplier document
      debugPrint('💾 Saving main supplier document...');
      await docRef.set(supplierModel.toJson(), SetOptions(merge: true));
      debugPrint('✅ Main supplier document saved successfully');

      // Save contract document URLs as separate fields
      Map<String, dynamic> contractDocuments = {};
      if (contractDoc1Url.isNotEmpty) {
        contractDocuments['contractDocument1FileUrl'] = contractDoc1Url;
        contractDocuments['contractDocument1FileName'] =
            'contract_document_1.png';
        contractDocuments['contractDocument1UploadStatus'] = 'uploaded';
      }
      if (contractDoc2Url.isNotEmpty) {
        contractDocuments['contractDocument2FileUrl'] = contractDoc2Url;
        contractDocuments['contractDocument2FileName'] =
            'contract_document_2.png';
        contractDocuments['contractDocument2UploadStatus'] = 'uploaded';
      }

      // Update document with contract URLs if we have any
      if (contractDocuments.isNotEmpty) {
        debugPrint('💾 Saving contract document URLs...');
        await docRef.update(contractDocuments);
        debugPrint('✅ Contract document URLs saved');
      }

      // SAVE ALL CONTACTS as sub-collection
      debugPrint('--- Saving ${contacts.length} contacts ---');
      for (int i = 0; i < contacts.length; i++) {
        final contact = contacts[i];
        final contactData = {
          'contact_id': 'contact_${i + 1}',
          'contact_order': i + 1,
          'firstName': contact.firstNameController.text,
          'middleName': contact.middleNameController.text,
          'lastName': contact.lastNameController.text,
          'title': contact.titleController.text,
          'phoneNumber': contact.phoneNumberController.text,
          'faxNumber': contact.faxNumberController.text,
          'email': contact.emailController.text,
          'preferredLanguage': contact.preferredLanguageController.text,
          'is_primary': i == 0,
          'created_at': nowIso,
          'addedOn': nowIso,
        };

        await docRef
            .collection('contacts')
            .doc('contact_${i + 1}')
            .set(contactData);
        debugPrint(
            '✅ Contact ${i + 1} saved: ${contact.firstNameController.text} ${contact.lastNameController.text}');
      }

      // SAVE ALL ADDRESSES as sub-collection
      debugPrint('--- Saving ${addresses.length} addresses ---');
      for (int i = 0; i < addresses.length; i++) {
        final address = addresses[i];
        final addressData = {
          'address_id': 'address_${i + 1}',
          'address_order': i + 1,
          'country': address.countryController.text,
          'stateOrProvince': address.stateOrProvinceController.text,
          'city': address.cityController.text,
          'postalCode': address.postalCodeController.text,
          'streetName': address.streetNameController.text,
          'warehouseAddress': address.warehouseAddressController.text,
          'is_primary': i == 0,
          'created_at': nowIso,
          'addedOn': nowIso,
        };

        await docRef
            .collection('addresses')
            .doc('address_${i + 1}')
            .set(addressData);
        debugPrint(
            '✅ Address ${i + 1} saved: ${address.countryController.text}, ${address.cityController.text}');
      }

      // SAVE ALL WAREHOUSES as sub-collection (only if warehouse is enabled)
      if (warehouseEnabled && warehouses.isNotEmpty) {
        debugPrint('--- Saving ${warehouses.length} warehouses ---');
        for (int i = 0; i < warehouses.length; i++) {
          final warehouse = warehouses[i];
          final warehouseData = {
            'warehouse_id': 'warehouse_${i + 1}',
            'warehouse_order': i + 1,
            'country': warehouse.country,
            'stateOrProvince': warehouse.stateOrProvince,
            'city': warehouse.city,
            'postalCode': warehouse.postalCode,
            'streetName': warehouse.streetName,
            'is_primary': i == 0,
            'created_at': nowIso,
            'addedOn': nowIso,
          };

          await docRef
              .collection('warehouses')
              .doc('warehouse_${i + 1}')
              .set(warehouseData);
          debugPrint(
              '✅ Warehouse ${i + 1} saved: ${warehouse.country}, ${warehouse.city}');
        }
      } else {
        debugPrint(
            '⏭️ Warehouse disabled or no warehouses - skipping warehouse sub-collection');
      }

      // Save summary information to the main document
      debugPrint('💾 Saving summary information...');
      await docRef.update({
        'total_contacts': contacts.length,
        'total_addresses': addresses.length,
        'total_warehouses': warehouseEnabled ? warehouses.length : 0,
        'has_multiple_contacts': contacts.length > 1,
        'has_multiple_addresses': addresses.length > 1,
        'has_multiple_warehouses': warehouseEnabled && warehouses.length > 1,
        'has_supplier_image': supplierImageUrl.isNotEmpty,
        'has_contract_documents':
            contractDoc1Url.isNotEmpty || contractDoc2Url.isNotEmpty,
        'last_updated': nowIso,
      });

      debugPrint('🎉 UPLOAD COMPLETED SUCCESSFULLY! 🎉');
      debugPrint('📄 Document ID: $docId');
      debugPrint('📧 User Email: $currentUserEmail');
      debugPrint('🏢 Supplier Name: $supplierName');
      debugPrint('📊 Sub-collections created:');
      debugPrint('  - contacts: ${contacts.length} documents');
      debugPrint('  - addresses: ${addresses.length} documents');
      debugPrint(
          '  - warehouses: ${warehouseEnabled ? warehouses.length : 0} documents');
    } catch (e, stackTrace) {
      debugPrint('❌ Error in uploadAllToFirebase: $e');
      debugPrint('📍 Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Helper method to format date as "day month year"
  String _formatDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  // Clear after save if you want
  void clear() {
    supplierID = '';
    supplierName = '';
    businessType = '';
    taxNumber = '';
    businessRegistrationNumber = '';
    supplierRank = '';
    createdBy = '';
    dateAdded = '';
    contacts = [];
    supplierImageFile = null;

    beneficiaryName = '';
    beneficiaryBankName = '';
    bankSWIFTBICCode = '';
    beneficiaryBankAccountNumberIBAN = '';
    bankAddress = '';
    addresses = [];

    warehouses = [WarehouseDraft()];
    contractStartDate = '';
    contractEndDate = '';
    taxCertificateFile = null;
    registrationDocumentFile = null;
    attachmentsFile = null;
    warehouseEnabled = false;

    // Clear contract document files
    contractDocument1File = null;
    contractDocument2File = null;
    attachmentFiles = [];

    // Clear existing URLs
    existingTaxCertificateUrl = null;
    existingRegistrationDocumentUrl = null;
    existingAttachmentsUrl = null;
    existingSupplierImageUrl = null;
    existingContractDocument1Url = null;
    existingContractDocument2Url = null;

    isActive = true;
    automaticOrders = false;
  }

  // Method to read supplier data back from Firebase (including sub-collections)
  Future<Map<String, dynamic>?> readSupplierFromFirebase({
    required String supplierId,
  }) async {
    final currentUserEmail = _getCurrentUserEmail();
    if (currentUserEmail.isEmpty) {
      debugPrint('❌ No user email available');
      return null;
    }

    try {
      final docRef = FirebaseFirestore.instance
          .collection('Demo')
          .doc(InventoryPaths.companyId)
          .collection('supplier')
          .doc(supplierId);

      // Get main supplier document
      final supplierDoc = await docRef.get();
      if (!supplierDoc.exists) {
        debugPrint('Supplier document not found: $supplierId');
        return null;
      }

      final supplierData = supplierDoc.data()!;

      // Get all contacts
      final contactsQuery =
          await docRef.collection('contacts').orderBy('contact_order').get();
      final contactsList = contactsQuery.docs.map((doc) => doc.data()).toList();

      // Get all addresses
      final addressesQuery =
          await docRef.collection('addresses').orderBy('address_order').get();
      final addressesList =
          addressesQuery.docs.map((doc) => doc.data()).toList();

      // Get all warehouses
      final warehousesQuery = await docRef
          .collection('warehouses')
          .orderBy('warehouse_order')
          .get();
      final warehousesList =
          warehousesQuery.docs.map((doc) => doc.data()).toList();

      // Combine all data
      final completeSupplierData = {
        ...supplierData,
        'contacts': contactsList,
        'addresses': addressesList,
        'warehouses': warehousesList,
      };

      debugPrint('✅ Successfully read supplier data with sub-collections');
      debugPrint('Contacts: ${contactsList.length}');
      debugPrint('Addresses: ${addressesList.length}');
      debugPrint('Warehouses: ${warehousesList.length}');
      debugPrint(
          'Has Image: ${supplierData['imageSupplier']?.isNotEmpty ?? false}');
      debugPrint(
          'Has Contract Doc 1: ${supplierData['contractDocument1FileUrl']?.isNotEmpty ?? false}');
      debugPrint(
          'Has Contract Doc 2: ${supplierData['contractDocument2FileUrl']?.isNotEmpty ?? false}');

      return completeSupplierData;
    } catch (e) {
      debugPrint('❌ Error reading supplier from Firebase: $e');
      return null;
    }
  }

  // Method to load existing supplier data into the draft store for editing
  void loadFromFirebaseData(Map<String, dynamic> supplierData) {
    // Basic supplier info
    supplierID = supplierData['supplierID'] ?? '';
    supplierName = supplierData['supplierName'] ?? '';
    businessType = supplierData['businessType'] ?? '';
    taxNumber = supplierData['taxNumber'] ?? '';
    businessRegistrationNumber =
        supplierData['businessRegistrationNumber'] ?? '';
    supplierRank = supplierData['supplierRank'] ?? '';
    createdBy = supplierData['createdBy'] ?? '';
    dateAdded = supplierData['dateAdded'] ?? '';

    // Store existing image URL
    existingSupplierImageUrl = supplierData['imageSupplier'];

    // Bank details
    beneficiaryName = supplierData['beneficiaryName'] ?? '';
    beneficiaryBankName = supplierData['beneficiaryBankName'] ?? '';
    bankSWIFTBICCode = supplierData['bankSWIFTBICCode'] ?? '';
    beneficiaryBankAccountNumberIBAN =
        supplierData['beneficiaryBankAccountNumberIBAN'] ?? '';
    bankAddress = supplierData['bankAddress'] ?? '';

    // Contract details
    contractStartDate = supplierData['contractStartDate'] ?? '';
    contractEndDate = supplierData['contractEndDate'] ?? '';

    // Warehouse state
    warehouseEnabled = supplierData['enable'] == 'warehouse_enabled';

    // Store existing file URLs
    existingTaxCertificateUrl = supplierData['taxCertificateFileUrl'];
    existingRegistrationDocumentUrl =
        supplierData['registrationDocumentFileUrl'];
    existingAttachmentsUrl = supplierData['attachmentsFileUrl'];
    existingContractDocument1Url = supplierData['contractDocument1FileUrl'];
    existingContractDocument2Url = supplierData['contractDocument2FileUrl'];

    // Metadata
    isActive = supplierData['isActive'] ?? true;
    automaticOrders = supplierData['automaticOrders'] ?? false;

    debugPrint('✅ Supplier data loaded into draft store for editing');
    debugPrint('Supplier ID: $supplierID');
    debugPrint(
        'Has existing image: ${existingSupplierImageUrl?.isNotEmpty ?? false}');
    debugPrint(
        'Has existing contract doc 1: ${existingContractDocument1Url?.isNotEmpty ?? false}');
    debugPrint(
        'Has existing contract doc 2: ${existingContractDocument2Url?.isNotEmpty ?? false}');
  }

  // Cloners
  ContactFormData _cloneContact(ContactFormData c) {
    final x = ContactFormData();
    x.firstNameController.text = c.firstNameController.text;
    x.middleNameController.text = c.middleNameController.text;
    x.lastNameController.text = c.lastNameController.text;
    x.titleController.text = c.titleController.text;
    x.phoneNumberController.text = c.phoneNumberController.text;
    x.faxNumberController.text = c.faxNumberController.text;
    x.emailController.text = c.emailController.text;
    x.preferredLanguageController.text = c.preferredLanguageController.text;
    return x;
  }

  AddressFormData _cloneAddress(AddressFormData a) {
    final x = AddressFormData();
    x.countryController.text = a.countryController.text;
    x.stateOrProvinceController.text = a.stateOrProvinceController.text;
    x.cityController.text = a.cityController.text;
    x.postalCodeController.text = a.postalCodeController.text;
    x.streetNameController.text = a.streetNameController.text;
    x.warehouseAddressController.text = a.warehouseAddressController.text;
    return x;
  }
}

// Light warehouse draft (no controllers on page 3)
class WarehouseDraft {
  String country = '';
  String stateOrProvince = '';
  String city = '';
  String postalCode = '';
  String streetName = '';

  WarehouseDraft copy() {
    final x = WarehouseDraft();
    x.country = country;
    x.stateOrProvince = stateOrProvince;
    x.city = city;
    x.postalCode = postalCode;
    x.streetName = streetName;
    return x;
  }
}
