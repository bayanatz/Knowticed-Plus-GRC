import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

import 'package:knowticed_plus/features/inventory/domain/models/supplier_model.dart';
import 'package:knowticed_plus/features/inventory/domain/base_repository/product_repository.dart';
import 'package:knowticed_plus/features/inventory/domain/models/product_model.dart';
import 'package:knowticed_plus/features/inventory/helpers/inventory_paths.dart';

class ProductRepositoryImpl implements ProductRepository {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  ProductRepositoryImpl(this.firestore, {FirebaseStorage? storageInstance})
      : storage = storageInstance ?? FirebaseStorage.instance;

  @override
  Future<List<ProductModel>> fetchAllProducts() async {
    try {
      return await getProducts(InventoryPaths.userEmail);
    } catch (e) {
      throw Exception('Failed to fetch all products: $e');
    }
  }

  @override
  Future<void> submitProduct(ProductModel product) async {
    await firestore.collection("test").add(product.toJson());
  }

  @override
  Future<String> uploadFile(PlatformFile file, String folder) async {
    try {
      debugPrint("🧪 Upload Debug:");
      debugPrint("→ file.path = ${file.path}");
      debugPrint("→ file.bytes = ${file.bytes != null}");
      debugPrint("→ kIsWeb = $kIsWeb");

      final ref = storage.ref().child(
            '$folder/${DateTime.now().millisecondsSinceEpoch}_${file.name}',
          );

      UploadTask uploadTask;

      if (!kIsWeb && file.path != null) {
        debugPrint("🛠 Using putFile() ✅");

        final fileToUpload = File(file.path!);

        final exists = await fileToUpload.exists();
        final size = await fileToUpload.length();
        debugPrint("File exists: $exists");
        debugPrint("File size: $size bytes");

        if (!exists) {
          throw Exception("❌ File not found at path: ${file.path}");
        }

        uploadTask = ref.putFile(fileToUpload);
      } else if (kIsWeb && file.bytes != null) {
        debugPrint("🛠 Using putData() for Web ✅");
        uploadTask = ref.putData(file.bytes!);
      } else {
        throw Exception(
          "❌ Invalid upload: file.path is null or unsupported platform",
        );
      }

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      debugPrint("✅ Upload successful. URL: $downloadUrl");
      return downloadUrl;
    } catch (e) {
      debugPrint("Upload failed: $e");
      throw Exception("Upload failed: $e");
    }
  }

  // ============================================================================
  // CONVERT FIRESTORE ORDER DATA TO PRODUCTMODEL FORMAT
  // ============================================================================

  // Unwrap any {value, timestamp} (even nested). Keep maps that have 'options'.

  // ============================================================================
  // REPOSITORY IMPLEMENTATION
  // ============================================================================

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<ProductModel>> getProducts(String userEmail) async {
    try {
      debugPrint("🔍 Fetching products for user: $userEmail");

      final QuerySnapshot querySnapshot = await _firestore
          .collection('Demo')
          .doc(InventoryPaths.companyId)
          .collection('CreateOrder')
          .doc('user')
          .collection(userEmail)
          .get();

      debugPrint("📄 Found ${querySnapshot.docs.length} product documents");

      final List<ProductModel> products = [];

      for (var doc in querySnapshot.docs) {
        try {
          debugPrint("📝 Processing document: ${doc.id}");

          final data = doc.data() as Map<String, dynamic>;
          debugPrint("📊 Raw data keys: ${data.keys.toList()}");

          final product = ProductModel.fromJson(data);
          products.add(product);

          debugPrint(
              "✅ Successfully parsed product: ${product.productId.value}");
        } catch (e) {
          debugPrint("❌ Error parsing document ${doc.id}: $e");
          continue;
        }
      }

      debugPrint("✅ Successfully loaded ${products.length} products");
      return products;
    } catch (e) {
      debugPrint("❌ Error in getProducts: $e");
      throw Exception('Failed to fetch products: $e');
    }
  }

  @override
  Future<void> addProduct(ProductModel product, String userEmail) async {
    try {
      await _firestore
          .collection('Demo')
          .doc(InventoryPaths.companyId)
          .collection('CreateOrder')
          .doc('user')
          .collection(userEmail)
          .doc(product.productId.value)
          .set(product.toJson());
    } catch (e) {
      throw Exception('Failed to add product: $e');
    }
  }

