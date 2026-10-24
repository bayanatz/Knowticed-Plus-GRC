part of 'product_cubit.dart';

@immutable
abstract class ProductState {}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductLoaded extends ProductState {
  final List<ProductModel> products;
  final List<ProductModel> filteredProducts;
  final String selectedFilter;
  final String searchQuery;
  final String statusFilter;
  final List<ProductModel> orders;
  final List<ProductModel> filteredOrders;

  ProductLoaded({
    required this.products,
    required this.filteredProducts,
    required this.selectedFilter,
    required this.searchQuery,
    required this.statusFilter,
    this.orders = const [],
    this.filteredOrders = const [],
  });

  ProductLoaded copyWith({
    List<ProductModel>? products,
    List<ProductModel>? filteredProducts,
    String? selectedFilter,
    String? searchQuery,
    String? statusFilter,
    List<ProductModel>? orders,
    List<ProductModel>? filteredOrders,
  }) {
    return ProductLoaded(
      products: products ?? this.products,
      filteredProducts: filteredProducts ?? this.filteredProducts,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter ?? this.statusFilter,
      orders: orders ?? this.orders,
      filteredOrders: filteredOrders ?? this.filteredOrders,
    );
  }
}

class ProductSuccess extends ProductState {}

class ProductError extends ProductState {
  final String message;

  ProductError(this.message);
}

class ProductUploadingFile extends ProductState {}

class ProductFileUploaded extends ProductState {
  final String downloadUrl;
  final String fileType;

  ProductFileUploaded({required this.downloadUrl, required this.fileType});
}

class ProductUploadError extends ProductState {
  final String message;

  ProductUploadError(this.message);
}

// Order-specific states
class OrderLoading extends ProductState {}

class OrderLoaded extends ProductState {
  final List<ProductModel> orders;
  final List<ProductModel> filteredOrders;
  final String selectedFilter;
  final String searchQuery;
  final String statusFilter;

  OrderLoaded({
    required this.orders,
    required this.filteredOrders,
    required this.selectedFilter,
    required this.searchQuery,
    required this.statusFilter,
  });

  OrderLoaded copyWith({
    List<ProductModel>? orders,
    List<ProductModel>? filteredOrders,
    String? selectedFilter,
    String? searchQuery,
    String? statusFilter,
  }) {
    return OrderLoaded(
      orders: orders ?? this.orders,
      filteredOrders: filteredOrders ?? this.filteredOrders,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter ?? this.statusFilter,
    );
  }
}

class OrderSuccess extends ProductState {}

class OrderError extends ProductState {
  final String message;

  OrderError(this.message);
}

class SupplierLoading extends ProductState {}

class SupplierLoaded extends ProductState {
  final SupplierModel supplier;

  SupplierLoaded({required this.supplier});
}

class SuppliersLoaded extends ProductState {
  final List<SupplierModel> suppliers;
  final List<SupplierModel> filteredSuppliers;
  final String searchQuery;

  SuppliersLoaded({
    required this.suppliers,
    required this.filteredSuppliers,
    required this.searchQuery,
  });

  SuppliersLoaded copyWith({
    List<SupplierModel>? suppliers,
    List<SupplierModel>? filteredSuppliers,
    String? searchQuery,
  }) {
    return SuppliersLoaded(
      suppliers: suppliers ?? this.suppliers,
      filteredSuppliers: filteredSuppliers ?? this.filteredSuppliers,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class SupplierSuccess extends ProductState {}

class SupplierError extends ProductState {
  final String message;

  SupplierError(this.message);
}

// Storage Location States
class StorageLocationLoading extends ProductState {}

class StorageLocationLoaded extends ProductState {
  final StorageLocation storageLocation;

  StorageLocationLoaded({required this.storageLocation});
}

class StorageLocationsLoaded extends ProductState {
  final List<StorageLocation> storageLocations;
  final List<StorageLocation> filteredStorageLocations;
  final String searchQuery;

  StorageLocationsLoaded({
    required this.storageLocations,
    required this.filteredStorageLocations,
    required this.searchQuery,
  });

  StorageLocationsLoaded copyWith({
    List<StorageLocation>? storageLocations,
    List<StorageLocation>? filteredStorageLocations,
    String? searchQuery,
  }) {
    return StorageLocationsLoaded(
      storageLocations: storageLocations ?? this.storageLocations,
      filteredStorageLocations:
          filteredStorageLocations ?? this.filteredStorageLocations,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class StorageLocationSuccess extends ProductState {}

class StorageLocationError extends ProductState {
  final String message;

  StorageLocationError(this.message);
}
