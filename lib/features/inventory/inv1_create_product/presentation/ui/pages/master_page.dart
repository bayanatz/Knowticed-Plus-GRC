import 'package:knowticed_plus/core/custom/feedback/custom_empty_state.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_sizing.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:knowticed_plus/core/app_services/firebase/live_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/features/inventory/domain/models/storage_location_model.dart';
import 'package:knowticed_plus/features/inventory/domain/models/supplier_model.dart';
import 'package:knowticed_plus/features/inventory/domain/models/product_model.dart';
import 'package:knowticed_plus/features/inventory/inv1_create_product/presentation/ui/widgets/master_page/export.dart';
import 'package:knowticed_plus/features/inventory/inv1_create_product/presentation/ui/widgets/master_page/filter.dart';
import 'package:knowticed_plus/features/inventory/inv1_create_product/presentation/ui/widgets/master_page/table.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/inventory/presentation/controller/product_cubit.dart';
import 'package:knowticed_plus/features/inventory/inv10_supplier/presentation/ui/pages/add_new_supplier_toggle.dart';
import 'package:knowticed_plus/features/inventory/inv10_supplier/presentation/ui/pages/supplier_view_details.dart';
import 'package:knowticed_plus/features/inventory/inv11_storage_location/presentation/ui/pages/add_new_storage_location_toggle.dart';
import 'package:knowticed_plus/features/inventory/inv11_storage_location/presentation/ui/pages/view_storage_location_details_toggle.dart';
import 'package:knowticed_plus/features/inventory/inv2_view_product/presentation/ui/pages/product_details_toggle.dart';
import 'package:knowticed_plus/features/inventory/inv4_product_request/presentation/ui/pages/p15_product_request_toogel.dart';
import 'package:knowticed_plus/features/inventory/inv5_employee/presentation/ui/pages/p21_employee_toogel.dart';
import 'package:knowticed_plus/features/inventory/inv6_approval/presentation/ui/pages/p26_approvals_toogel.dart';
import 'package:knowticed_plus/features/inventory/inv7_dashboard/presentation/ui/pages/p7_dashboard_toogel.dart';
import 'package:knowticed_plus/features/inventory/inv8_assets_and_consumables/presentation/ui/pages/p28_assets_details_toogel.dart';
import 'package:knowticed_plus/features/inventory/inv8_assets_and_consumables/presentation/ui/pages/p29_assets_details_name_toogel.dart';
import 'package:knowticed_plus/features/inventory/inv9_order/presentation/ui/pages/add_new_order_toggle.dart';
import 'package:knowticed_plus/features/inventory/inv9_order/presentation/ui/pages/order_details.dart';
import 'package:knowticed_plus/features/inventory/inv1_create_product/presentation/ui/pages/select_order_toggle.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_navigate.dart';
import 'package:knowticed_plus/core/custom/layout/cross_axis_count_helper.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/custom/dialogs/custom_pop_up.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_search_widget_custom.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:knowticed_plus/features/inventory/helpers/inventory_paths.dart';

// Import your existing models (make sure paths are correct)
// import 'your_supplier_model.dart'; // Replace with actual path
// import 'your_storage_location_model.dart'; // Replace with actual path

class InventoryManagementDesktopScreen extends StatefulWidget {
  final String? initialSelectedLabel; // Made optional with nullable type
  const InventoryManagementDesktopScreen({
    super.key,
    this.initialSelectedLabel,
  });

  @override
  State<InventoryManagementDesktopScreen> createState() =>
      _InventoryManagementDesktopScreenState();
}