  @override
  Future<void> updateProduct(ProductModel product, String userEmail) async {
    try {
      await _firestore
          .collection('Demo')
          .doc(InventoryPaths.companyId)
          .collection('CreateOrder')
          .doc('user')
          .collection(userEmail)
          .doc(product.productId.value)
          .update(product.toJson());
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  @override
  Future<void> deleteProduct(String productId, String userEmail) async {
    try {
      await _firestore
          .collection('Demo')
          .doc(InventoryPaths.companyId)
          .collection('CreateOrder')
          .doc('user')
          .collection(userEmail)
          .doc(productId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }

  // ============================================================================
  // ORDER METHODS WITH CUSTOM DATA CONVERSION
  // ============================================================================

  @override
  Future<List<ProductModel>> getOrders() async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection("Demo")
          .doc(InventoryPaths.companyId)
          .collection("order")
          .orderBy('createdAt', descending: true)
          .get();

      debugPrint(
          "📦 Total order documents found: ${querySnapshot.docs.length}");

      List<ProductModel> loadedOrders = [];

      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        try {
          Map<String, dynamic> orderData = doc.data() as Map<String, dynamic>;

          debugPrint("📝 Processing order document: ${doc.id}");

          // Add debug print for OR107 specifically
          if (doc.id == "OR107") {
            debugPrint("🔍 OR107 raw data: $orderData");
            debugPrint("🔍 OR107 products array: ${orderData['products']}");
            if (orderData['products'] != null) {
              debugPrint(
                  "🔍 OR107 products length: ${(orderData['products'] as List).length}");
            }
          }

          orderData['documentId'] = doc.id;
          if (!orderData.containsKey('orderId')) {
            orderData['orderId'] = doc.id;
          }

          if (orderData['products'] != null && orderData['products'] is List) {
            List<dynamic> productsData = orderData['products'];

            // Add debug print for OR107
            if (doc.id == "OR107") {
              debugPrint("🔍 OR107 processing ${productsData.length} products");
            }

            for (int i = 0; i < productsData.length; i++) {
              var productData = productsData[i];
              if (productData is Map<String, dynamic>) {
                try {
                  // Add order-level data to each product
                  productData['orderId'] = doc.id;

                  // Add other order-level fields if they exist
                  if (orderData['supplierName'] != null) {
                    productData['supplierName'] = orderData['supplierName'];
                  }
                  if (orderData['orderDate'] != null) {
                    productData['orderDate'] = orderData['orderDate'];
                  }
                  if (orderData['orderValue'] != null) {
                    productData['orderValue'] = orderData['orderValue'];
                  }
                  if (orderData['status'] != null) {
                    productData['status'] = orderData['status'];
                  }
                  if (orderData['paymentMethod'] != null) {
                    productData['paymentMethod'] = orderData['paymentMethod'];
                  }

                  ProductModel product = ProductModel.fromJson(productData);
                  loadedOrders.add(product);

                  // Add debug print for OR107
                  if (doc.id == "OR107") {
                    debugPrint(
                        "📋 OR107 Product $i: ${product.productName.value} - ID: ${product.productId.value}");
                  }
                } catch (e) {
                  debugPrint("❌ Error converting product data: $e");
                }
              }
            }
          }
        } catch (e) {
          debugPrint("❌ Error processing order ${doc.id}: $e");
        }
      }

      debugPrint("📦 Total products loaded: ${loadedOrders.length}");
      // Add debug print for OR107 count
      int or107Count =
          loadedOrders.where((p) => p.orderId.value == "OR107").length;
      debugPrint("🔍 OR107 products in loaded orders: $or107Count");

      return loadedOrders;
    } catch (e) {
      debugPrint("❌ Error loading orders: $e");
      throw Exception('Failed to fetch orders: $e');
    }
  }

  @override
  Future<SupplierModel?> getSupplierById({
    required String supplierId,
    required String userEmail,
  }) async {
    try {
      debugPrint(
          "🔍 Repository: Fetching supplier document for ID: $supplierId");
      debugPrint(
          "🔍 Repository: Path = Demo/${InventoryPaths.companyId}/supplier/user/$userEmail/$supplierId");

      final doc = await _firestore
          .collection('Demo')
          .doc(InventoryPaths.companyId)
          .collection('supplier')
          .doc(supplierId)
          .get();

      debugPrint("🔍 Repository: Document exists = ${doc.exists}");

      if (!doc.exists) {
        debugPrint(
            "❌ Repository: Supplier document not found for ID: $supplierId");
        return null; // Return null instead of throwing
      }

      final data = doc.data() as Map<String, dynamic>;
      data['supplierID'] = doc.id;

      debugPrint("✅ Repository: Supplier data retrieved successfully");
      return SupplierModel.fromJson(data);
    } catch (e) {
      debugPrint("❌ Repository: Error in getSupplierById: $e");
      throw Exception('getSupplierById failed: $e');
    }
  }
}
