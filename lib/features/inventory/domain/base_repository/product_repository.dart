import 'package:file_picker/file_picker.dart';
import 'package:knowticed_plus/features/inventory/domain/models/supplier_model.dart';
import 'package:knowticed_plus/features/inventory/domain/models/product_model.dart';

abstract class ProductRepository {
  Future<List<ProductModel>> fetchAllProducts();
  Future<void> submitProduct(ProductModel product);
  Future<String> uploadFile(PlatformFile file, String folder);
  Future<List<ProductModel>> getProducts(String userEmail);
  Future<void> addProduct(ProductModel product, String userEmail);
  Future<void> updateProduct(ProductModel product, String userEmail);
  Future<void> deleteProduct(String productId, String userEmail);

  Future<List<ProductModel>> getOrders();

  Future<SupplierModel?> getSupplierById({
    required String supplierId,
    required String userEmail,
  });
}