class _InventoryManagementDesktopScreenState
    extends State<InventoryManagementDesktopScreen> {
  /////////////////////////////// Variables /////////////////////////////////////

  final TextEditingController _searchController = TextEditingController();
  bool isGridViewChoose = true;
  String selectedLabel = "Products"; // Default selected chip
  String selectFilterProduct = "all"; // Default selected chip
  String selectOrderStatus = "all"; // default

  // Firebase variables for supplier and storage location data
  List<SupplierModel> suppliers = [];
  List<StorageLocation> storageLocations = [];
  bool isLoadingSuppliers = false;
  bool isLoadingStorageLocations = false;
  String supplierError = '';
  String storageLocationError = '';
  List<ProductModel> orders = [];
  List<ProductModel> filteredOrders = [];
  bool isLoadingOrders = false;
  String orderError = '';
  Map<String, dynamic> currentFilters = {};
  List<SupplierModel> filteredSuppliers = [];
  List<StorageLocation> filteredStorageLocations = [];

  // Firebase instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LiveRefresh _live = LiveRefresh();

  List<Map<String, dynamic>> drafts = [];
  bool isLoadingDrafts = false;
  String draftError = '';

  /////////////////////////////// Variables /////////////////////////////////////

  @override
  void initState() {
    super.initState();
    // Load products when screen initializes
    context.read<ProductCubit>().loadProducts();

    if (widget.initialSelectedLabel != null) {
      selectedLabel = widget.initialSelectedLabel!;
    }

    // Load all data when screen initializes
    _initializeAllData();

    // Add search listener
    _searchController.addListener(() {
      if (selectedLabel == "Orders") {
        _filterOrders(_searchController.text);
      } else if (selectedLabel == "Storage Locations") {
        _filterStorageLocations(); // Apply filtering when searching
      } else {
        context.read<ProductCubit>().searchProducts(_searchController.text);
      }
    });

    filteredSuppliers = suppliers;
    filteredStorageLocations = storageLocations;
  }

  @override
  void dispose() {
    _live.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initializeAllData() async {
    // Load products first
    context.read<ProductCubit>().loadProducts();

    // Load all other data simultaneously
    try {
      await Future.wait([
        _loadOrders(),
        _loadSuppliers(),
        _loadStorageLocations(),
        _loadDrafts(), // Add this line
      ]);
    } catch (error) {
      // Handle any initialization errors
      debugPrint('Error initializing data: $error');
    }
    _watchData();
  }

  /// Keeps the lists live: any change under these collections reloads the
  /// matching list in place (no spinner). Products are watched by
  /// `ProductCubit` itself.
  void _watchData() {
    if (!mounted) return;
    final String base = 'Demo/${InventoryPaths.companyId}';
    void when(String path, Future<void> Function() reload) {
      _live.watchPaths(<String>[path], () {
        if (mounted) reload();
      });
    }

    when('$base/order', () => _loadOrders(silent: true));
    when('$base/supplier', () => _loadSuppliers(silent: true));
    when('$base/Storage Location', () => _loadStorageLocations(silent: true));
    when('$base/drafts', () => _loadDrafts(silent: true));
  }

  Future<void> _loadDrafts({bool silent = false}) async {
    if (!silent) {
      setState(() {
        isLoadingDrafts = true;
        draftError = '';
      });
    }

    try {
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("Demo")
          .doc(InventoryPaths.companyId)
          .collection("drafts")
          .orderBy('lastModified', descending: true)
          .get();

      debugPrint(
          "📄 Total draft documents found: ${querySnapshot.docs.length}");

      List<Map<String, dynamic>> loadedDrafts = [];

      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        try {
          Map<String, dynamic> draftData = doc.data() as Map<String, dynamic>;
          draftData['documentId'] = doc.id;
          loadedDrafts.add(draftData);
          debugPrint("📋 Draft loaded: ${doc.id}");
        } catch (e) {
          debugPrint("❌ Error processing draft ${doc.id}: $e");
        }
      }

      setState(() {
        drafts = loadedDrafts;
        isLoadingDrafts = false;
      });

      debugPrint("📊 Total drafts loaded: ${drafts.length}");
    } catch (e) {
      debugPrint("❌ Error loading drafts: $e");
      if (silent || !mounted) return;
      setState(() {
        draftError = 'Error loading drafts: $e';
        isLoadingDrafts = false;
      });
    }
  }

  // Firebase Methods for fetching data
  Future<void> _loadSuppliers({bool silent = false}) async {
    if (!silent) {
      setState(() {
        isLoadingSuppliers = true;
        supplierError = '';
      });
    }

    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection('Demo')
          .doc(InventoryPaths.companyId)
          .collection('supplier')
          .get();

      List<SupplierModel> loadedSuppliers = [];
      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        try {
          SupplierModel supplier = SupplierModel.fromJson(
            doc.data() as Map<String, dynamic>,
          );
          loadedSuppliers.add(supplier);
        } catch (e) {
          debugPrint('Error parsing supplier document ${doc.id}: $e');
        }
      }

      setState(() {
        suppliers = loadedSuppliers;
        isLoadingSuppliers = false;
        // Update filtered suppliers
        _filterSuppliers();
      });
    } catch (e) {
      if (silent || !mounted) return;
      setState(() {
        supplierError = 'Error loading suppliers: $e';
        isLoadingSuppliers = false;
      });
    }
  }

  Future<void> _loadStorageLocations({bool silent = false}) async {
    if (!silent) {
      setState(() {
        isLoadingStorageLocations = true;
        storageLocationError = '';
      });
    }

    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection('Demo')
          .doc(InventoryPaths.companyId)
          .collection('Storage Location')
          .get();

      List<StorageLocation> loadedStorageLocations = [];
      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        try {
          StorageLocation storageLocation = StorageLocation.fromJson(
            doc.data() as Map<String, dynamic>,
          );
          loadedStorageLocations.add(storageLocation);
        } catch (e) {
          debugPrint('Error parsing storage location document ${doc.id}: $e');
        }
      }

      setState(() {
        storageLocations = loadedStorageLocations;
        isLoadingStorageLocations = false;
        // Update filtered storage locations
        _filterStorageLocations();
      });
    } catch (e) {
      if (silent || !mounted) return;
      setState(() {
        storageLocationError = 'Error loading storage locations: $e';
        isLoadingStorageLocations = false;
      });
    }
  }

  ////////////////////// load order //////////////////////////
  Future<void> _loadOrders({bool silent = false}) async {
    if (!silent) {
      setState(() {
        isLoadingOrders = true;
        orderError = '';
      });
    }

    try {
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
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

          // ADD THIS DEBUG PRINT
          if (doc.id == "OR107") {
            debugPrint("🔍 OR107 raw data: $orderData");
            debugPrint("🔍 OR107 products array: ${orderData['products']}");
            if (orderData['products'] != null) {
              debugPrint(
                "🔍 OR107 products length: ${(orderData['products'] as List).length}",
              );
            }
          }

          orderData['documentId'] = doc.id;
          if (!orderData.containsKey('orderId')) {
            orderData['orderId'] = doc.id;
          }

          if (orderData['products'] != null && orderData['products'] is List) {
            List<dynamic> productsData = orderData['products'];

            // ADD THIS DEBUG PRINT
            if (doc.id == "OR107") {
              debugPrint("🔍 OR107 processing ${productsData.length} products");
            }

            for (int i = 0; i < productsData.length; i++) {
              var productData = productsData[i];
              if (productData is Map<String, dynamic>) {
                try {
                  // Add order-level data to each product
                  productData['orderId'] = doc.id;

                  ProductModel product = ProductModel.fromJson(productData);
                  loadedOrders.add(product);

                  // ADD THIS DEBUG PRINT
                  if (doc.id == "OR107") {
                    debugPrint(
                      "📋 OR107 Product $i: ${product.productName.value} - ID: ${product.productId.value}",
                    );
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
      // ADD THIS DEBUG PRINT
      int or107Count =
          loadedOrders.where((p) => p.orderId.value == "OR107").length;
      debugPrint("🔍 OR107 products in loaded orders: $or107Count");

      setState(() {
        orders = loadedOrders;
        isLoadingOrders = false;
      });

      _applyOrderFilters();
    } catch (e) {
      debugPrint("❌ Error loading orders: $e");
      if (silent || !mounted) return;
      setState(() {
        orderError = 'Error loading orders: $e';
        isLoadingOrders = false;
      });
    }
  }

  List<ProductModel> _applyOrderStatusFilter(
    List<ProductModel> orderList,
    String statusFilter,
  ) {
    if (statusFilter == "all") return orderList;

    return orderList.where((order) {
      // Get the status value from the nested structure
      String orderStatus = order.status.value.toLowerCase();
      String filterStatus = statusFilter.toLowerCase();

      // Handle different status mappings
      switch (filterStatus) {
        case "open":
          return orderStatus == "open";
        case "received":
          return orderStatus == "received";
        case "partially_received":
          return orderStatus == "partially received" ||
              orderStatus == "partially_received";
        case "cancelled":
          return orderStatus == "cancelled" || orderStatus == "cancel";
        case "draft":
          return orderStatus == "draft";
        default:
          return orderStatus == filterStatus;
      }
    }).toList();
  }

  ////////////////////// load order //////////////////////////

  // Add this method to filter orders by search query
  void _filterOrders(String query) {
    setState(() {
      _applyOrderFilters(); // Use the combined filter method
    });
  }

  ///////////////////////////// Filter data ///////////////////////////
  void _applyFilters(Map<String, dynamic> filters) {
    setState(() {
      currentFilters = filters;
      _filterCurrentData();
    });
  }

  // Method to filter data based on selected category and filters
  void _filterCurrentData() {
    switch (selectedLabel) {
      case 'Suppliers':
        _filterSuppliers();
        break;
      case 'Products':
        _filterProducts();
        break;
      case 'Assets':
      case 'Consumables':
        _filterAssets();
        break;
      case 'Orders':
        _filterOrdersByFilters();
        break;
      case 'Storage Locations':
        _filterStorageLocations();
        break;
    }
  }

  void _filterSuppliers() {
    filteredSuppliers = suppliers.where((supplier) {
      bool matchesRank = currentFilters['supplierRank'] == null ||
          supplier.supplierRank == currentFilters['supplierRank'];

      bool matchesBusinessType = currentFilters['businessType'] == null ||
          supplier.businessType == currentFilters['businessType'];

      bool matchesDateRange = currentFilters['dateRange'] == null ||
          _isSupplierDateInRange(
            supplier.contractStartDate,
            currentFilters['dateRange'],
          );

      return matchesRank && matchesBusinessType && matchesDateRange;
    }).toList();
  }

  void _filterProducts() {
    if (currentFilters['productStatus'] != null) {
      context.read<ProductCubit>().filterProductsByStatus(
            currentFilters['productStatus'],
          );
    }
  }

  void _filterAssets() {
    if (currentFilters['assetStatus'] != null) {
      context.read<ProductCubit>().filterProductsByStatus(
            currentFilters['assetStatus'],
          );
    }
  }

  void _filterOrdersByFilters() {
    List<ProductModel> allOrders = orders;

    // Create unique orders for display (group by order ID)
    Map<String, ProductModel> uniqueOrdersMap = {};
    for (var order in allOrders) {
      if (!uniqueOrdersMap.containsKey(order.orderId.value)) {
        uniqueOrdersMap[order.orderId.value] = order;
      }
    }

    List<ProductModel> uniqueOrders = uniqueOrdersMap.values.toList();

    // Apply all filters
    filteredOrders = uniqueOrders.where((order) {
      // Order Status Filter (existing)
      bool matchesOrderStatus = true;
      if (currentFilters['orderStatus'] != null) {
        String orderStatus = order.status.value.toLowerCase();
        String filterStatus = currentFilters['orderStatus'].toLowerCase();

        switch (filterStatus) {
          case "open":
            matchesOrderStatus = orderStatus == "open";
            break;
          case "received":
            matchesOrderStatus = orderStatus == "received";
            break;
          case "partially_received":
            matchesOrderStatus = orderStatus == "partially received" ||
                orderStatus == "partially_received";
            break;
          case "cancelled":
            matchesOrderStatus =
                orderStatus == "cancelled" || orderStatus == "cancel";
            break;
          case "draft":
            matchesOrderStatus = orderStatus == "draft";
            break;
          default:
            matchesOrderStatus = orderStatus == filterStatus;
        }
      }

      // Supplier Name Filter
      bool matchesSupplierName = currentFilters['supplierName'] == null ||
          order.supplierName.value == currentFilters['supplierName'];

      // Order Date Range Filter
      bool matchesDateRange = currentFilters['dateRange'] == null ||
          _isOrderDateInRange(
            order.orderDate.timestamp,
            currentFilters['dateRange'],
          );

      return matchesOrderStatus && matchesSupplierName && matchesDateRange;
    }).toList();

    // Also apply current status filter and search if they exist
    if (selectOrderStatus != "all") {
      filteredOrders = _applyOrderStatusFilter(
        filteredOrders,
        selectOrderStatus,
      );
    }

    // Apply search filter
    if (_searchController.text.isNotEmpty) {
      final lowercaseQuery = _searchController.text.toLowerCase();
      filteredOrders = filteredOrders
          .where(
            (order) =>
                order.orderId.value.toLowerCase().contains(
                      lowercaseQuery,
                    ) ||
                order.productName.value.toLowerCase().contains(
                      lowercaseQuery,
                    ) ||
                order.supplierName.value.toLowerCase().contains(
                      lowercaseQuery,
                    ),
          )
          .toList();
    }
  }

  bool _isOrderDateInRange(DateTime date, DateTimeRange range) {
    try {
      return date.isAfter(range.start.subtract(Duration(days: 1))) &&
          date.isBefore(range.end.add(Duration(days: 1)));
    } catch (e) {
      return false;
    }
  }

  void _filterStorageLocations() {
    filteredStorageLocations = storageLocations.where((location) {
      // Apply status filter based on selectFilterProduct
      bool matchesStatus = true;
      if (selectFilterProduct != "all") {
        String locationStatus = location.status.value.toLowerCase();
        if (selectFilterProduct == "active") {
          matchesStatus = locationStatus == "active";
        } else if (selectFilterProduct == "inactive") {
          matchesStatus = locationStatus == "inactive";
        }
      }

      // Apply search filter
      bool matchesSearch = true;
      if (_searchController.text.isNotEmpty) {
        final query = _searchController.text.toLowerCase();
        matchesSearch = location.name.value.toLowerCase().contains(query) ||
            location.id.value.toLowerCase().contains(query) ||
            location.assignedDepartment.value.toLowerCase().contains(query);
      }

      // Apply filter dialog filters
      bool matchesAssignedLocation =
          currentFilters['assignedLocation'] == null ||
              location.assignedDepartment.value ==
                  currentFilters['assignedLocation'];

      bool matchesAccessLevel = currentFilters['accessLevel'] == null ||
          location.accessLevel.value == currentFilters['accessLevel'];

      // You'll need to add these properties to your StorageLocation model if they don't exist
      bool matchesEquipmentAvailability =
          currentFilters['equipmentAvailability'] == null ||
              (location.equipmentAvailable.value) ==
                  currentFilters['equipmentAvailability'];

      bool matchesConditionStorage =
          currentFilters['conditionStorage'] == null ||
              (location.conditionOfStorage.value) ==
                  currentFilters['conditionStorage'];

      bool matchesDateRange = currentFilters['dateRange'] == null ||
          _isStorageLocationDateInRange(
            location.dateAdded.value,
            currentFilters['dateRange'],
          );

      return matchesStatus &&
          matchesSearch &&
          matchesAssignedLocation &&
          matchesAccessLevel &&
          matchesEquipmentAvailability &&
          matchesConditionStorage &&
          matchesDateRange;
    }).toList();
  }

  bool _isSupplierDateInRange(String dateString, DateTimeRange range) {
    try {
      List<String> parts = dateString.split('-');
      if (parts.length == 3) {
        int day = int.parse(parts[0]);
        int month = int.parse(parts[1]);
        int year = int.parse(parts[2]);
        DateTime date = DateTime(year, month, day);

        return date.isAfter(range.start.subtract(Duration(days: 1))) &&
            date.isBefore(range.end.add(Duration(days: 1)));
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  bool _isStorageLocationDateInRange(DateTime date, DateTimeRange range) {
    try {
      return date.isAfter(range.start.subtract(Duration(days: 1))) &&
          date.isBefore(range.end.add(Duration(days: 1)));
    } catch (e) {
      return false;
    }
  }
  ///////////////////////////// Filter data ///////////////////////////

  @override
  Widget build(BuildContext context) {
    Localizations.localeOf(context).languageCode == 'ar';
    final isMobile = context.isPhone;
    return SafeArea(
      child: Scaffold(
        body: isMobile
            ? Padding(padding: EdgeInsets.all(15.sp), child: _buildScreen())
            : SideFrameMasterServices(
                titleText: S.of(context).inventoryManagement,
                child: _buildScreen(),
              ),
      ),
    );
  }

  List<Map<String, String>> _getAvailableSuppliers() {
    if (suppliers.isEmpty) {
      return [];
    }

    return suppliers
        .map(
          (supplier) => {
            "key": supplier.supplierName,
            "value": supplier.supplierName,
          },
        )
        .toList();
  }

  Widget _buildFilterButton() {
    final isTablet = context.isTablet;
    final isLandscape = context.isLandscape;

    // Check if any filters are active
    final bool hasActiveFilters = currentFilters.values.any(
      (value) => value != null,
    );

    return customButtonWithSvg(
      title: !isTablet && !isLandscape ? "" : S.of(context).filter,
      function: () async {
        await showAppDialog(
          context: context,
          barrierDismissible: true,
          builder: (_) => InventoryFilterDialog(
            selectedCategory: selectedLabel,
            onApplyFilters: _applyFilters,
            currentFilters: currentFilters,
            orders: selectedLabel == "Orders" ? orders : null,
            availableSuppliers: _getAvailableSuppliers(),
          ),
        );
      },
      // 22/10/2026 — Owner: toolbar text is 14 in every module (was 16).
      textStyle: StyleText.fontSize14Weight500.copyWith(
        // Change text color based on filter state
        color:
            hasActiveFilters ? AppColors.textButton : AppColors.secondaryText,
      ),
      // Compact like Figma: 100 × 38 with text, 38 × 38 icon-only.
      fixedWidth: !isTablet && !isLandscape ? 38.sp : 100.sp,
      fixedHeight: 38.sp,
      space: 8.sp,
      radius: 8.r,
      // Change icon color based on filter state
      svgColor:
          hasActiveFilters ? AppColors.textButton : AppColors.secondaryText,
      // Change background color based on filter state
      color: hasActiveFilters ? AppColors.primary : AppColors.card,
      image: "assets/icons_assets/main_icons_assets/ic_action_filter.svg",
      widthImage: 20.sp,
      heightImage: 20.sp,
      colorBorder: Colors.transparent,
    );
  }

  //////////////////////////////// Build App Content ///////////////////////////////

  Widget _buildScreen() {
    Localizations.localeOf(context).languageCode == 'ar';
    final isTablet = context.isTablet;
    final isMobile = context.isPhone;
    final isLandscape = context.isLandscape;

    return SingleChildScrollView(
      child: Column(
        children: [
          isMobile ? SizedBox(height: 15.sp) : SizedBox(),
          isMobile
              ? Row(
                  children: [
                    Text(
                      S.of(context).inventory,
                      style: StyleText.fontSize24Weight600.copyWith(
                        color: AppColors.blackButton,
                      ),
                    ),
                  ],
                )
              : Container(),

          isMobile ? SizedBox(height: 15.sp) : SizedBox(),
          // Approvals in Vertical
          isTablet && !isLandscape
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    customButton(
                      title: S.of(context).approvals,
                      function: () {
                        navigateTo(context, ApprovalsSection());
                      },
                      color: AppColors.primary,
                      height: 38.sp,
                      width: 135.sp,
                      // 22/10/2026 — Owner: toolbar / header buttons are 14 medium (500).
                      textStyle: StyleText.fontSize14Weight500.copyWith(
                        color: AppColors.textButton,
                      ),
                      radius: 8.r,
                    ),
                  ],
                )
              : SizedBox(),
          // Size in Vertical
          isTablet && !isLandscape ? SizedBox(height: 15.sp) : Container(),
          // 4 and 3 Button ( Product Requests  & Employees & Approvals & Dashboard )
          isTablet && !isLandscape
              ? Row(
                  children: [
                    // Product Requests
                    customButton(
                      title: S.of(context).productRequests,
                      function: () {
                        navigateTo(context, ProductRequest());
                      },
                      color: AppColors.primary,
                      height: 38.sp,
                      wrapContent:
                          true, // hug the text so "Product Requests" stays on one line
                      // 22/10/2026 — Owner: toolbar / header buttons are 14 medium (500).
                      textStyle: StyleText.fontSize14Weight500.copyWith(
                        color: AppColors.textButton,
                      ),
                      radius: 8.r,
                    ),
                    const Spacer(),

                    // Employees
                    customButton(
                      title: S.of(context).employees,
                      function: () {
                        navigateTo(context, EmployeeSection());
                      },
                      color: AppColors.primary,
                      height: 38.sp,
                      width: 135.sp,
                      // 22/10/2026 — Owner: toolbar / header buttons are 14 medium (500).
                      textStyle: StyleText.fontSize14Weight500.copyWith(
                        color: AppColors.textButton,
                      ),
                      radius: 8.r,
                    ),
                    //space
                    SizedBox(width: 15.sp),
                    // Dashboard
                    customButton(
                      title: S.of(context).dashboard,
                      function: () {
                        navigateTo(context, DashboardSection());
                      },
                      color: AppColors.primary,
                      height: 38.sp,
                      width: 135.sp,
                      // 22/10/2026 — Owner: toolbar / header buttons are 14 medium (500).
                      textStyle: StyleText.fontSize14Weight500.copyWith(
                        color: AppColors.textButton,
                      ),
                      radius: 8.r,
                    ),
                  ],
                )
              :
              // Mobile
              isMobile
                  // FIXED 16/10/2026 (merge check): the four buttons had three
                  // different widths (one hugged its text). Now an even 2 × 2.
                  ? Column(
                      children: [
                        Row(
                          spacing: 8.sp,
                          children: [
                            Expanded(
                                child: customButton(
                              title: S.of(context).productRequests,
                              function: () {
                                navigateTo(context, ProductRequest());
                              },
                              color: AppColors.primary,
                              height: 38.sp,
                              fullWidth: true,
                              // 22/10/2026 — Owner: toolbar / header buttons are 14 medium (500).
                              textStyle: StyleText.fontSize14Weight500.copyWith(
                                color: AppColors.textButton,
                              ),
                              radius: 8.r,
                            )),
                            Expanded(
                                child: customButton(
                              title: S.of(context).approvals,
                              function: () {
                                navigateTo(context, ApprovalsSection());
                              },
                              color: AppColors.primary,
                              height: 38.sp,
                              fullWidth: true,
                              // 22/10/2026 — Owner: toolbar / header buttons are 14 medium (500).
                              textStyle: StyleText.fontSize14Weight500.copyWith(
                                color: AppColors.textButton,
                              ),
                              radius: 8.r,
                            )),
                          ],
                        ),
                        SizedBox(height: 8.sp),
                        Row(
                          spacing: 8.sp,
                          children: [
                            Expanded(
                                child: customButton(
                              title: S.of(context).employees,
                              function: () {
                                navigateTo(context, EmployeeSection());
                              },
                              color: AppColors.primary,
                              height: 38.sp,
                              fullWidth: true,
                              // 22/10/2026 — Owner: toolbar / header buttons are 14 medium (500).
                              textStyle: StyleText.fontSize14Weight500.copyWith(
                                color: AppColors.textButton,
                              ),
                              radius: 8.r,
                            )),
                            Expanded(
                                child: customButton(
                              title: S.of(context).dashboard,
                              function: () {
                                navigateTo(context, DashboardSection());
                              },
                              color: AppColors.primary,
                              height: 38.sp,
                              fullWidth: true,
                              // 22/10/2026 — Owner: toolbar / header buttons are 14 medium (500).
                              textStyle: StyleText.fontSize14Weight500.copyWith(
                                color: AppColors.textButton,
                              ),
                              radius: 8.r,
                            )),
                          ],
                        ),
                      ],
                    )
                  // horizontal view
                  : Row(
                      children: [
                        // Product Requests
                        customButton(
                          title: S.of(context).productRequests,
                          function: () {
                            navigateTo(context, ProductRequest());
                          },
                          color: AppColors.primary,
                          height: 38.sp,
                          wrapContent:
                              true, // hug the text so "Product Requests" stays on one line
                          // 22/10/2026 — Owner: toolbar / header buttons are 14 medium (500).
                          textStyle: StyleText.fontSize14Weight500.copyWith(
                            color: AppColors.textButton,
                          ),
                          radius: 8.r,
                        ),
                        const Spacer(),

                        // Employees
                        customButton(
                          title: S.of(context).employees,
                          function: () {
                            navigateTo(context, EmployeeSection());
                          },
                          color: AppColors.primary,
                          height: 38.sp,
                          width: 135.sp,
                          // 22/10/2026 — Owner: toolbar / header buttons are 14 medium (500).
                          textStyle: StyleText.fontSize14Weight500.copyWith(
                            color: AppColors.textButton,
                          ),
                          radius: 8.r,
                        ),
                        //space
                        SizedBox(width: 15.sp),
                        // Approvals
                        customButton(
                          title: S.of(context).approvals,
                          function: () {
                            navigateTo(context, ApprovalsSection());
                          },
                          color: AppColors.primary,
                          height: 38.sp,
                          width: 135.sp,
                          // 22/10/2026 — Owner: toolbar / header buttons are 14 medium (500).
                          textStyle: StyleText.fontSize14Weight500.copyWith(
                            color: AppColors.textButton,
                          ),
                          radius: 8.r,
                        ),
                        //space
                        SizedBox(width: 15.sp),
                        // Dashboard
                        customButton(
                          title: S.of(context).dashboard,
                          function: () {
                            navigateTo(context, DashboardSection());
                          },
                          color: AppColors.primary,
                          height: 38.sp,
                          width: 135.sp,
                          // 22/10/2026 — Owner: toolbar / header buttons are 14 medium (500).
                          textStyle: StyleText.fontSize14Weight500.copyWith(
                            color: AppColors.textButton,
                          ),
                          radius: 8.r,
                        ),
                      ],
                    ),
          // space
          SizedBox(height: 25.sp),
          // Filter Widget
          filterSection(context),

          // space
          SizedBox(height: 15.sp),

          // selectedLabel == "Orders"
          //     ?
          // // permissions & Requests
          // Row(
          //   children: [
          //     // permissions
          //     customButton(
          //       title: S
          //           .of(context)
          //           .permissions,
          //       function: () {
          //         navigateTo(context, widget);
          //       },
          //       color: AppColors.primary,
          //       height: 38.sp,
          //       width: 135.sp,
          //       textStyle: StyleText.fontSize16Weight500.copyWith(
          //         color: AppColors.textButton,
          //       ),
          //       radius: 8.r,
          //     ),
          //
          //     Spacer(),
          //
          //     // Requests
          //     customButton(
          //       title: S
          //           .of(context)
          //           .requests,
          //       function: () {
          //         navigateTo(context, widget);
          //       },
          //       color: AppColors.primary,
          //       height: 38.sp,
          //       width: 135.sp,
          //       textStyle: StyleText.fontSize16Weight500.copyWith(
          //         color: AppColors.textButton,
          //       ),
          //       radius: 8.r,
          //     ),
          //   ],
          // )
          //     : Container(),

          // space
          // SizedBox(height: 15.sp),

          // Search and filter and Add Product
          Row(
            children: [
              AppSearchTextField(
                controller: _searchController,
                onChanged: (_) {},
              ),

              // space
              SizedBox(width: ButtonSizing.toolbarGap(context)),

              // Filter
              _buildFilterButton(),
              // space
              SizedBox(width: ButtonSizing.toolbarGap(context)),

              // Add Order  &  Add Product
              selectedLabel == "Orders"
                  ?
                  //
                  CustomPopupMenuButton(
                      title: isMobile ? "" : S.of(context).orders,
                      iconPath:
                          "assets/icons_assets/main_icons_assets/ic_data_service_requests.svg",
                      width: isMobile ? 38.w : 130.w,
                      height: ButtonSizing.height,
                      backgroundColor: AppColors.primary,
                      iconColor: AppColors.textButton,
                      onSelected: (value) {
                        if (value == 'Existing Product') {
                          debugPrint("Existing Order");
                        } else if (value == 'New Product') {
                          navigateTo(context, AddNewOrderFirstToggle());
                          debugPrint("New Order");
                        }
                      },
                      options: [
                        PopupOption(
                          value: 'Existing Product',
                          label: S.of(context).existingProduct,
                        ),
                        PopupOption(
                          value: 'New Product',
                          label: S.of(context).newProduct,
                        ),
                      ],
                    )
                  :
                  // Add Product/Supplier/Storage Location
                  _buildAddButton(),
            ],
          ),

          // space
          SizedBox(height: 10.sp),
          //  Filter page and three icon (grid & table & bulk Upload)
          isMobile
              ? SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      selectedLabel == "Orders"
                          ? _buildOrderStatusFilters()
                          : _buildProductStatusFilters(),

                      isMobile ? SizedBox() : Spacer(),
                      // Export
                      GestureDetector(
                        onTap: () async {
                          debugPrint(
                            "🔍 Export button clicked for category: $selectedLabel",
                          );

                          // Prepare data based on selected category
                          List<ProductModel>? products;
                          List<ProductModel>? orders;
                          List<SupplierModel>? suppliers;
                          List<StorageLocation>? storageLocations;

                          switch (selectedLabel) {
                            case 'Products':
                            case 'Assets':
                            case 'Consumables':
                              final productState =
                                  context.read<ProductCubit>().state;
                              if (productState is ProductLoaded) {
                                products = productState.filteredProducts;
                                debugPrint(
                                  "📦 Products to export: ${products.length}",
                                );
                              } else {
                                debugPrint("❌ No product state loaded");
                              }
                              break;
                            case 'Orders':
                              orders = filteredOrders;
                              debugPrint(
                                  "📋 Orders to export: ${orders.length}");
                              break;
                            case 'Suppliers':
                              suppliers = this.suppliers;
                              debugPrint(
                                "🏢 Suppliers to export: ${suppliers.length}",
                              );
                              break;
                            case 'Storage Locations':
                              storageLocations = this.storageLocations;
                              debugPrint(
                                "📍 Storage locations to export: ${storageLocations.length}",
                              );
                              break;
                          }

                          debugPrint("🚀 Opening export dialog...");

                          try {
                            await showAppDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (_) => InventoryExportDialog(
                                selectedCategory: selectedLabel,
                                products: products,
                                orders: orders,
                                suppliers: suppliers,
                                storageLocations: storageLocations,
                              ),
                            );
                            debugPrint("✅ Dialog closed");
                          } catch (e) {
                            debugPrint("❌ Error showing dialog: $e");
                          }
                        },
                        child: customButtonWithSvg(
                          title: isLandscape ? S.of(context).export : "",
                          function: () async {
                            debugPrint(
                              "🔍 Export button clicked for category: $selectedLabel",
                            );

                            // Prepare data based on selected category
                            List<ProductModel>? products;
                            List<ProductModel>? orders;
                            List<SupplierModel>? suppliers;
                            List<StorageLocation>? storageLocations;

                            switch (selectedLabel) {
                              case 'Products':
                              case 'Assets':
                              case 'Consumables':
                                final productState =
                                    context.read<ProductCubit>().state;
                                if (productState is ProductLoaded) {
                                  products = productState.filteredProducts;
                                  debugPrint(
                                    "📦 Products to export: ${products.length}",
                                  );
                                } else {
                                  debugPrint("❌ No product state loaded");
                                }
                                break;
                              case 'Orders':
                                orders = filteredOrders;
                                debugPrint(
                                    "📋 Orders to export: ${orders.length}");
                                break;
                              case 'Suppliers':
                                suppliers = this.suppliers;
                                debugPrint(
                                  "🏢 Suppliers to export: ${suppliers.length}",
                                );
                                break;
                              case 'Storage Locations':
                                storageLocations = this.storageLocations;
                                debugPrint(
                                  "📍 Storage locations to export: ${storageLocations.length}",
                                );
                                break;
                            }

                            debugPrint("🚀 Opening export dialog...");

                            try {
                              await showAppDialog(
                                context: context,
                                barrierDismissible: true,
                                builder: (_) => InventoryExportDialog(
                                  selectedCategory: selectedLabel,
                                  products: products,
                                  orders: orders,
                                  suppliers: suppliers,
                                  storageLocations: storageLocations,
                                ),
                              );
                              debugPrint("✅ Dialog closed");
                            } catch (e) {
                              debugPrint("❌ Error showing dialog: $e");
                            }
                          },
                          // 22/10/2026 — Owner: toolbar text is 14 in every module (was 16).
                          textStyle: StyleText.fontSize14Weight500.copyWith(
                            color: AppColors.textButton,
                          ),
                          fixedWidth: isLandscape ? 100.sp : 38.sp,
                          fixedHeight: 38.sp,
                          space: 8.sp,
                          radius: 8.r,
                          svgColor: AppColors.textButton,
                          color: AppColors.primary,
                          image:
                              "assets/icons_assets/main_icons_assets/ic_action_export.svg",
                          widthImage: 24.sp,
                          heightImage: 24.sp,
                          colorBorder: Colors.transparent,
                        ),
                      ),

                      isMobile ? SizedBox() : SizedBox(width: 18.sp),

                      // Table View
                      isMobile
                          ? SizedBox()
                          : GestureDetector(
                              onTap: () => setState(() =>
                                  isGridViewChoose = withLowHaptic(false)),
                              child: Container(
                                width: 38.sp,
                                height: 38.sp,
                                decoration: BoxDecoration(
                                  color: !isGridViewChoose
                                      ? AppColors.primary // selected background
                                      : AppColors.card,
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: CustomSvgImage.natural(
                                  assetPath:
                                      "assets/icons_assets/main_icons_assets/ic_list_lines.svg",
                                  width: 20.sp,
                                  height: 20.sp,
                                  fit: BoxFit.scaleDown,
                                  semanticsLabel: 'Table View',
                                  color: !isGridViewChoose
                                      ? AppColors.textButton // selected icon
                                      : Theme.of(context).brightness ==
                                              Brightness.light
                                          ? Colors
                                              .black // unselected, light mode
                                          : Colors
                                              .white, // unselected, dark mode
                                ),
                              ),
                            ),

                      isMobile ? SizedBox() : SizedBox(width: 15.sp),

                      // Grid View
                      isMobile
                          ? SizedBox()
                          : GestureDetector(
                              onTap: () => setState(
                                  () => isGridViewChoose = withLowHaptic(true)),
                              child: Container(
                                width: 38.sp,
                                height: 38.sp,
                                decoration: BoxDecoration(
                                  color: isGridViewChoose
                                      ? AppColors.primary
                                      : AppColors.card,
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: CustomSvgImage.natural(
                                  assetPath:
                                      "assets/icons_assets/main_icons_assets/ic_nav_grid.svg",
                                  width: 20.sp,
                                  height: 20.sp,
                                  fit: BoxFit.scaleDown,
                                  semanticsLabel: 'Grid View',
                                  color: isGridViewChoose
                                      ? AppColors.textButton // selected icon
                                      : Theme.of(context).brightness ==
                                              Brightness.light
                                          ? Colors
                                              .black // unselected, light mode
                                          : Colors
                                              .white, // unselected, dark mode
                                ),
                              ),
                            ),
                    ],
                  ),
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    selectedLabel == "Orders"
                        ? _buildOrderStatusFilters()
                        : _buildProductStatusFilters(),

                    isMobile ? SizedBox() : Spacer(),
                    // Export
                    GestureDetector(
                      onTap: () async {
                        debugPrint(
                          "🔍 Export button clicked for category: $selectedLabel",
                        );

                        // Prepare data based on selected category
                        List<ProductModel>? products;
                        List<ProductModel>? orders;
                        List<SupplierModel>? suppliers;
                        List<StorageLocation>? storageLocations;

                        switch (selectedLabel) {
                          case 'Products':
                          case 'Assets':
                          case 'Consumables':
                            final productState =
                                context.read<ProductCubit>().state;
                            if (productState is ProductLoaded) {
                              products = productState.filteredProducts;
                              debugPrint(
                                  "📦 Products to export: ${products.length}");
                            } else {
                              debugPrint("❌ No product state loaded");
                            }
                            break;
                          case 'Orders':
                            orders = filteredOrders;
                            debugPrint("📋 Orders to export: ${orders.length}");
                            break;
                          case 'Suppliers':
                            suppliers = this.suppliers;
                            debugPrint(
                                "🏢 Suppliers to export: ${suppliers.length}");
                            break;
                          case 'Storage Locations':
                            storageLocations = this.storageLocations;
                            debugPrint(
                              "📍 Storage locations to export: ${storageLocations.length}",
                            );
                            break;
                        }

                        debugPrint("🚀 Opening export dialog...");

                        try {
                          await showAppDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => InventoryExportDialog(
                              selectedCategory: selectedLabel,
                              products: products,
                              orders: orders,
                              suppliers: suppliers,
                              storageLocations: storageLocations,
                            ),
                          );
                          debugPrint("✅ Dialog closed");
                        } catch (e) {
                          debugPrint("❌ Error showing dialog: $e");
                        }
                      },
                      child: customButtonWithSvg(
                        title: isLandscape ? S.of(context).export : "",
                        function: () async {
                          debugPrint(
                            "🔍 Export button clicked for category: $selectedLabel",
                          );

                          // Prepare data based on selected category
                          List<ProductModel>? products;
                          List<ProductModel>? orders;
                          List<SupplierModel>? suppliers;
                          List<StorageLocation>? storageLocations;

                          switch (selectedLabel) {
                            case 'Products':
                            case 'Assets':
                            case 'Consumables':
                              final productState =
                                  context.read<ProductCubit>().state;
                              if (productState is ProductLoaded) {
                                products = productState.filteredProducts;
                                debugPrint(
                                  "📦 Products to export: ${products.length}",
                                );
                              } else {
                                debugPrint("❌ No product state loaded");
                              }
                              break;
                            case 'Orders':
                              orders = filteredOrders;
                              debugPrint(
                                  "📋 Orders to export: ${orders.length}");
                              break;
                            case 'Suppliers':
                              suppliers = this.suppliers;
                              debugPrint(
                                "🏢 Suppliers to export: ${suppliers.length}",
                              );
                              break;
                            case 'Storage Locations':
                              storageLocations = this.storageLocations;
                              debugPrint(
                                "📍 Storage locations to export: ${storageLocations.length}",
                              );
                              break;
                          }

                          debugPrint("🚀 Opening export dialog...");

                          try {
                            await showAppDialog(
                              context: context,
                              barrierDismissible: true,
                              builder: (_) => InventoryExportDialog(
                                selectedCategory: selectedLabel,
                                products: products,
                                orders: orders,
                                suppliers: suppliers,
                                storageLocations: storageLocations,
                              ),
                            );
                            debugPrint("✅ Dialog closed");
                          } catch (e) {
                            debugPrint("❌ Error showing dialog: $e");
                          }
                        },
                        // 22/10/2026 — Owner: toolbar text is 14 in every module (was 16).
                        textStyle: StyleText.fontSize14Weight500.copyWith(
                          color: AppColors.textButton,
                        ),
                        fixedWidth: isLandscape ? 100.sp : 38.sp,
                        fixedHeight: 38.sp,
                        space: 8.sp,
                        radius: 8.r,
                        svgColor: AppColors.textButton,
                        color: AppColors.primary,
                        image:
                            "assets/icons_assets/main_icons_assets/ic_action_export.svg",
                        widthImage: 24.sp,
                        heightImage: 24.sp,
                        colorBorder: Colors.transparent,
                      ),
                    ),

                    isMobile ? SizedBox() : SizedBox(width: 18.sp),

                    // Table View
                    isMobile
                        ? SizedBox()
                        : GestureDetector(
                            onTap: () => setState(
                                () => isGridViewChoose = withLowHaptic(false)),
                            child: Container(
                              width: 38.sp,
                              height: 38.sp,
                              decoration: BoxDecoration(
                                color: !isGridViewChoose
                                    ? AppColors.primary // selected background
                                    : AppColors.card,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: CustomSvgImage.natural(
                                assetPath:
                                    "assets/icons_assets/main_icons_assets/ic_list_lines.svg",
                                width: 20.sp,
                                height: 20.sp,
                                fit: BoxFit.scaleDown,
                                semanticsLabel: 'Table View',
                                color: !isGridViewChoose
                                    ? AppColors.textButton // selected icon
                                    : Theme.of(context).brightness ==
                                            Brightness.light
                                        ? Colors.black // unselected, light mode
                                        : Colors.white, // unselected, dark mode
                              ),
                            ),
                          ),

                    isMobile ? SizedBox() : SizedBox(width: 15.sp),

                    // Grid View
                    isMobile
                        ? SizedBox()
                        : GestureDetector(
                            onTap: () => setState(
                                () => isGridViewChoose = withLowHaptic(true)),
                            child: Container(
                              width: 38.sp,
                              height: 38.sp,
                              decoration: BoxDecoration(
                                color: isGridViewChoose
                                    ? AppColors.primary
                                    : AppColors.card,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: CustomSvgImage.natural(
                                assetPath:
                                    "assets/icons_assets/main_icons_assets/ic_nav_grid.svg",
                                width: 20.sp,
                                height: 20.sp,
                                fit: BoxFit.scaleDown,
                                semanticsLabel: 'Grid View',
                                color: isGridViewChoose
                                    ? AppColors.textButton // selected icon
                                    : Theme.of(context).brightness ==
                                            Brightness.light
                                        ? Colors.black // unselected, light mode
                                        : Colors.white, // unselected, dark mode
                              ),
                            ),
                          ),
                  ],
                ),

          SizedBox(height: 19.sp),

          // GridView based on selected label
          BounceSwitcher(
            // Bounce when switching list <-> grid view.
            triggerValue: isGridViewChoose,
            child: _buildContentBasedOnSelection(),
          ),
        ],
      ),
    );
  }

  //////////////////////////////// Build App Content ///////////////////////////////

  /////////////////////////////// Main Filter //////////////////////////////////////
  Widget filterSection(BuildContext context) {
    return BlocBuilder<ProductCubit, ProductState>(
      builder: (context, state) {
        final Map<String, String> filterItems = {
          "Products": S.of(context).productN,
          "Assets": S.of(context).assets,
          "Consumables": S.of(context).consumables,
          "Orders": S.of(context).orders,
          "Suppliers": S.of(context).suppliers,
          "Storage Locations": S.of(context).storageLocations,
        };

        Set<String> uniqueOrderIds =
            orders.map((order) => order.orderId.value).toSet();

        // Include drafts in the Orders count
        Map<String, String> filterCounts = {
          "Orders": (uniqueOrderIds.length + drafts.length)
              .toString(), // Combined count
          "Suppliers": suppliers.length.toString(),
          "Storage Locations": storageLocations.length.toString(),
        };

        if (state is ProductLoaded) {
          filterCounts.addAll({
            "Products": state.products.length.toString(),
            "Assets": state.products
                .where((p) => p.status.value == 'Assets')
                .length
                .toString(),
            "Consumables": state.products
                .where((p) => p.status.value == 'Consumable')
                .length
                .toString(),
          });
        } else {
          filterCounts.addAll({
            "Products": "0",
            "Assets": "0",
            "Consumables": "0",
          });
        }

        // Wrap (not a horizontal scroll) so every category is always visible,
        // aligned to the start edge (left in English, right in Arabic) and
        // flowing onto a second line on narrow screens.
        return Align(
          alignment: AlignmentDirectional.centerStart,
          child: Wrap(
            alignment: WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 10.sp,
            children: filterItems.entries.map((entry) {
              final key = entry.key;
              final label = entry.value;
              final count = filterCounts[key] ?? "0";
              return _statusChip(count, key, label, context);
            }).toList(),
          ),
        );
      },
    );
  }

  // Update your _statusChip method to load orders when Orders is selected
  Widget _statusChip(
    String count,
    String key,
    String label,
    BuildContext context,
  ) {
    final isMobile = context.isPhone;
    bool isSelected = key == selectedLabel;
    bool isLight = Theme.of(context).brightness == Brightness.light;

    return GestureDetector(
      onTapDown: (_) => HapticController.low(),
      onTap: () {
        setState(() {
          selectedLabel = key;
          // Reset filter when switching categories
          selectFilterProduct = "all";
        });

        // Only filter data that's already loaded, don't reload
        if (key == 'Products' || key == 'Assets' || key == 'Consumables') {
          context.read<ProductCubit>().filterProductsByCategory(key);
        } else if (key == 'Storage Locations') {
          _filterStorageLocations(); // Apply initial filter
        }
        // For Orders, Suppliers, and Storage Locations, data is already loaded
        // so we don't need to call the load methods again
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: isMobile ? 35.sp : 45.sp,
            height: isMobile ? 35.sp : 45.sp,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary
                  : (isLight ? AppColors.white : AppColors.chatBackground),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Center(
              child: Text(
                count,
                // 22/10/2026 — Owner (phone): count chips match Notifications — box 35, number 14/400, label 14/600.
                style: (isMobile
                        ? StyleText.fontSize14Weight400
                        : StyleText.fontSize20Weight500)
                    .copyWith(
                  color: isSelected
                      ? AppColors.textButton
                      : isLight
                          ? AppColors.secondaryText
                          : AppColors.grey,
                ),
              ),
            ),
          ),
          SizedBox(width: 16.sp),
          Text(
            FormatHelper.capitalize(label),
            style: (isMobile
                    ? StyleText.fontSize14Weight600
                    : StyleText.fontSize16Weight600)
                .copyWith(
              color: isSelected
                  ? isLight
                      ? AppColors.blackButton
                      : AppColors.white
                  : (isLight ? AppColors.secondaryText : AppColors.grey),
            ),
          ),
          SizedBox(width: 30.sp),
        ],
      ),
    );
  }

  /////////////////////////////// Main Filter //////////////////////////////////////

  // New method to build add button based on selected label
  Widget _buildAddButton() {
    final isTablet = context.isTablet;
    final isLandscape = context.isLandscape;

    String buttonText = "";
    VoidCallback onPressed = () {};

    switch (selectedLabel) {
      case "Suppliers":
        buttonText = !isTablet && !isLandscape ? "" : S.of(context).addSupplier;
        onPressed = () {
          navigateTo(context, AddNewSupplierToggle());
          debugPrint("Add Supplier pressed");
        };
        break;
      case "Storage Locations":
        buttonText = !isTablet && !isLandscape ? "" : S.of(context).storage;
        onPressed = () {
          navigateTo(context, AddNewStorageToggle());
          debugPrint("Add Storage Location pressed");
        };
        break;
      default:
        buttonText = !isTablet && !isLandscape ? "" : S.of(context).productN;
        onPressed = () {
          navigateTo(context, SelectOrder());
        };
        break;
    }

    return customButtonWithSvg(
      title: buttonText,
      function: onPressed,
      // 22/10/2026 — Owner: toolbar text is 14 in every module (was 16).
      textStyle: StyleText.fontSize14Weight500.copyWith(
        color: AppColors.textButton,
      ),
      padding: EdgeInsets.symmetric(horizontal: 8.sp, vertical: 5.sp),
      height: ButtonSizing.height,
      space: 8.sp,
      radius: 8.r,
      color: AppColors.primary,
      svgColor: AppColors.textButton,
      image: selectedLabel == "Storage Locations"
          ? "assets/icons_assets/main_icons_assets/ic_action_plus.svg"
          : "assets/icons_assets/main_icons_assets/ic_data_inventory_products.svg",
      widthImage: 20.sp,
      heightImage: 20.sp,
      colorBorder: Colors.transparent,
    );
  }

  // Updated content builder method
  // Updated content builder method
  Widget _buildContentBasedOnSelection() {
    final locale = Localizations.localeOf(context).languageCode;

    switch (selectedLabel) {
      case 'Products':
        return BlocBuilder<ProductCubit, ProductState>(
          builder: (context, state) {
            if (isGridViewChoose) {
              return _buildProductsGridView(state);
            } else {
              // Table view for products
              if (state is ProductLoaded) {
                return ProductsTableWidget(
                  products: state.filteredProducts,
                  locale: locale,
                );
              } else if (state is ProductLoading) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(50.sp),
                    child:
                        CircleProgressMaster.inline(color: AppColors.primary),
                  ),
                );
              } else if (state is ProductError) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(50.sp),
                    child: Column(
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48.sp,
                          color: AppColors.red,
                        ),
                        SizedBox(height: 16.sp),
                        Text(
                          'Error: ${state.message}',
                          style: StyleText.fontSize16Weight400.copyWith(
                            color: Colors.red,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16.sp),
                        customButton(
                          title: S.of(context).retry,
                          function: () =>
                              context.read<ProductCubit>().loadProducts(),
                          wrapContent: true,
                        ),
                      ],
                    ),
                  ),
                );
              }
              return SizedBox();
            }
          },
        );

      case 'Assets':
      case 'Consumables':
        return BlocBuilder<ProductCubit, ProductState>(
          builder: (context, state) {
            if (isGridViewChoose) {
              return _buildAssetsGridView(state);
            } else {
              // Table view for assets/consumables
              if (state is ProductLoaded) {
                return AssetsTableWidget(
                  assets: state.filteredProducts,
                  locale: locale,
                );
              } else if (state is ProductLoading) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(50.sp),
                    child:
                        CircleProgressMaster.inline(color: AppColors.primary),
                  ),
                );
              } else if (state is ProductError) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(50.sp),
                    child: Column(
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48.sp,
                          color: AppColors.red,
                        ),
                        SizedBox(height: 16.sp),
                        Text(
                          'Error: ${state.message}',
                          style: StyleText.fontSize16Weight400.copyWith(
                            color: Colors.red,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16.sp),
                        customButton(
                          title: S.of(context).retry,
                          function: () =>
                              context.read<ProductCubit>().loadProducts(),
                          wrapContent: true,
                        ),
                      ],
                    ),
                  ),
                );
              }
              return SizedBox();
            }
          },
        );

      case 'Orders':
        if (isGridViewChoose) {
          return _buildOrdersPreview();
        } else {
          // Table view for orders
          if (isLoadingOrders) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(50.sp),
                child: CircleProgressMaster.inline(color: AppColors.primary),
              ),
            );
          }
          if (orderError.isNotEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(50.sp),
                child: Column(
                  children: [
                    Icon(Icons.error_outline,
                        size: 48.sp, color: AppColors.red),
                    SizedBox(height: 16.sp),
                    Text(
                      orderError,
                      style: StyleText.fontSize16Weight400.copyWith(
                        color: AppColors.red,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.sp),
                    customButton(
                      title: S.of(context).retry,
                      function: _loadOrders,
                      wrapContent: true,
                    ),
                  ],
                ),
              ),
            );
          }
          if (filteredOrders.isEmpty) {
            return Center(
              child: Column(
                children: [
                  CustomEmptyState(
                    lottiePath:
                        'assets/lottie_assets/main_lottie_assets/lot_empty_state.json',
                    size: 200,
                    verticalPadding: 0,
                  ),
                ],
              ),
            );
          }
          return OrderPreviewTableWidget(
            orders: filteredOrders,
            locale: locale,
          );
        }

      case 'Suppliers':
        if (isGridViewChoose) {
          return _buildSuppliersGridView();
        } else {
          // Table view for suppliers
          if (isLoadingSuppliers) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(50.sp),
                child: CircleProgressMaster.inline(color: AppColors.primary),
              ),
            );
          }
          if (supplierError.isNotEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(50.sp),
                child: Column(
                  children: [
                    Icon(Icons.error_outline,
                        size: 48.sp, color: AppColors.red),
                    SizedBox(height: 16.sp),
                    Text(
                      supplierError,
                      style: StyleText.fontSize16Weight400.copyWith(
                        color: AppColors.red,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.sp),
                    customButton(
                      title: S.of(context).retry,
                      function: _loadSuppliers,
                      wrapContent: true,
                    ),
                  ],
                ),
              ),
            );
          }
          if (suppliers.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(0.sp),
                child: Column(
                  children: [
                    CustomEmptyState(
                      lottiePath:
                          'assets/lottie_assets/main_lottie_assets/lot_empty_state.json',
                      size: 200,
                      verticalPadding: 0,
                    ),
                  ],
                ),
              ),
            );
          }
          return SuppliersTableWidget(suppliers: suppliers, locale: locale);
        }

      case 'Storage Locations':
        if (isGridViewChoose) {
          return _buildStorageLocationsGridView();
        } else {
          // Table view for storage locations
          if (isLoadingStorageLocations) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(50.sp),
                child: CircleProgressMaster.inline(color: AppColors.primary),
              ),
            );
          }
          if (storageLocationError.isNotEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(50.sp),
                child: Column(
                  children: [
                    Icon(Icons.error_outline,
                        size: 48.sp, color: AppColors.red),
                    SizedBox(height: 16.sp),
                    Text(
                      storageLocationError,
                      style: StyleText.fontSize16Weight400.copyWith(
                        color: AppColors.red,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.sp),
                    customButton(
                      title: S.of(context).retry,
                      function: _loadStorageLocations,
                      wrapContent: true,
                    ),
                  ],
                ),
              ),
            );
          }
          if (storageLocations.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(50.sp),
                child: Column(
                  children: [
                    CustomEmptyState(
                      lottiePath:
                          'assets/lottie_assets/main_lottie_assets/lot_empty_state.json',
                      size: 70,
                      verticalPadding: 0,
                    ),
                  ],
                ),
              ),
            );
          }
          return StorageLocationsTableWidget(
            storageLocations: filteredStorageLocations,
            locale: locale,
          );
        }

      default:
        return Center(child: Text(S.of(context).no));
    }
  }

  // New method to build suppliers grid view
  Widget _buildSuppliersGridView() {
    if (isLoadingSuppliers) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(50.sp),
          child: CircleProgressMaster.inline(color: AppColors.primary),
        ),
      );
    }

    if (supplierError.isNotEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(50.sp),
          child: Column(
            children: [
              Icon(Icons.error_outline, size: 48.sp, color: AppColors.red),
              SizedBox(height: 16.sp),
              Text(
                supplierError,
                style: StyleText.fontSize16Weight400.copyWith(
                  color: AppColors.red,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.sp),
              customButton(
                title: S.of(context).retry,
                function: _loadSuppliers,
                wrapContent: true,
              ),
            ],
          ),
        ),
      );
    }

    // Use filteredSuppliers instead of suppliers
    if (filteredSuppliers.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(0.sp),
          child: Column(
            children: [
              Center(
                child: Padding(
                  padding: EdgeInsets.all(0.sp),
                  child: Column(
                    children: [
                      CustomEmptyState(
                        lottiePath:
                            'assets/lottie_assets/main_lottie_assets/lot_empty_state.json',
                        size: 200,
                        verticalPadding: 0,
                      ),
                    ],
                  ),
                ),
              ),
              if (currentFilters.isNotEmpty) ...[
                SizedBox(height: 8.sp),
                customButton(
                  title: S.of(context).clearFilter,
                  function: () {
                    setState(() {
                      currentFilters.clear();
                      filteredSuppliers = suppliers;
                    });
                  },
                  color: AppColors.darkGrey,
                  textColor: AppColors.text,
                  wrapContent: true,
                  haptic: HapticController.low,
                ),
              ],
            ],
          ),
        ),
      );
    }

    // Equal-height rows instead of a fixed-extent grid: a card grows when a
    // value wraps (full text, no "…"), and every card in the row matches it.
    return _equalHeightGrid(
      count: filteredSuppliers.length,
      itemBuilder: (context, index) {
        final supplier = filteredSuppliers[index];
        return GestureDetector(
          onTap: () {
            navigateTo(context, ViewSupplierDetails(supplierModel: supplier));
            debugPrint("Supplier tapped: ${supplier.supplierName}");
          },
          child: _buildSupplierCard(supplier),
        );
      },
    );
  }

  // New method to build storage locations grid view
  Widget _buildStorageLocationsGridView() {
    if (isLoadingStorageLocations) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(50.sp),
          child: CircleProgressMaster.inline(color: AppColors.primary),
        ),
      );
    }

    if (storageLocationError.isNotEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(50.sp),
          child: Column(
            children: [
              Icon(Icons.error_outline, size: 48.sp, color: AppColors.red),
              SizedBox(height: 16.sp),
              Text(
                storageLocationError,
                style: StyleText.fontSize16Weight400.copyWith(
                  color: AppColors.red,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.sp),
              customButton(
                title: S.of(context).retry,
                function: _loadStorageLocations,
                wrapContent: true,
              ),
            ],
          ),
        ),
      );
    }

    // Use filteredStorageLocations instead of storageLocations
    if (filteredStorageLocations.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(0.sp),
          child: Column(
            children: [
              CustomEmptyState(
                lottiePath:
                    'assets/lottie_assets/main_lottie_assets/lot_empty_state.json',
                size: 200,
                verticalPadding: 0,
              ),
            ],
          ),
        ),
      );
    }

    // Equal-height rows instead of a fixed-extent grid: a card grows when a
    // value wraps (full text, no "…"), and every card in the row matches it.
    return _equalHeightGrid(
      count: filteredStorageLocations.length,
      itemBuilder: (context, index) {
        final storageLocation = filteredStorageLocations[index];
        return GestureDetector(
          onTap: () {
            HapticController.low(); // list row: on the tap (X-117)
            debugPrint("Storage Location tapped: ${storageLocation.name}");
          },
          child: _buildStorageLocationCard(storageLocation),
        );
      },
    );
  }

  // New method to build supplier card (using your SupplierModel)
  // Updated method to build supplier card (using flattened SupplierModel)

  /// Lays cards out in rows of [CrossAxisCountHelper] columns, 15 apart both
  /// ways. Each row is as tall as its tallest card, so long values
  /// wrap instead of being cut with "…".
  Widget _equalHeightGrid({
    required int count,
    required IndexedWidgetBuilder itemBuilder,
  }) {
    final int columns =
        CrossAxisCountHelper.getCrossAxisCountForDefaultTablet2(context);
    final rows = <Widget>[];
    for (int start = 0; start < count; start += columns) {
      final cells = <Widget>[];
      for (int c = 0; c < columns; c++) {
        if (c > 0) cells.add(SizedBox(width: 15.sp));
        final int i = start + c;
        cells.add(
          Expanded(
            child:
                i < count ? itemBuilder(context, i) : const SizedBox.shrink(),
          ),
        );
      }
      if (rows.isNotEmpty) rows.add(SizedBox(height: 15.sp));
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: cells,
          ),
        ),
      );
    }
    return Column(mainAxisSize: MainAxisSize.min, children: rows);
  }

  /// Supplier card — Figma 4031:28925 (289 × 101, radius 8, 10 in).
  ///
  /// Same frame as the storage location card: icon 30 beside "Supplier ID"
  /// (12) and "Business Type" (10); then "Name" and "Supplier Rank" (10);
  /// bottom row "Contract Start Date" / "Contract End Date" (8); "Added On"
  /// (8) in the top-end corner. Labels #797979, values #2D2D2D.
  Widget _buildSupplierCard(SupplierModel supplier) {
    final Color labelColor = AppColors.secondaryText;
    final Color valueColor = AppColors.blackButton;

    Widget line(String label, String value, TextStyle base) {
      return Text.rich(
        TextSpan(
          children: [
            TextSpan(text: '$label: ', style: base.copyWith(color: labelColor)),
            TextSpan(
              text: value.trim().isEmpty ? '-' : value,
              style: base.copyWith(color: valueColor),
            ),
          ],
        ),
      );
    }

    // Keeps a value on ONE line at full text: shrinks it slightly if needed
    // instead of wrapping or cutting with "…".
    Widget oneLine(Widget child) => FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.centerStart,
          // softWrap off so the card's measured height counts ONE line
          // (otherwise the row is sized for wrapped text and the card gets
          // extra empty space at the bottom).
          child: DefaultTextStyle.merge(
            softWrap: false,
            maxLines: 1,
            child: child,
          ),
        );

    final TextStyle s12 = StyleText.fontSize12Weight500.copyWith(height: 1.2);
    final TextStyle s10 = StyleText.fontSize10Weight500.copyWith(height: 1.2);
    final TextStyle s8 = StyleText.fontSize8Weight500.copyWith(height: 1.2);

    return Container(
      padding: EdgeInsets.all(10.sp),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 30.r,
                height: 30.r,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: CustomSvgImage(
                  assetPath:
                      'assets/icons_assets/inventory_assets/ic_file_folder_done.svg',
                  width: 20.r,
                  height: 20.r,
                  fit: BoxFit.scaleDown,
                  color: valueColor,
                ),
              ),
              SizedBox(width: 5.sp),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ID with "Added On" at the end; when both don't fit on
                    // one line the date drops below the ID instead of
                    // squeezing anything.
                    SizedBox(
                      // Full width: the date/status sits flush at the end, 10 from the
                      // card edge — the same inset as the top and bottom.
                      width: double.infinity,
                      child: Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8.sp,
                        runSpacing: 4.sp,
                        children: [
                          line(S.of(context).supplierID, supplier.supplierID,
                              s12),
                          line(
                            S.of(context).addedOn,
                            formatDate(supplier.addedOn),
                            s8,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8.sp),
                    // Full width and always ONE line (shrinks to fit).
                    oneLine(line(
                      S.of(context).businessType,
                      supplier.businessType,
                      s10,
                    )),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 8.sp),
          line(S.of(context).name, supplier.supplierName, s10),
          SizedBox(height: 7.sp),
          line(S.of(context).supplierRank, supplier.supplierRank, s10),
          SizedBox(height: 7.sp),
          // Both dates on ONE line: start date at the start, end date at
          // the end; each shrinks slightly instead of wrapping.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: oneLine(line(
                  S.of(context).contractStartDate,
                  _formatSupplierDate(supplier.contractStartDate),
                  s8,
                )),
              ),
              SizedBox(width: 8.sp),
              Flexible(
                child: oneLine(line(
                  S.of(context).contractEndDate,
                  _formatSupplierDate(supplier.contractEndDate),
                  s8,
                )),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String formatDate(dynamic date) {
    DateTime dt;

    if (date is String) {
      dt = DateTime.tryParse(date) ?? DateTime.now();
    } else if (date is Timestamp) {
      dt = date.toDate();
    } else if (date is DateTime) {
      dt = date;
    } else {
      return '';
    }

    return DateFormat("dd MMM yyyy").format(dt);
  }

  String _formatSupplierDate(String dateString) {
    if (dateString.isEmpty) return '-';

    debugPrint("Trying to format date: '$dateString'"); // Debug print

    try {
      // Handle the format "23-9-2025" (dd-M-yyyy)
      List<String> parts = dateString.split('-');
      if (parts.length == 3) {
        int day = int.parse(parts[0]);
        int month = int.parse(parts[1]);
        int year = int.parse(parts[2]);

        String formatted =
            "${day.toString().padLeft(2, '0')} ${_getMonthName(month)} $year";
        debugPrint("Formatted to: '$formatted'"); // Debug print
        return formatted;
      }

      // Fallback: try parsing as standard DateTime
      DateTime date = DateTime.parse(dateString);
      String formatted =
          "${date.day.toString().padLeft(2, '0')} ${_getMonthName(date.month)} ${date.year}";
      debugPrint("Formatted to: '$formatted'"); // Debug print
      return formatted;
    } catch (e) {
      debugPrint("Failed to parse date: $e"); // Debug print
      return dateString;
    }
  }

  // New method to build storage location card (using your StorageLocation model)
  // Update the _buildStorageLocationCard method in your main inventory screen

  // Replace your _buildStorageLocationCard method with this corrected version:

  /// Storage location card — Figma 4068:28540 (289 × 101, radius 8, 10 in).
  ///
  /// Icon 30 (#D0D0D0, radius 4) beside "Storage Location ID" (12) and
  /// "Country" (10); then "Name" and "Assigned Department" (10); the bottom
  /// row has "Storage Capacity" (8) at the start and "Access Level" (8) at the
  /// end; "Status" (8) sits in the top-end corner. Labels #797979, values
  /// #2D2D2D, Active #4BB609 / Inactive red.
  Widget _buildStorageLocationCard(StorageLocation storageLocation) {
    final lightMode = Theme.of(context).brightness == Brightness.light;
    final Color labelColor = AppColors.secondaryText;
    final Color valueColor = AppColors.blackButton;

    Widget line(String label, String value, TextStyle base, {Color? color}) {
      return Text.rich(
        TextSpan(
          children: [
            TextSpan(text: '$label: ', style: base.copyWith(color: labelColor)),
            TextSpan(
              text: value.trim().isEmpty ? '-' : value,
              style: base.copyWith(color: color ?? valueColor),
            ),
          ],
        ),
      );
    }

    // Keeps a value on ONE line at full text: shrinks it slightly if needed
    // instead of wrapping or cutting with "…".
    Widget oneLine(Widget child) => FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.centerStart,
          // softWrap off so the card's measured height counts ONE line
          // (otherwise the row is sized for wrapped text and the card gets
          // extra empty space at the bottom).
          child: DefaultTextStyle.merge(
            softWrap: false,
            maxLines: 1,
            child: child,
          ),
        );

    final String status = storageLocation.status.value.trim().toLowerCase();
    final bool inactive = status == 'inactive';
    final String capacity = [
      '${storageLocation.storageCapacity.value}',
      storageLocation.capacityUnit.value.trim(),
    ].where((e) => e.isNotEmpty).join(' ');

    final TextStyle s12 = StyleText.fontSize12Weight500.copyWith(height: 1.2);
    final TextStyle s10 = StyleText.fontSize10Weight500.copyWith(height: 1.2);
    final TextStyle s8 = StyleText.fontSize8Weight500.copyWith(height: 1.2);

    return GestureDetector(
      onTap: () {
        navigateTo(
          context,
          StorageLocationDetailsToggle(storageLocation: storageLocation),
        );
      },
      child: Container(
        padding: EdgeInsets.all(10.sp),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon + ID / Country, Status in the corner
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 30.r,
                  height: 30.r,
                  decoration: BoxDecoration(
                    color: lightMode
                        ? const Color(0xffD0D0D0)
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: CustomSvgImage(
                    assetPath:
                        'assets/icons_assets/main_icons_assets/ic_module_inventory.svg',
                    width: 20.r,
                    height: 20.r,
                    fit: BoxFit.scaleDown,
                    color: valueColor,
                  ),
                ),
                SizedBox(width: 5.sp),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ID with Status at the end; Status drops below the
                      // ID when both don't fit on one line.
                      SizedBox(
                        // Full width: the date/status sits flush at the end, 10 from the
                        // card edge — the same inset as the top and bottom.
                        width: double.infinity,
                        child: Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8.sp,
                          runSpacing: 4.sp,
                          children: [
                            line(
                              S.of(context).storageLocationID,
                              storageLocation.id.value,
                              s12,
                            ),
                            line(
                              S.of(context).status,
                              inactive
                                  ? S.of(context).inactive
                                  : S.of(context).active,
                              s8,
                              color: inactive
                                  ? Colors.red[700]
                                  : const Color(0xff4BB609),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8.sp),
                      oneLine(line(
                        S.of(context).country,
                        storageLocation.country.value,
                        s10,
                      )),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.sp),
            line(S.of(context).name, storageLocation.name.value, s10),
            SizedBox(height: 7.sp),
            line(
              S.of(context).assignedDepartment,
              storageLocation.assignedDepartment.value,
              s10,
            ),
            SizedBox(height: 7.sp),
            // Capacity (start) / Access level (end) on ONE line; each
            // shrinks slightly instead of wrapping.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: oneLine(line(
                    S.of(context).storageCapacity,
                    capacity,
                    s8,
                  )),
                ),
                SizedBox(width: 8.sp),
                Flexible(
                  child: oneLine(line(
                    S.of(context).accessLevel,
                    storageLocation.accessLevel.value,
                    s8,
                  )),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  } /////////////////////////////// Updated Product GridView ///////////////////////////////////

  Widget _buildProductStatusFilters() {
    // Hide filters for Suppliers only
    if (selectedLabel == "Suppliers") {
      return SizedBox(); // Return empty widget
    }

    // Storage Locations filters
    if (selectedLabel == "Storage Locations") {
      return Row(
        children: [
          GestureDetector(
            onTapDown: (_) => HapticController.low(),
            onTap: () {
              setState(() {
                selectFilterProduct = "all";
                _filterStorageLocations(); // Apply filter immediately
              });
            },
            child: filterProduct(
              context: context,
              label: S.of(context).all,
              isSelected: selectFilterProduct == "all",
              colorLabel: AppColors.textButton,
            ),
          ),
          SizedBox(width: 10.sp),
          GestureDetector(
            onTapDown: (_) => HapticController.low(),
            onTap: () {
              setState(() {
                selectFilterProduct = "active";
                _filterStorageLocations(); // Apply filter immediately
              });
            },
            child: filterProduct(
              context: context,
              label: S.of(context).active,
              isSelected: selectFilterProduct == "active",
              colorLabel: AppColors.lightGreen,
            ),
          ),
          SizedBox(width: 10.sp),
          GestureDetector(
            onTapDown: (_) => HapticController.low(),
            onTap: () {
              setState(() {
                selectFilterProduct = "inactive";
                _filterStorageLocations(); // Apply filter immediately
              });
            },
            child: filterProduct(
              context: context,
              label: S.of(context).inactive,
              isSelected: selectFilterProduct == "inactive",
              colorLabel: AppColors.red,
            ),
          ),
        ],
      );
    }

    if (selectedLabel == "Assets") {
      return Row(
        children: [
          GestureDetector(
            onTapDown: (_) => HapticController.low(),
            onTap: () {
              setState(() {
                selectFilterProduct = "all";
              });
              context.read<ProductCubit>().filterProductsByStatus("all");
            },
            child: filterProduct(
              context: context,
              label: S.of(context).all,
              isSelected: selectFilterProduct == "all",
              colorLabel: AppColors.textButton,
            ),
          ),
          SizedBox(width: 10.sp),
          GestureDetector(
            onTapDown: (_) => HapticController.medium(),
            onTap: () {
              setState(() {
                selectFilterProduct = "assigned";
              });
              context.read<ProductCubit>().filterProductsByStatus("assigned");
            },
            child: filterProduct(
              context: context,
              label: S.of(context).assigned,
              isSelected: selectFilterProduct == "assigned",
              colorLabel: AppColors.lightGreen,
            ),
          ),
          SizedBox(width: 10.sp),
          GestureDetector(
            onTapDown: (_) => HapticController.low(),
            onTap: () {
              setState(() {
                selectFilterProduct = "unassigned";
              });
              context.read<ProductCubit>().filterProductsByStatus("unassigned");
            },
            child: filterProduct(
              context: context,
              label: S.of(context).unassigned,
              isSelected: selectFilterProduct == "unassigned",
              colorLabel: AppColors.red,
            ),
          ),
        ],
      );
    }

    // Default for Products and Consumables
    return Row(
      children: [
        GestureDetector(
          onTapDown: (_) => HapticController.low(),
          onTap: () {
            setState(() {
              selectFilterProduct = "all";
            });
            context.read<ProductCubit>().filterProductsByStatus("all");
          },
          child: filterProduct(
            context: context,
            label: S.of(context).all,
            isSelected: selectFilterProduct == "all",
            colorLabel: AppColors.textButton,
          ),
        ),
        SizedBox(width: 10.sp),
        GestureDetector(
          onTapDown: (_) => HapticController.low(),
          onTap: () {
            setState(() {
              selectFilterProduct = "In Stock";
            });
            context.read<ProductCubit>().filterProductsByStatus("In Stock");
          },
          child: filterProduct(
            context: context,
            label: S.of(context).inStock,
            isSelected: selectFilterProduct == "In Stock",
            colorLabel: AppColors.lightGreen,
          ),
        ),
        SizedBox(width: 10.sp),
        GestureDetector(
          onTapDown: (_) => HapticController.low(),
          onTap: () {
            setState(() {
              selectFilterProduct = "Out Of Stock";
            });
            context.read<ProductCubit>().filterProductsByStatus("Out Of Stock");
          },
          child: filterProduct(
            context: context,
            label: S.of(context).outOfStock,
            isSelected: selectFilterProduct == "Out Of Stock",
            colorLabel: AppColors.red,
          ),
        ),
        SizedBox(width: 10.sp),
        GestureDetector(
          onTapDown: (_) => HapticController.low(),
          onTap: () {
            setState(() {
              selectFilterProduct = "Low Stock";
            });
            context.read<ProductCubit>().filterProductsByStatus("Low Stock");
          },
          child: filterProduct(
            context: context,
            label: S.of(context).lowStock,
            isSelected: selectFilterProduct == "Low Stock",
            colorLabel: AppColors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildProductsGridView(ProductState state) {
    if (state is ProductLoading) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(50.sp),
          child: CircleProgressMaster.inline(color: AppColors.primary),
        ),
      );
    }

    if (state is ProductError) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(50.sp),
          child: Column(
            children: [
              Icon(Icons.error_outline, size: 48.sp, color: AppColors.red),
              SizedBox(height: 16.sp),
              Text(
                'Error: ${state.message}',
                style: StyleText.fontSize16Weight400.copyWith(
                  color: AppColors.red,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.sp),
              customButton(
                title: S.of(context).retry,
                function: () => context.read<ProductCubit>().loadProducts(),
                wrapContent: true,
              ),
            ],
          ),
        ),
      );
    }

    if (state is ProductLoaded) {
      final products = state.filteredProducts;

      if (products.isEmpty) {
        return Center(
          child: Padding(
            padding: EdgeInsets.all(0.sp),
            child: Column(
              children: [
                CustomEmptyState(
                  lottiePath:
                      'assets/lottie_assets/main_lottie_assets/lot_empty_state.json',
                  size: 200,
                  verticalPadding: 0,
                ),
              ],
            ),
          ),
        );
      }

      return GridView.builder(
        shrinkWrap: true,
        physics: BouncingScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount:
              CrossAxisCountHelper.getCrossAxisCountForDefaultTablet2(context),
          crossAxisSpacing: 15.sp,
          mainAxisExtent: 90.sp,
          mainAxisSpacing: 15.sp,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return GestureDetector(
            onTap: () {
              // Pass the product data to the details page
              navigateTo(context, ViewProductDetails(productModel: product));
            },
            child: _buildProductCardFromModel(product),
          );
        },
      );
    }

    return SizedBox();
  }

  Widget _buildProductCardFromModel(ProductModel product) {
    final lightMode = Theme.of(context).brightness == Brightness.light;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    // Calculate status based on quantity and reorder level
    String statusText = _getProductStatus(product);
    Color statusColor = _getStatusColor(statusText);

    return Container(
      width: 289.sp,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Padding(
        padding: EdgeInsets.only(top: 10.sp, right: 10.sp, left: 10.sp),
        child: Column(
          children: [
            Stack(
              children: [
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4.r),
                        color:
                            lightMode ? AppColors.grey : AppColors.background,
                      ),
                      width: 50.sp,
                      height: 50.sp,
                      child: CustomSvgImage(
                        assetPath:
                            "assets/icons_assets/main_icons_assets/ic_media_image_placeholder.svg",
                        color: AppColors.blackButton,
                        fit: BoxFit.scaleDown,
                        height: 30.sp,
                        width: 34.sp,
                      ),
                    ),
                    SizedBox(width: 5.sp),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        itemTextProduct(
                          value: product.productId.value,
                          label: "${S.of(context).productID}: ",
                        ),
                        SizedBox(height: 3.sp),
                        itemTextProduct(
                          value: product.status.value,
                          label: "${S.of(context).productType}: ",
                        ),
                        SizedBox(height: 3.sp),
                        itemTextProduct(
                          value: product.supplierName.value,
                          label: "${S.of(context).supplier}: ",
                        ),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  bottom: 40.sp,
                  right: isArabic ? null : 0,
                  left: isArabic ? 0 : null,
                  child: Row(
                    children: [
                      Text(
                        "${S.of(context).status}: ",
                        style: StyleText.fontSize8Weight400.copyWith(
                          color: AppColors.secondaryText,
                        ),
                      ),
                      Text(
                        statusText,
                        style: StyleText.fontSize8Weight400.copyWith(
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 5.sp),
            Row(
              children: [
                Text(
                  FormatHelper.capitalize(product.productName.value),
                  style: StyleText.fontSize14Weight400.copyWith(
                    color: AppColors.blackButton,
                  ),
                ),
                Spacer(),
                itemTextProduct(
                  value: _formatDate(product.orderDate.timestamp),
                  label: "${S.of(context).lastUpdate}: ",
                  valueStyle: StyleText.fontSize8Weight400.copyWith(
                    color: AppColors.blackButton,
                  ),
                  labelStyle: StyleText.fontSize8Weight400.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  ///////////////////////////// Updated Assets & Consumables GridView ////////////////////////////////////
  Widget _buildAssetsGridView(ProductState state) {
    if (state is ProductLoading) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(50.sp),
          child: CircleProgressMaster.inline(color: AppColors.primary),
        ),
      );
    }

    if (state is ProductError) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(50.sp),
          child: Column(
            children: [
              Icon(Icons.error_outline, size: 48.sp, color: AppColors.red),
              SizedBox(height: 16.sp),
              Text(
                'Error: ${state.message}',
                style: StyleText.fontSize16Weight400.copyWith(
                  color: AppColors.red,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.sp),
              customButton(
                title: S.of(context).retry,
                function: () => context.read<ProductCubit>().loadProducts(),
                wrapContent: true,
              ),
            ],
          ),
        ),
      );
    }

    if (state is ProductLoaded) {
      final products = state.filteredProducts;

      if (products.isEmpty) {
        return Center(
          child: Padding(
            padding: EdgeInsets.all(0.sp),
            child: Column(
              children: [
                CustomEmptyState(
                  lottiePath:
                      'assets/lottie_assets/main_lottie_assets/lot_empty_state.json',
                  size: 200,
                  verticalPadding: 0,
                ),
              ],
            ),
          ),
        );
      }

      return GridView.builder(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount:
              CrossAxisCountHelper.getCrossAxisCountForDefaultTablet2(context),
          crossAxisSpacing: 15.sp,
          mainAxisSpacing: 15.sp,
          mainAxisExtent: 116.sp,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          // For demo purposes, simulate assigned/unassigned status
          final isAssigned = index % 2 == 0; // alternating for demo

          return GestureDetector(
            onTap: () {
              // Pass product data to appropriate details page
              if (isAssigned) {
                navigateTo(
                  context,
                  AssetsDetailsSection(
                    productModel: product,
                  ), // Add productModel parameter
                );
              } else {
                navigateTo(
                  context,
                  AssetsDetailsNameSection(
                    productModel: product,
                  ), // Add productModel parameter
                );
              }
            },
            child: isAssigned
                ? _buildAssignedAssetCardFromModel(product, context)
                : _buildUnassignedAssetCardFromModel(product, context),
          );
        },
      );
    }

    return SizedBox();
  }

  Widget _buildAssignedAssetCardFromModel(
    ProductModel product,
    BuildContext context,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(8.sp),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Image.asset(
                      "assets/icons_assets/main_icons_assets/ic_user_avatar_male.png",
                      width: 40.sp,
                      height: 40.sp,
                    ),
                    SizedBox(width: 5.sp),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Employee Name",
                          // You can add employee data to your model if needed
                          style: StyleText.fontSize14Weight500.copyWith(
                            color: AppColors.blackButton,
                          ),
                        ),
                        Text(
                          "Department",
                          style: StyleText.fontSize10Weight500.copyWith(
                            color: AppColors.secondaryText,
                          ),
                        ),
                        Text(
                          "Title",
                          style: StyleText.fontSize10Weight500.copyWith(
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Spacer(),
                itemTextProduct(
                  label: S.of(context).receivedDate,
                  value: _formatDate(product.receivingDate.timestamp),
                  labelStyle: StyleText.fontSize8Weight400.copyWith(
                    color: AppColors.secondaryText,
                  ),
                  valueStyle: StyleText.fontSize8Weight400.copyWith(
                    color: AppColors.blackButton,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.sp),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    itemTextProduct(
                      label: "${S.of(context).assetId}: ",
                      value: product.productId.value,
                    ),
                    SizedBox(height: 10.sp),
                    itemTextProduct(
                      label: "${S.of(context).assetsName}: ",
                      value: product.productName.value,
                    ),
                  ],
                ),
                Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    itemTextProduct(
                      label: "${S.of(context).productID}: ",
                      value: product.productId.value,
                    ),
                    SizedBox(height: 10.sp),
                    itemTextProduct(
                      label: "${S.of(context).location}: ",
                      value: product.storageLocation.value.isNotEmpty
                          ? product.storageLocation.value
                          : "N/A",
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnassignedAssetCardFromModel(
    ProductModel product,
    BuildContext context,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8.r),
      ),
      padding: EdgeInsets.all(10.sp),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CustomSvgImage(
                    assetPath:
                        "assets/icons_assets/main_icons_assets/ic_data_inventory_assets.svg",
                    width: 40.sp,
                    height: 40.sp,
                    color: AppColors.blackButton,
                    fit: BoxFit.scaleDown,
                  ),
                  SizedBox(width: 5.sp),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.productName.value,
                        style: StyleText.fontSize12Weight500.copyWith(
                          color: AppColors.blackButton,
                        ),
                      ),
                      itemTextProduct(
                        label: "${S.of(context).assetId}: ",
                        value: product.productId.value,
                        labelStyle: StyleText.fontSize10Weight500.copyWith(
                          color: AppColors.secondaryText,
                        ),
                        valueStyle: StyleText.fontSize10Weight500.copyWith(
                          color: AppColors.blackButton,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Spacer(),
              itemTextProduct(
                label: S.of(context).receivedDate,
                value: _formatDate(product.receivingDate.timestamp),
                labelStyle: StyleText.fontSize8Weight400.copyWith(
                  color: AppColors.secondaryText,
                ),
                valueStyle: StyleText.fontSize8Weight400.copyWith(
                  color: AppColors.blackButton,
                ),
              ),
            ],
          ),
          SizedBox(height: 13.sp),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  itemTextProduct(
                    label: "${S.of(context).assetId}: ",
                    value: product.productId.value,
                  ),
                  SizedBox(height: 10.sp),
                  itemTextProduct(
                    label: "${S.of(context).assetsName}: ",
                    value: product.productName.value,
                  ),
                ],
              ),
              Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  itemTextProduct(
                    label: "${S.of(context).productID}: ",
                    value: product.productId.value,
                  ),
                  SizedBox(height: 10.sp),
                  itemTextProduct(
                    label: "${S.of(context).location}: ",
                    value: product.storageLocation.value.isNotEmpty
                        ? product.storageLocation.value
                        : "N/A",
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper methods for status calculation and formatting
  String _getProductStatus(ProductModel product) {
    final quantity = int.tryParse(product.quantity.value) ?? 0;
    final reorderLevel = int.tryParse(product.reorderLevel.value) ?? 0;

    if (quantity == 0) {
      return S.of(context).outOfStock;
    } else if (quantity <= reorderLevel) {
      return S.of(context).lowStock;
    } else {
      return S.of(context).inStock;
    }
  }

  Color _getStatusColor(String status) {
    if (status == S.of(context).lowStock) {
      return Color(0xffE5B800);
    } else if (status == S.of(context).inStock) {
      return Colors.green;
    } else {
      return Colors.red;
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')} ${_getMonthName(date.month)} ${date.year}";
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  ///////////////////////////// Original Orders Implementation (Unchanged) ////////////////////////////////////

  /////////////////////////////////////////// Order //////////////////////////////////////////////
  Widget _buildOrderStatusFilters() {
    final List<Map<String, dynamic>> statuses = [
      {
        "label": S.of(context).all,
        "value": "all",
        "color": AppColors.textButton,
      },
      {
        "label": S.of(context).open,
        "value": "open",
        "color": Color(0xffE5B800),
      },
      {
        "label": S.of(context).received,
        "value": "received",
        "color": Color(0xff4BB609),
      },
      {
        "label": S.of(context).partiallyReceived,
        "value": "partially_received",
        "color": Color(0xffFF814A),
      },
      {
        "label": S.of(context).cancelled,
        "value": "cancelled",
        "color": Color(0xffDF1C1C),
      },
      {
        "label": S.of(context).draft,
        "value": "draft",
        "color": Color(0xff797979),
      },
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: statuses.map((status) {
          return Row(
            children: [
              GestureDetector(
                onTap: () {
                  HapticController.low(); // list row: on the tap (X-117)
                  setState(() {
                    selectOrderStatus = status["value"];
                    // Apply the combined filters (status + search)
                    _applyOrderFilters();
                  });
                },
                child: filterProduct(
                  context: context,
                  label: status["label"],
                  isSelected: selectOrderStatus == status["value"],
                  colorLabel: status["color"],
                ),
              ),
              SizedBox(width: 10.sp),
            ],
          );
        }).toList(),
      ),
    );
  }

  void _applyOrderFilters() {
    // Start with all orders
    List<ProductModel> allOrders = orders;

    // Create unique orders for display (group by order ID)
    Map<String, List<ProductModel>> orderGroupsMap = {};
    for (var order in allOrders) {
      if (!orderGroupsMap.containsKey(order.orderId.value)) {
        orderGroupsMap[order.orderId.value] = [];
      }
      orderGroupsMap[order.orderId.value]!.add(order);
    }

    // Use first product from each group for display
    List<ProductModel> uniqueOrders =
        orderGroupsMap.values.map((group) => group.first).toList();

    // Add drafts as ProductModel objects if status filter is "all" or "draft"
    if (selectOrderStatus == "all" || selectOrderStatus == "draft") {
      for (var draft in drafts) {
        // Convert draft to ProductModel for display
        try {
          ProductModel draftAsProduct = _convertDraftToProductModel(draft);
          uniqueOrders.add(draftAsProduct);
        } catch (e) {
          debugPrint("Error converting draft to ProductModel: $e");
        }
      }
    }

    // Apply dialog filters first (if any)
    if (currentFilters.isNotEmpty) {
      uniqueOrders = uniqueOrders.where((order) {
        // Supplier Name Filter
        bool matchesSupplierName = currentFilters['supplierName'] == null ||
            order.supplierName.value == currentFilters['supplierName'];

        // Order Date Range Filter
        bool matchesDateRange = currentFilters['dateRange'] == null ||
            _isOrderDateInRange(
              order.orderDate.timestamp,
              currentFilters['dateRange'],
            );

        return matchesSupplierName && matchesDateRange;
      }).toList();
    }

    // Apply status filter
    List<ProductModel> statusFilteredOrders = _applyOrderStatusFilter(
      uniqueOrders,
      selectOrderStatus,
    );

    // Apply search filter if there's a search query
    if (_searchController.text.isNotEmpty) {
      final lowercaseQuery = _searchController.text.toLowerCase();
      filteredOrders = statusFilteredOrders
          .where(
            (order) =>
                order.orderId.value.toLowerCase().contains(
                      lowercaseQuery,
                    ) ||
                order.productName.value.toLowerCase().contains(
                      lowercaseQuery,
                    ) ||
                order.supplierName.value.toLowerCase().contains(
                      lowercaseQuery,
                    ),
          )
          .toList();
    } else {
      filteredOrders = statusFilteredOrders;
    }
  }

  ProductModel _convertDraftToProductModel(Map<String, dynamic> draft) {
    final now = DateTime.now();

    return ProductModel(
      orderId: FieldWithTimestamp(
        value: draft['orderId'] ?? '',
        timestamp: now,
      ),
      orderType: FieldWithTimestamp(
        value: draft['orderType'] ?? '',
        timestamp: now,
      ),
      productId: FieldWithTimestamp(value: '', timestamp: now),
      orderNote: FieldWithTimestamp(
        value: draft['orderNote'] ?? '',
        timestamp: now,
      ),
      category: FieldWithTimestamp(value: '', timestamp: now),
      subCategory: FieldWithTimestamp(value: '', timestamp: now),
      brand: FieldWithTimestamp(value: '', timestamp: now),
      model: FieldWithTimestamp(value: '', timestamp: now),
      usageFrequency: FieldWithTimestamp(value: '', timestamp: now),
      unitOfMeasurement: FieldWithTimestamp(value: '', timestamp: now),
      productName: FieldWithTimestamp(value: 'Draft Order', timestamp: now),
      quantity: FieldWithTimestamp(value: '', timestamp: now),
      unitCost: FieldWithTimestamp(
        value: draft['orderValue'] ?? '0',
        timestamp: now,
      ),
      currency: FieldWithTimestamp(value: '', timestamp: now),
      supplierName: FieldWithTimestamp(
        value: draft['supplierName'] ?? 'Not selected',
        timestamp: now,
      ),
      expectedLifetime: FieldWithTimestamp(value: '', timestamp: now),
      expectedDelivery: FieldWithTimestamp(
        value: draft['expectedDelivery'] ?? '',
        timestamp: now,
      ),
      deliverySelectedData: FieldWithTimestamp(value: '', timestamp: now),
      reorderLevel: FieldWithTimestamp(value: '', timestamp: now),
      reorderQuantity: FieldWithTimestamp(value: '', timestamp: now),
      additionalNote: FieldWithTimestamp(value: '', timestamp: now),
      productQuantity: FieldWithTimestamp(value: '', timestamp: now),
      orderDate: FieldWithTimestamp(
        value: draft['orderDate'] ?? DateTime.now().toIso8601String(),
        timestamp: _parseTimestamp(draft['createdAt']) ?? now,
      ),
      receivingDate: FieldWithTimestamp(value: '', timestamp: now),

      // Dropdown fields
      storageRequirement: DropdownFieldWithTimestamp(
        value: '',
        options: [],
        timestamp: now,
      ),
      deliveryMethod: DropdownFieldWithTimestamp(
        value: draft['deliveryMethod'] ?? '',
        options: [],
        timestamp: now,
      ),
      year: DropdownFieldWithTimestamp(value: '', options: [], timestamp: now),
      maintenanceFrequency: DropdownFieldWithTimestamp(
        value: '',
        options: [],
        timestamp: now,
      ),
      storageLocation: DropdownFieldWithTimestamp(
        value: '',
        options: [],
        timestamp: now,
      ),
      status: DropdownFieldWithTimestamp(
        value: 'Draft',
        options: [],
        timestamp: now,
      ),
      paymentMethod: DropdownFieldWithTimestamp(
        value: draft['paymentMethod'] ?? '',
        options: [],
        timestamp: now,
      ),

      requestType: FieldWithTimestamp<List<String>>(value: [], timestamp: now),
      approvalCycle: [],

      // Images
      productSpecificationImage: FieldWithTimestamp(value: '', timestamp: now),
      productWarrantyImage: FieldWithTimestamp(value: '', timestamp: now),
      attachmentsImage: FieldWithTimestamp(
        value: (draft['attachmentUrls'] as List<dynamic>?)?.join(',') ?? '',
        timestamp: now,
      ),

      // Other required fields
      vat: FieldWithTimestamp(value: '', timestamp: now),
      discountPercentage: FieldWithTimestamp(value: '', timestamp: now),
      shipping: FieldWithTimestamp(
        value: draft['shipping'] ?? '',
        timestamp: now,
      ),
      orderValue: FieldWithTimestamp(
        value: draft['orderValue'] ?? '',
        timestamp: now,
      ),
      firstNameCreator: FieldWithTimestamp(
        value: draft['createdBy']?['firstName'] ?? '',
        timestamp: now,
      ),
      lastNameCreator: FieldWithTimestamp(
        value: draft['createdBy']?['lastName'] ?? '',
        timestamp: now,
      ),
      firstNameArCreator: FieldWithTimestamp(value: '', timestamp: now),
      lastNameArCreator: FieldWithTimestamp(value: '', timestamp: now),
      departmentCreator: FieldWithTimestamp(
        value: draft['createdBy']?['department'] ?? '',
        timestamp: now,
      ),
      departmentArCreator: FieldWithTimestamp(value: '', timestamp: now),
      jobTitleCreator: FieldWithTimestamp(
        value: draft['createdBy']?['jobTitle'] ?? '',
        timestamp: now,
      ),
      jobTitleArCreator: FieldWithTimestamp(value: '', timestamp: now),
      emailCreator: FieldWithTimestamp(
        value: draft['createdBy']?['email'] ?? '',
        timestamp: now,
      ),
      phoneCreator: FieldWithTimestamp(value: '', timestamp: now),
      supplierId: FieldWithTimestamp(
        value: draft['supplierId'] ?? '',
        timestamp: now,
      ),
      advancedPayment: DropdownFieldWithTimestamp(
        value: draft['advancedPayment'] ?? '',
        options: [],
        timestamp: now,
      ),
      methodOfPayment: DropdownFieldWithTimestamp(
        value: draft['methodOfPayment'] ?? '',
        options: [],
        timestamp: now,
      ),
      beneficiaryName: FieldWithTimestamp(
        value: draft['beneficiaryName'] ?? '',
        timestamp: now,
      ),
      storageAllocations: FieldWithTimestamp(value: '', timestamp: now),
      beneficiaryBankName: FieldWithTimestamp(
        value: draft['beneficiaryBankName'] ?? '',
        timestamp: now,
      ),
      beneficiaryAccountIban: FieldWithTimestamp(
        value: draft['beneficiaryAccountIban'] ?? '',
        timestamp: now,
      ),
      bankSwiftBicCode: FieldWithTimestamp(
        value: draft['bankSwiftBicCode'] ?? '',
        timestamp: now,
      ),
      bankAddress: FieldWithTimestamp(
        value: draft['bankAddress'] ?? '',
        timestamp: now,
      ),
      transactionId: FieldWithTimestamp(value: '', timestamp: now),
    );
  }

  // Helper method to parse timestamp
  DateTime? _parseTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    } else if (timestamp is String) {
      return DateTime.tryParse(timestamp);
    }
    return null;
  }

  Widget _buildOrdersPreview() {
    if (isLoadingOrders) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(50.sp),
          child: CircleProgressMaster.inline(color: AppColors.primary),
        ),
      );
    }

    if (orderError.isNotEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(50.sp),
          child: Column(
            children: [
              Icon(Icons.error_outline, size: 48.sp, color: AppColors.red),
              SizedBox(height: 16.sp),
              Text(
                orderError,
                style: StyleText.fontSize16Weight400.copyWith(
                  color: AppColors.red,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.sp),
              customButton(
                title: S.of(context).retry,
                function: _loadOrders,
                wrapContent: true,
              ),
            ],
          ),
        ),
      );
    }

    if (filteredOrders.isEmpty) {
      return Center(
        child: Column(
          children: [
            CustomEmptyState(
              lottiePath:
                  'assets/lottie_assets/main_lottie_assets/lot_empty_state.json',
              size: 200,
              verticalPadding: 0,
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: CrossAxisCountHelper.getCrossAxisCountForDefaultTablet2(
          context,
        ),
        crossAxisSpacing: 15.sp,
        mainAxisSpacing: 15.sp,
        mainAxisExtent: 111.sp,
      ),
      itemCount: filteredOrders.length,
      itemBuilder: (context, index) {
        final order = filteredOrders[index];
        return GestureDetector(
          // In the order card onTap
          // In _buildOrderCardFromModel, update the onTap:
          onTap: () {
            // Get ALL OR107 products
            List<ProductModel> orderProducts = orders
                .where(
                  (product) => product.orderId.value == order.orderId.value,
                )
                .toList();

            debugPrint(
              "🔍 DIRECT TEST: Found ${orderProducts.length} products for ${order.orderId.value}",
            );
            for (int i = 0; i < orderProducts.length; i++) {
              debugPrint(
                "🔍 DIRECT TEST: Product $i - ${orderProducts[i].productName.value} - ${orderProducts[i].productId.value}",
              );
            }

            // Navigate DIRECTLY to OrderDetails (skip the Toggle wrapper)
            navigateTo(
              context,
              OrderDetails(
                products: orderProducts,
              ), // Direct to OrderDetails, not OrderDetailsToggle
            );
          },
          child: _buildOrderCardFromModel(order),
        );
      },
    );
  }

  Widget _buildOrderCardFromModel(ProductModel order) {
    var lightMode = Theme.of(context).brightness == Brightness.light;
    final bool isDraft = order.status.value.toLowerCase() == 'draft';

    // Get all products for this order ID (only for non-draft orders)
    List<ProductModel> orderProducts = isDraft
        ? [order]
        : orders
            .where(
              (product) => product.orderId.value == order.orderId.value,
            )
            .toList();

    // Calculate total quantity
    orderProducts.fold(
      0,
      (total, product) => total + (int.tryParse(product.quantity.value) ?? 0),
    );

    // Create combined strings for multiple products
    String combinedProductNames =
        orderProducts.map((product) => product.productName.value).join(' - ');
    String combinedQuantities =
        orderProducts.map((product) => product.quantity.value).join(' - ');
    String combinedSupplierNames = orderProducts
        .map((product) => product.supplierName.value)
        .toSet()
        .join(' - '); // Use toSet() to avoid duplicates

    // Get status color
    Color getStatusColor(String status) {
      switch (status.toLowerCase()) {
        case "open":
          return Color(0xffE5B800);
        case "received":
          return Color(0xff4BB609);
        case "partially received":
        case "partially_received":
          return Color(0xffFF814A);
        case "cancelled":
        case "cancel":
          return Color(0xffDF1C1C);
        case "draft":
          return Color(0xff797979);
        default:
          return AppColors.secondaryText;
      }
    }

    return Container(
      padding: EdgeInsets.all(10.sp),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        color: AppColors.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 30.sp,
                height: 30.sp,
                decoration: BoxDecoration(
                  color: (lightMode ? AppColors.grey : AppColors.background),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Center(
                  child: CustomSvgImage(
                    assetPath:
                        "assets/icons_assets/main_icons_assets/ic_data_service_requests.svg",
                    width: 20.sp,
                    height: 20.sp,
                    fit: BoxFit.scaleDown,
                  ),
                ),
              ),
              SizedBox(width: 5.sp),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    itemTextProduct(
                      value: order.orderId.value,
                      label:
                          isDraft ? "Draft ID: " : "${S.of(context).orderID}: ",
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          FormatHelper.capitalize(
                            "${S.of(context).closureStatus}: ",
                          ),
                          style: StyleText.fontSize10Weight500.copyWith(
                            color: AppColors.secondaryText,
                          ),
                        ),
                        Text(
                          FormatHelper.capitalize(order.status.value),
                          style: StyleText.fontSize10Weight500.copyWith(
                            color: getStatusColor(order.status.value),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              itemTextProduct(
                value: _formatDate(order.orderDate.timestamp),
                label: "${S.of(context).orderDate}: ",
              ),
            ],
          ),
          SizedBox(height: 8.sp),
          // Product info with combined names in same row
          itemTextProduct(
            value: combinedProductNames,
            label: "${S.of(context).productName}: ",
          ),
          SizedBox(height: 4.sp),
          itemTextProduct(
            value: combinedSupplierNames,
            label: "${S.of(context).supplierName}: ",
          ),
          SizedBox(height: 4.sp),
          Row(
            children: [
              itemTextProduct(
                value: combinedQuantities,
                label: "${S.of(context).quantity}: ",
              ),
              Spacer(),
              itemTextProduct(
                value: _formatDate(order.receivingDate.timestamp),
                label: "${S.of(context).receivedDate}: ",
              ),
            ],
          ),
        ],
      ),
    );
  }

  /////////////////////////////////////////// Order //////////////////////////////////////////////

  //////////////////////////////////// Core Widget ////////////////////////////////////
  Widget itemTextProduct({
    required String label,
    required String value,
    TextStyle? labelStyle,
    TextStyle? valueStyle,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          FormatHelper.capitalize(label),
          style: labelStyle ??
              StyleText.fontSize10Weight500.copyWith(
                color: AppColors.secondaryText,
              ),
        ),
        Text(
          FormatHelper.capitalize(value),
          style: valueStyle ??
              StyleText.fontSize10Weight500.copyWith(
                color: AppColors.blackButton,
              ),
        ),
      ],
    );
  }

  Widget filterProduct({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required Color colorLabel,
  }) {
    final isMobile = context.isPhone;

    final bool isLight = Theme.of(context).brightness == Brightness.light;
    return Container(
      height: 28.sp,
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primary
            : isLight
                ? AppColors.white
                : AppColors.chatBackground,
        borderRadius: BorderRadius.circular(4.r),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 5.sp : 10.sp,
        vertical: 5.sp,
      ),
      child: Center(
        child: Text(
          label,
          style: isMobile
              ? StyleText.fontSize12Weight400.copyWith(color: colorLabel)
              : StyleText.fontSize14Weight400.copyWith(
                  color: isSelected ? AppColors.textButton : colorLabel,
                ),
        ),
      ),
    );
  }

  //////////////////////////////////// Core Widget ////////////////////////////////////
}
