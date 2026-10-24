import 'package:flutter/widgets.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:knowticed_plus/core/app_services/firebase/live_refresh.dart';
import 'package:knowticed_plus/features/inventory/domain/models/storage_location_model.dart';
import 'package:knowticed_plus/features/inventory/domain/models/supplier_model.dart';
import 'package:knowticed_plus/features/inventory/domain/models/product_model.dart';

import 'package:knowticed_plus/features/inventory/domain/base_repository/product_repository.dart';
import 'package:knowticed_plus/features/inventory/helpers/inventory_paths.dart';

part 'product_state.dart';

class ProductCubit extends Cubit<ProductState> {
  final ProductRepository repository;

  ProductCubit(this.repository) : super(ProductInitial());

  final LiveRefresh _live = LiveRefresh();
  String? _watchedSupplierId;
  String? _watchedOrdersSupplierId;

  // Same owner and path `ProductRepositoryImpl.getProducts` reads.
  static String get _ownerEmail => InventoryPaths.userEmail;
  static String get _productsPath =>
      'Demo/${InventoryPaths.companyId}/CreateOrder/user/$_ownerEmail';

  static ProductCubit get(BuildContext context) => BlocProvider.of(context);

  // ============================================================================
  // PRODUCT METHODS
  // ============================================================================

  Future<void> loadProducts({bool silent = false}) async {
    try {
      debugPrint("📢 loadProducts() called");
      if (!silent) emit(ProductLoading());

      // Use getProducts directly instead of fetchAllProducts
      final products = await repository.getProducts(_ownerEmail);

      debugPrint("✅ Products loaded: ${products.length}");

      final current = state;
      if (silent && current is ProductLoaded) {
        // A background refresh keeps the user's tab, status and search.
        var filtered = _getFilteredByCategory(products, current.selectedFilter);
        filtered = _applyStatusFilter(filtered, current.statusFilter);
        filtered = _applySearchFilter(filtered, current.searchQuery);
        emit(current.copyWith(products: products, filteredProducts: filtered));
        return;
      }

      emit(ProductLoaded(
        products: products,
        filteredProducts: products,
        selectedFilter: 'Products',
        searchQuery: '',
        statusFilter: 'all',
      ));
      _live.watchPaths([_productsPath], () => loadProducts(silent: true));
    } catch (e) {
      debugPrint("❌ Error in loadProducts(): $e");
      if (!silent) {
        emit(ProductError("Failed to load products: ${e.toString()}"));
      }
    }
  }

