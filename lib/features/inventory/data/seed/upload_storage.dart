import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:knowticed_plus/features/inventory/helpers/inventory_paths.dart';

class StorageLocation {
  final String id;
  final String name;
  final String country;
  final String stateOrProvince;
  final String city;
  final String postalCode;
  final String branchName;
  final String area;
  final String createdBy;
  final DateTime dateAdded;
  final String assignedDepartment;
  final String accessLevel;
  final int storageCapacity;
  final String capacityUnit;
  final String conditionOfStorage;
  final String equipmentAvailable;
  final String additionalNote;

  StorageLocation({
    required this.id,
    required this.name,
    required this.country,
    required this.stateOrProvince,
    required this.city,
    required this.postalCode,
    required this.branchName,
    required this.area,
    required this.createdBy,
    required this.dateAdded,
    required this.assignedDepartment,
    required this.accessLevel,
    required this.storageCapacity,
    required this.capacityUnit,
    required this.conditionOfStorage,
    required this.equipmentAvailable,
    required this.additionalNote,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'country': country,
      'stateOrProvince': stateOrProvince,
      'city': city,
      'postalCode': postalCode,
      'branchName': branchName,
      'area': area,
      'createdBy': createdBy,
      'dateAdded': Timestamp.fromDate(dateAdded),
      'assignedDepartment': assignedDepartment,
      'accessLevel': accessLevel,
      'storageCapacity': storageCapacity,
      'capacityUnit': capacityUnit,
      'conditionOfStorage': conditionOfStorage,
      'equipmentAvailable': equipmentAvailable,
      'additionalNote': additionalNote,
    };
  }
}

class StorageLocationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionPath =
      '/Demo/${InventoryPaths.companyId}/storage_location/user/${InventoryPaths.userEmail}';

  // Create 8 storage locations based on your screen data
  List<StorageLocation> getStorageLocations() {
    return [
      StorageLocation(
        id: '001',
        name: 'IT Tech',
        country: 'Manufacturer',
        stateOrProvince: '1021564526984-1612',
        city: '1021564526984-1612',
        postalCode: '1021564526984-1612',
        branchName: '1021564526984-1612',
        area: 'Floor 2',
        createdBy: 'Amro Handousa',
        dateAdded: DateTime(2025, 5, 10),
        assignedDepartment: 'Department',
        accessLevel: 'Manager',
        storageCapacity: 10,
        capacityUnit: 'Unit',
        conditionOfStorage: 'climate',
        equipmentAvailable: 'climate',
        additionalNote: 'Text here',
      ),
      StorageLocation(
        id: '002',
        name: 'Electronics Warehouse',
        country: 'Egypt',
        stateOrProvince: 'Cairo',
        city: 'New Cairo',
        postalCode: '11835',
        branchName: 'Main Electronics Hub',
        area: 'Floor 1',
        createdBy: 'Ahmed Hassan',
        dateAdded: DateTime(2025, 5, 15),
        assignedDepartment: 'Electronics',
        accessLevel: 'Supervisor',
        storageCapacity: 50,
        capacityUnit: 'Cubic Meters',
        conditionOfStorage: 'Temperature Controlled',
        equipmentAvailable: 'Forklifts, Shelving',
        additionalNote: 'High security area for valuable electronics',
      ),
      StorageLocation(
        id: '003',
        name: 'Medical Supplies Storage',
        country: 'Egypt',
        stateOrProvince: 'Giza',
        city: 'Giza',
        postalCode: '12511',
        branchName: 'Healthcare Center',
        area: 'Floor 3',
        createdBy: 'Dr. Sarah Mohamed',
        dateAdded: DateTime(2025, 5, 12),
        assignedDepartment: 'Medical',
        accessLevel: 'Manager',
        storageCapacity: 25,
        capacityUnit: 'Cubic Meters',
        conditionOfStorage: 'Sterile Environment',
        equipmentAvailable: 'Refrigeration Units',
        additionalNote: 'Requires special handling protocols',
      ),
      StorageLocation(
        id: '004',
        name: 'Raw Materials Depot',
        country: 'Egypt',
        stateOrProvince: 'Alexandria',
        city: 'Alexandria',
        postalCode: '21500',
        branchName: 'Industrial Zone',
        area: 'Ground Floor',
        createdBy: 'Omar Farouk',
        dateAdded: DateTime(2025, 5, 8),
        assignedDepartment: 'Manufacturing',
        accessLevel: 'Operator',
        storageCapacity: 100,
        capacityUnit: 'Tons',
        conditionOfStorage: 'Dry Storage',
        equipmentAvailable: 'Cranes, Conveyors',
        additionalNote: 'Heavy machinery storage area',
      ),
      StorageLocation(
        id: '005',
        name: 'Food & Beverage Storage',
        country: 'Egypt',
        stateOrProvince: 'Gharbia',
        city: 'Tanta',
        postalCode: '31500',
        branchName: 'Food Processing Plant',
        area: 'Cold Storage',
        createdBy: 'Fatima Ali',
        dateAdded: DateTime(2025, 5, 20),
        assignedDepartment: 'Food Services',
        accessLevel: 'Manager',
        storageCapacity: 75,
        capacityUnit: 'Cubic Meters',
        conditionOfStorage: 'Frozen',
        equipmentAvailable: 'Freezers, Loading Docks',
        additionalNote: 'HACCP compliant facility',
      ),
      StorageLocation(
        id: '006',
        name: 'Textile Warehouse',
        country: 'Egypt',
        stateOrProvince: 'Dakahlia',
        city: 'Mansoura',
        postalCode: '35500',
        branchName: 'Textile Manufacturing',
        area: 'Floor 2',
        createdBy: 'Youssef Ibrahim',
        dateAdded: DateTime(2025, 5, 18),
        assignedDepartment: 'Textiles',
        accessLevel: 'Supervisor',
        storageCapacity: 40,
        capacityUnit: 'Cubic Meters',
        conditionOfStorage: 'Humidity Controlled',
        equipmentAvailable: 'Fabric Rollers, Climate Control',
        additionalNote: 'Fire suppression system installed',
      ),
      StorageLocation(
        id: '007',
        name: 'Chemical Storage Facility',
        country: 'Egypt',
        stateOrProvince: 'Qalyubia',
        city: 'Shubra El Kheima',
        postalCode: '13500',
        branchName: 'Chemical Processing Unit',
        area: 'Basement Level',
        createdBy: 'Dr. Mahmoud Rashad',
        dateAdded: DateTime(2025, 5, 14),
        assignedDepartment: 'Chemical',
        accessLevel: 'Manager',
        storageCapacity: 15,
        capacityUnit: 'Cubic Meters',
        conditionOfStorage: 'Hazmat Compliant',
        equipmentAvailable: 'Safety Showers, Ventilation',
        additionalNote: 'Restricted access - safety training required',
      ),
      StorageLocation(
        id: '008',
        name: 'Automotive Parts Center',
        country: 'Egypt',
        stateOrProvince: 'Cairo',
        city: '6th October City',
        postalCode: '12500',
        branchName: 'Automotive Hub',
        area: 'Multiple Floors',
        createdBy: 'Khaled Mostafa',
        dateAdded: DateTime(2025, 5, 22),
        assignedDepartment: 'Automotive',
        accessLevel: 'Operator',
        storageCapacity: 80,
        capacityUnit: 'Cubic Meters',
        conditionOfStorage: 'Standard',
        equipmentAvailable: 'Automated Retrieval System',
        additionalNote: 'Integrated with ERP system',
      ),
    ];
  }

  // Upload all storage locations to Firebase using the specific path
  Future<void> uploadStorageLocations() async {
    try {
      final locations = getStorageLocations();
      final batch = _firestore.batch();

      for (final location in locations) {
        final docRef = _firestore.collection(collectionPath).doc(location.id);
        batch.set(docRef, location.toFirestore());
      }

      await batch.commit();
      debugPrint(
          'Successfully uploaded ${locations.length} storage locations to Firebase at path: $collectionPath');
    } catch (e) {
      debugPrint('Error uploading storage locations: $e');
      rethrow;
    }
  }

  // Upload single storage location
  Future<void> uploadSingleLocation(StorageLocation location) async {
    try {
      await _firestore
          .collection('Demo')
          .doc(InventoryPaths.companyId)
          .collection('storage_location')
          .doc('user')
          .collection(InventoryPaths.userEmail)
          .doc(location.id)
          .set(location.toFirestore());
      debugPrint(
          'Successfully uploaded storage location: ${location.name} to Demo/${InventoryPaths.companyId}/storage_location/user/${InventoryPaths.userEmail}');
    } catch (e) {
      debugPrint('Error uploading storage location: $e');
      rethrow;
    }
  }

  // Fetch all storage locations
  Future<List<StorageLocation>> fetchStorageLocations() async {
    try {
      final querySnapshot = await _firestore
          .collection('Demo')
          .doc(InventoryPaths.companyId)
          .collection('storage_location')
          .doc('user')
          .collection(InventoryPaths.userEmail)
          .get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return StorageLocation(
          id: data['id'],
          name: data['name'],
          country: data['country'],
          stateOrProvince: data['stateOrProvince'],
          city: data['city'],
          postalCode: data['postalCode'],
          branchName: data['branchName'],
          area: data['area'],
          createdBy: data['createdBy'],
          dateAdded: (data['dateAdded'] as Timestamp).toDate(),
          assignedDepartment: data['assignedDepartment'],
          accessLevel: data['accessLevel'],
          storageCapacity: data['storageCapacity'],
          capacityUnit: data['capacityUnit'],
          conditionOfStorage: data['conditionOfStorage'],
          equipmentAvailable: data['equipmentAvailable'],
          additionalNote: data['additionalNote'],
        );
      }).toList();
    } catch (e) {
      debugPrint('Error fetching storage locations: $e');
      rethrow;
    }
  }

  // Add method to get the full document path for a specific location
  String getLocationPath(String locationId) {
    return 'Demo/${InventoryPaths.companyId}/storage_location/user/${InventoryPaths.userEmail}/$locationId';
  }

  // Add method to delete a specific location
  Future<void> deleteLocation(String locationId) async {
    try {
      await _firestore
          .collection('Demo')
          .doc(InventoryPaths.companyId)
          .collection('storage_location')
          .doc('user')
          .collection(InventoryPaths.userEmail)
          .doc(locationId)
          .delete();
      debugPrint('Successfully deleted storage location: $locationId');
    } catch (e) {
      debugPrint('Error deleting storage location: $e');
      rethrow;
    }
  }

  // Add method to update a specific location
  Future<void> updateLocation(StorageLocation location) async {
    try {
      await _firestore
          .collection('Demo')
          .doc(InventoryPaths.companyId)
          .collection('storage_location')
          .doc('user')
          .collection(InventoryPaths.userEmail)
          .doc(location.id)
          .update(location.toFirestore());
      debugPrint('Successfully updated storage location: ${location.name}');
    } catch (e) {
      debugPrint('Error updating storage location: $e');
      rethrow;
    }
  }
}

// Example usage in a Flutter widget
class StorageLocationUploadWidget extends StatefulWidget {
  const StorageLocationUploadWidget({super.key});

  @override
  State<StorageLocationUploadWidget> createState() =>
      _StorageLocationUploadWidgetState();
}

class _StorageLocationUploadWidgetState
    extends State<StorageLocationUploadWidget> {
  final StorageLocationService _service = StorageLocationService();
  bool _isUploading = false;

  Future<void> _uploadLocations() async {
    setState(() {
      _isUploading = true;
    });

    try {
      await _service.uploadStorageLocations();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully uploaded 8 storage locations!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Storage Location Upload'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.warehouse,
              size: 100,
              color: AppColors.blue,
            ),
            SizedBox(height: 20),
            Text(
              'Upload to Firebase',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Path: Demo/${InventoryPaths.companyId}/storage_location/user/${InventoryPaths.userEmail}',
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontFamily: 'monospace'),
            ),
            SizedBox(height: 10),
            Text(
              'This will upload 8 storage locations to your Firebase path',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: 30),
            customButton(
              title: 'Upload To Firebase',
              function: _uploadLocations,
              isLoading: _isUploading,
              wrapContent: true,
            ),
          ],
        ),
      ),
    );
  }
}