  Future<void> submitProduct(ProductModel product) async {
    emit(ProductLoading());
    try {
      await repository.submitProduct(product);
      emit(ProductSuccess());
      // Reload products after successful submission
      await loadProducts();
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> updateProduct(ProductModel product) async {
    try {
      await repository.updateProduct(product, InventoryPaths.userEmail);
      await loadProducts();
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await repository.deleteProduct(productId, InventoryPaths.userEmail);
      await loadProducts();
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  void filterProductsByCategory(String filter) {
    final currentState = state;
    if (currentState is ProductLoaded) {
      List<ProductModel> filtered;

      switch (filter) {
        case 'Assets':
          filtered = currentState.products
              .where((product) => product.status.value == 'Assets')
              .toList();
          break;
        case 'Consumables':
          filtered = currentState.products
              .where((product) => product.status.value == 'Consumable')
              .toList();
          break;
        case 'Orders':
          filtered = currentState.products
              .where((product) => product.orderDate.value.isNotEmpty)
              .toList();
          break;
        case 'Suppliers':
          filtered = currentState.products
              .where((product) => product.supplierName.value.isNotEmpty)
              .toList();
          break;
        case 'Storage Locations':
          filtered = currentState.products
              .where((product) => product.storageLocation.value.isNotEmpty)
              .toList();
          break;
        default: // Products or All
          filtered = currentState.products;
      }

      // Apply existing search and status filters
      filtered = _applyAllFilters(
          filtered, currentState.searchQuery, currentState.statusFilter);

      emit(currentState.copyWith(
        filteredProducts: filtered,
        selectedFilter: filter,
      ));
    }
  }

  void filterProductsByStatus(String statusFilter) {
    final currentState = state;
    if (currentState is ProductLoaded) {
      List<ProductModel> filtered = _getFilteredByCategory(
          currentState.products, currentState.selectedFilter);

      // Apply status filter
      if (statusFilter != 'all') {
        switch (statusFilter) {
          case 'In Stock':
            filtered = filtered.where((product) {
              final quantity = int.tryParse(product.quantity.value) ?? 0;
              final reorderLevel =
                  int.tryParse(product.reorderLevel.value) ?? 0;
              return quantity > reorderLevel;
            }).toList();
            break;
          case 'Out Of Stock':
            filtered = filtered.where((product) {
              final quantity = int.tryParse(product.quantity.value) ?? 0;
              return quantity == 0;
            }).toList();
            break;
          case 'Low Stock':
            filtered = filtered.where((product) {
              final quantity = int.tryParse(product.quantity.value) ?? 0;
              final reorderLevel =
                  int.tryParse(product.reorderLevel.value) ?? 0;
              return quantity > 0 && quantity <= reorderLevel;
            }).toList();
            break;
          case 'assigned':
            filtered = filtered.where((product) {
              return product.status.value == 'Assets';
            }).toList();
            break;
          case 'unassigned':
            filtered = filtered.where((product) {
              return product.status.value == 'Assets';
            }).toList();
            break;
        }
      }

      // Apply search filter
      filtered = _applySearchFilter(filtered, currentState.searchQuery);

      emit(currentState.copyWith(
        filteredProducts: filtered,
        statusFilter: statusFilter,
      ));
    }
  }

  void searchProducts(String query) {
    final currentState = state;
    if (currentState is ProductLoaded) {
      List<ProductModel> filtered = _getFilteredByCategory(
          currentState.products, currentState.selectedFilter);

      // Apply status filter
      filtered = _applyStatusFilter(filtered, currentState.statusFilter);

      // Apply search filter
      filtered = _applySearchFilter(filtered, query);

      emit(currentState.copyWith(
        filteredProducts: filtered,
        searchQuery: query,
      ));
    }
  }

  void clearFilters() {
    final currentState = state;
    if (currentState is ProductLoaded) {
      emit(currentState.copyWith(
        filteredProducts: currentState.products,
        selectedFilter: 'Products',
        searchQuery: '',
        statusFilter: 'all',
      ));
    }
  }

  // ============================================================================
  // ORDER METHODS
  // ============================================================================

  Future<void> loadOrders() async {
    try {
      debugPrint("📢 loadOrders() called");
      emit(OrderLoading());

      // Load orders from the specified path
      final orders = await repository.getOrders();

      debugPrint("✅ Orders loaded: ${orders.length}");

      emit(OrderLoaded(
        orders: orders,
        filteredOrders: orders,
        selectedFilter: 'Orders',
        searchQuery: '',
        statusFilter: 'all',
      ));
    } catch (e) {
      debugPrint("❌ Error in loadOrders(): $e");
      emit(OrderError("Failed to load orders: ${e.toString()}"));
    }
  }

  void filterOrdersByCategory(String filter) {
    final currentState = state;
    if (currentState is OrderLoaded) {
      List<ProductModel> filtered;

      switch (filter) {
        case 'Pending':
          filtered = currentState.orders
              .where((order) => order.status.value == 'Pending')
              .toList();
          break;
        case 'Approved':
          filtered = currentState.orders
              .where((order) => order.status.value == 'Approved')
              .toList();
          break;
        case 'Processing':
          filtered = currentState.orders
              .where((order) => order.status.value == 'Processing')
              .toList();
          break;
        case 'Delivered':
          filtered = currentState.orders
              .where((order) => order.status.value == 'Delivered')
              .toList();
          break;
        case 'Cancelled':
          filtered = currentState.orders
              .where((order) => order.status.value == 'Cancelled')
              .toList();
          break;
        default: // All Orders
          filtered = currentState.orders;
      }

      // Apply existing search and status filters
      filtered = _applyOrderFilters(
          filtered, currentState.searchQuery, currentState.statusFilter);

      emit(currentState.copyWith(
        filteredOrders: filtered,
        selectedFilter: filter,
      ));
    }
  }

  void filterOrdersByStatus(String statusFilter) {
    final currentState = state;
    if (currentState is OrderLoaded) {
      List<ProductModel> filtered = _getFilteredOrdersByCategory(
          currentState.orders, currentState.selectedFilter);

      // Apply status filter
      filtered = _applyOrderStatusFilter(filtered, statusFilter);

      // Apply search filter
      filtered = _applyOrderSearchFilter(filtered, currentState.searchQuery);

      emit(currentState.copyWith(
        filteredOrders: filtered,
        statusFilter: statusFilter,
      ));
    }
  }

  void searchOrders(String query) {
    final currentState = state;
    if (currentState is OrderLoaded) {
      List<ProductModel> filtered = _getFilteredOrdersByCategory(
          currentState.orders, currentState.selectedFilter);

      // Apply status filter
      filtered = _applyOrderStatusFilter(filtered, currentState.statusFilter);

      // Apply search filter
      filtered = _applyOrderSearchFilter(filtered, query);

      emit(currentState.copyWith(
        filteredOrders: filtered,
        searchQuery: query,
      ));
    }
  }

  void clearOrderFilters() {
    final currentState = state;
    if (currentState is OrderLoaded) {
      emit(currentState.copyWith(
        filteredOrders: currentState.orders,
        selectedFilter: 'Orders',
        searchQuery: '',
        statusFilter: 'all',
      ));
    }
  }

  // ============================================================================
  // FILE UPLOAD METHODS
  // ============================================================================

  Future<void> uploadFile(PlatformFile file, String type) async {
    emit(ProductUploadingFile());

    try {
      final url = await repository.uploadFile(file, "inventory");

      emit(ProductFileUploaded(downloadUrl: url, fileType: type));
    } catch (e) {
      emit(ProductUploadError(e.toString()));
    }
  }

  // ============================================================================
  // PRODUCT HELPER METHODS
  // ============================================================================

  List<ProductModel> _getFilteredByCategory(
      List<ProductModel> products, String filter) {
    switch (filter) {
      case 'Assets':
        return products
            .where((product) => product.status.value == 'Assets')
            .toList();
      case 'Consumables':
        return products
            .where((product) => product.status.value == 'Consumable')
            .toList();
      case 'Orders':
        return products
            .where((product) => product.orderDate.value.isNotEmpty)
            .toList();
      case 'Suppliers':
        return products
            .where((product) => product.supplierName.value.isNotEmpty)
            .toList();
      case 'Storage Locations':
        return products
            .where((product) => product.storageLocation.value.isNotEmpty)
            .toList();
      default:
        return products;
    }
  }

  List<ProductModel> _applyStatusFilter(
      List<ProductModel> products, String statusFilter) {
    if (statusFilter == 'all') return products;

    switch (statusFilter) {
      case 'In Stock':
        return products.where((product) {
          final quantity = int.tryParse(product.quantity.value) ?? 0;
          final reorderLevel = int.tryParse(product.reorderLevel.value) ?? 0;
          return quantity > reorderLevel;
        }).toList();
      case 'Out Of Stock':
        return products.where((product) {
          final quantity = int.tryParse(product.quantity.value) ?? 0;
          return quantity == 0;
        }).toList();
      case 'Low Stock':
        return products.where((product) {
          final quantity = int.tryParse(product.quantity.value) ?? 0;
          final reorderLevel = int.tryParse(product.reorderLevel.value) ?? 0;
          return quantity > 0 && quantity <= reorderLevel;
        }).toList();
      case 'assigned':
      case 'unassigned':
        return products
            .where((product) => product.status.value == 'Assets')
            .toList();
      default:
        return products;
    }
  }

  List<ProductModel> _applySearchFilter(
      List<ProductModel> products, String query) {
    if (query.isEmpty) return products;

    final lowercaseQuery = query.toLowerCase();
    return products
        .where((product) =>
            product.productName.value.toLowerCase().contains(lowercaseQuery) ||
            product.productId.value.toLowerCase().contains(lowercaseQuery) ||
            product.brand.value.toLowerCase().contains(lowercaseQuery) ||
            product.model.value.toLowerCase().contains(lowercaseQuery) ||
            product.supplierName.value.toLowerCase().contains(lowercaseQuery) ||
            product.category.value.toLowerCase().contains(lowercaseQuery))
        .toList();
  }

  List<ProductModel> _applyAllFilters(
      List<ProductModel> products, String searchQuery, String statusFilter) {
    var filtered = _applyStatusFilter(products, statusFilter);
    return _applySearchFilter(filtered, searchQuery);
  }

  // ============================================================================
  // ORDER HELPER METHODS
  // ============================================================================

  List<ProductModel> _getFilteredOrdersByCategory(
      List<ProductModel> orders, String filter) {
    switch (filter) {
      case 'Pending':
        return orders
            .where((order) => order.status.value == 'Pending')
            .toList();
      case 'Approved':
        return orders
            .where((order) => order.status.value == 'Approved')
            .toList();
      case 'Processing':
        return orders
            .where((order) => order.status.value == 'Processing')
            .toList();
      case 'Delivered':
        return orders
            .where((order) => order.status.value == 'Delivered')
            .toList();
      case 'Cancelled':
        return orders
            .where((order) => order.status.value == 'Cancelled')
            .toList();
      default:
        return orders;
    }
  }

  List<ProductModel> _applyOrderStatusFilter(
      List<ProductModel> orders, String statusFilter) {
    if (statusFilter == 'all') return orders;

    switch (statusFilter) {
      case 'Pending':
        return orders
            .where((order) => order.status.value == 'Pending')
            .toList();
      case 'Processing':
        return orders
            .where((order) => order.status.value == 'Processing')
            .toList();
      case 'Approved':
        return orders
            .where((order) => order.status.value == 'Approved')
            .toList();
      case 'Delivered':
        return orders
            .where((order) => order.status.value == 'Delivered')
            .toList();
      case 'Cancelled':
        return orders
            .where((order) => order.status.value == 'Cancelled')
            .toList();
      default:
        return orders;
    }
  }

  List<ProductModel> _applyOrderSearchFilter(
      List<ProductModel> orders, String query) {
    if (query.isEmpty) return orders;

    final lowercaseQuery = query.toLowerCase();
    return orders
        .where((order) =>
            order.orderId.value.toLowerCase().contains(lowercaseQuery) ||
            order.productName.value.toLowerCase().contains(lowercaseQuery) ||
            order.supplierName.value.toLowerCase().contains(lowercaseQuery) ||
            order.category.value.toLowerCase().contains(lowercaseQuery) ||
            order.brand.value.toLowerCase().contains(lowercaseQuery) ||
            order.model.value.toLowerCase().contains(lowercaseQuery))
        .toList();
  }

  List<ProductModel> _applyOrderFilters(
      List<ProductModel> orders, String searchQuery, String statusFilter) {
    var filtered = _applyOrderStatusFilter(orders, statusFilter);
    return _applyOrderSearchFilter(filtered, searchQuery);
  }

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================

  int getProductCountByCategory(String category) {
    final currentState = state;
    if (currentState is! ProductLoaded) return 0;

    switch (category) {
      case 'Assets':
        return currentState.products
            .where((p) => p.status.value == 'Assets')
            .length;
      case 'Consumables':
        return currentState.products
            .where((p) => p.status.value == 'Consumable')
            .length;
      case 'Orders':
        return currentState.products
            .where((p) => p.orderDate.value.isNotEmpty)
            .length;
      case 'Suppliers':
        return currentState.products
            .where((p) => p.supplierName.value.isNotEmpty)
            .length;
      case 'Storage Locations':
        return currentState.products
            .where((p) => p.storageLocation.value.isNotEmpty)
            .length;
      default:
        return currentState.products.length;
    }
  }

  int getOrderCountByCategory(String category) {
    final currentState = state;
    if (currentState is! OrderLoaded) return 0;

    switch (category) {
      case 'Pending':
        return currentState.orders
            .where((o) => o.status.value == 'Pending')
            .length;
      case 'Approved':
        return currentState.orders
            .where((o) => o.status.value == 'Approved')
            .length;
      case 'Processing':
        return currentState.orders
            .where((o) => o.status.value == 'Processing')
            .length;
      case 'Delivered':
        return currentState.orders
            .where((o) => o.status.value == 'Delivered')
            .length;
      case 'Cancelled':
        return currentState.orders
            .where((o) => o.status.value == 'Cancelled')
            .length;
      default:
        return currentState.orders.length;
    }
  }

  // ============================================================================
  // SUPPLIER METHODS
  // ============================================================================

  // in ProductCubit ( history oder details )
  Future<void> loadSupplierById(String supplierId,
      {bool silent = false}) async {
    try {
      debugPrint("🔍 Loading supplier with ID: '$supplierId'");
      _watchedSupplierId = supplierId;
      if (!silent) emit(SupplierLoading());

      final supplier = await repository.getSupplierById(
        supplierId: supplierId,
        userEmail: InventoryPaths.userEmail,
      );

      if (supplier == null) {
        debugPrint("❌ Supplier not found for id: $supplierId");
        emit(SupplierError("Supplier not found for id: $supplierId"));
        return;
      }

      debugPrint("✅ Supplier loaded successfully: ${supplier.supplierName}");
      emit(SupplierLoaded(supplier: supplier));
      _live.watchPaths(<String>['Demo/${InventoryPaths.companyId}/supplier'],
          () {
        final id = _watchedSupplierId;
        if (id != null && state is SupplierLoaded) {
          loadSupplierById(id, silent: true);
        }
      });
    } catch (e) {
      debugPrint("❌ Error in loadSupplierById: $e");
      if (silent) return;
      emit(SupplierError("Failed to load supplier: ${e.toString()}"));
    }
  }

  // (supplier view details)
  Future<void> loadOrdersForSupplier(String supplierId,
      {bool silent = false}) async {
    try {
      debugPrint("🔍 Loading orders for supplier: $supplierId");
      _watchedOrdersSupplierId = supplierId;
      if (!silent) emit(OrderLoading());

      // Load all orders first
      final allOrders = await repository.getOrders();

      // Filter orders by supplier ID
      final supplierOrders = allOrders.where((order) {
        final orderSupplierId = order.supplierId.value;
        debugPrint(
            "🔍 Checking order ${order.orderId.value}: supplierId = '$orderSupplierId'");
        return orderSupplierId == supplierId;
      }).toList();

      debugPrint(
          "✅ Found ${supplierOrders.length} orders for supplier $supplierId");

      final current = state;
      if (silent && current is OrderLoaded) {
        emit(current.copyWith(
            orders: supplierOrders, filteredOrders: supplierOrders));
      } else {
        emit(OrderLoaded(
          orders: supplierOrders,
          filteredOrders: supplierOrders,
          selectedFilter: 'Orders',
          searchQuery: '',
          statusFilter: 'all',
        ));
      }
      _live.watchPaths(<String>['Demo/${InventoryPaths.companyId}/order'], () {
        final id = _watchedOrdersSupplierId;
        if (id != null && state is OrderLoaded) {
          loadOrdersForSupplier(id, silent: true);
        }
      });
    } catch (e) {
      debugPrint("❌ Error in loadOrdersForSupplier: $e");
      if (silent) return;
      emit(OrderError("Failed to load supplier orders: ${e.toString()}"));
    }
  }

  // Helper method to get supplier data for a specific product

  @override
  Future<void> close() {
    _live.dispose();
    return super.close();
  }
}
