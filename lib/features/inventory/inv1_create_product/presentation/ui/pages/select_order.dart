import 'package:knowticed_plus/core/custom/buttons/custom_button_sizing.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:knowticed_plus/core/app_services/firebase/live_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:knowticed_plus/features/inventory/inv1_create_product/presentation/ui/widgets/select_order/filter_widget.dart';
import 'package:knowticed_plus/generated/l10n.dart';
import 'package:knowticed_plus/core/theme/app_colors.dart';
import 'package:knowticed_plus/features/inventory/domain/models/product_model.dart';
import 'package:knowticed_plus/features/inventory/inv1_create_product/presentation/ui/pages/order_info_toggle.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_navigate.dart';
import 'package:knowticed_plus/core/custom/layout/cross_axis_count_helper.dart';
import 'package:knowticed_plus/core/helper/format_title.dart';
import 'package:knowticed_plus/core/custom/inputs/custom_search_widget_custom.dart';
import 'package:knowticed_plus/core/custom/helpers/custom_svg.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button.dart';
import 'package:knowticed_plus/core/custom/buttons/custom_button_with_svg.dart';
import 'package:knowticed_plus/core/custom/navigation/custom_side_frame_master.dart';
import 'package:knowticed_plus/core/theme/app_theme.dart';
import 'package:knowticed_plus/core/theme/app_animations.dart';
import 'package:knowticed_plus/core/custom/feedback/circle_progress.dart';
import 'package:knowticed_plus/core/theme/haptic_controller.dart';
import 'package:knowticed_plus/features/inventory/helpers/inventory_paths.dart';

class SelectOrderDesktopScreen extends StatefulWidget {
  const SelectOrderDesktopScreen({super.key});

  @override
  State<SelectOrderDesktopScreen> createState() =>
      _SelectOrderDesktopScreenState();
}

class _SelectOrderDesktopScreenState extends State<SelectOrderDesktopScreen> {
  //////////////////////////////////// Variables ////////////////////////////////////
  String selectedLabel = "All";
  final TextEditingController _searchController = TextEditingController();
  bool isGridViewChoose = true;
  Map<String, String> activeFilters = {};

  // Use same variables as inventory screen
  List<ProductModel> orders = [];
  List<ProductModel> filteredOrders = [];
  final LiveRefresh _live = LiveRefresh();
  bool isLoadingOrders = false;
  String orderError = '';

  //////////////////////////////////// Filter Bar ////////////////////////////////////////////////////////

  Widget filterSection(
    BuildContext context,
    Map<String, int> typeCounts,
    int allCount,
  ) {
    final Map<String, String> filterItems = {
      "All": S.of(context).all,
      "Assets": S.of(context).assets,
      "Consumable": S.of(context).consumables,
      "Hybrid": S.of(context).hybrid,
    };

    final Map<String, String> filterCounts = {
      "All": allCount.toString(),
      "Assets": typeCounts['Assets']?.toString() ?? "0",
      "Consumable": typeCounts['Consumable']?.toString() ?? "0",
      "Hybrid": typeCounts['Hybrid']?.toString() ?? "0",
    };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filterItems.entries.map((entry) {
          final key = entry.key;
          final label = entry.value;
          final count = filterCounts[key] ?? "0";
          return _statusChip(count, key, label, context);
        }).toList(),
      ),
    );
  }

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
        });
        _applyOrderFilters(); // Apply filters when chip is selected
      },
      child: Row(
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

  //////////////////////////////////// Init ////////////////////////////////////
  @override
  void initState() {
    super.initState();
    _loadOrders(); // Use the same function as inventory screen

    _searchController.addListener(() {
      _applyOrderFilters();
    });
  }

  @override
  void dispose() {
    _live.dispose();
    _searchController.dispose();
    super.dispose();
  }

  //////////////////////////////////// Load Orders (EXACT COPY FROM INVENTORY SCREEN) ////////////////////////////////////
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

            if (doc.id == "OR107") {
              debugPrint("🔍 OR107 processing ${productsData.length} products");
            }

            for (int i = 0; i < productsData.length; i++) {
              var productData = productsData[i];
              if (productData is Map<String, dynamic>) {
                try {
                  productData['orderId'] = doc.id;
                  ProductModel product = ProductModel.fromJson(productData);
                  loadedOrders.add(product);

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
      int or107Count =
          loadedOrders.where((p) => p.orderId.value == "OR107").length;
      debugPrint("🔍 OR107 products in loaded orders: $or107Count");

      if (!mounted) return;
      setState(() {
        orders = loadedOrders;
        isLoadingOrders = false;
      });

      _applyOrderFilters();
      _live.watchPaths(<String>['Demo/${InventoryPaths.companyId}/order'], () {
        if (mounted) _loadOrders(silent: true);
      });
    } catch (e) {
      debugPrint("❌ Error loading orders: $e");
      if (silent || !mounted) return;
      setState(() {
        orderError = 'Error loading orders: $e';
        isLoadingOrders = false;
      });
    }
  }

  //////////////////////////////////// Filter Logic (SAME AS INVENTORY) ////////////////////////////////////
  void _applyOrderFilters() {
    // Start with all orders
    List<ProductModel> allOrders = orders;

    // Create unique orders for display (group by order ID) - SAME AS INVENTORY
    Map<String, List<ProductModel>> orderGroupsMap = {};
    for (var order in allOrders) {
      if (!orderGroupsMap.containsKey(order.orderId.value)) {
        orderGroupsMap[order.orderId.value] = [];
      }
      orderGroupsMap[order.orderId.value]!.add(order);
    }

    // Use first product from each group for display - SAME AS INVENTORY
    List<ProductModel> uniqueOrders =
        orderGroupsMap.values.map((group) => group.first).toList();

    // Apply search filter
    if (_searchController.text.isNotEmpty) {
      final lowercaseQuery = _searchController.text.toLowerCase();
      uniqueOrders = uniqueOrders
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

    // Apply type filter (from chips)
    if (selectedLabel != "All") {
      uniqueOrders = uniqueOrders.where((order) {
        final displayType = _getDisplayType(order);
        return displayType == selectedLabel;
      }).toList();
    }

    // Apply advanced filters from FilterDialog
    if (activeFilters.isNotEmpty) {
      uniqueOrders = uniqueOrders.where((order) {
        // Filter by product type
        if (activeFilters.containsKey('productType')) {
          final displayType = _getDisplayType(order);
          if (displayType != activeFilters['productType']) {
            return false;
          }
        }

        // Filter by category
        if (activeFilters.containsKey('category')) {
          final orderCategory = _asText(order.category.value).trim();
          if (orderCategory != activeFilters['category']) {
            return false;
          }
        }

        // Filter by subcategory
        if (activeFilters.containsKey('subcategory')) {
          final orderSubcategory = _asText(order.subCategory.value).trim();
          if (!orderSubcategory.contains(activeFilters['subcategory']!)) {
            return false;
          }
        }

        // ADD SUPPLIER FILTER
        if (activeFilters.containsKey('supplier')) {
          final orderSupplier = _asText(order.supplierName.value).trim();
          if (orderSupplier != activeFilters['supplier']) {
            return false;
          }
        }

        // Filter by order date
        if (activeFilters.containsKey('orderDate')) {
          try {
            final filterDate = DateTime.parse(activeFilters['orderDate']!);
            final orderDate = order.orderDate.timestamp;

            if (orderDate.year != filterDate.year ||
                orderDate.month != filterDate.month ||
                orderDate.day != filterDate.day) {
              return false;
            }
          } catch (e) {
            debugPrint('Error parsing order date filter: $e');
          }
        }

        // Filter by receiving date
        if (activeFilters.containsKey('receivingDate')) {
          try {
            final filterDate = DateTime.parse(
              activeFilters['receivingDate']!,
            );
            final receivingDate = order.receivingDate.timestamp;

            if (receivingDate.year != filterDate.year ||
                receivingDate.month != filterDate.month ||
                receivingDate.day != filterDate.day) {
              return false;
            }
          } catch (e) {
            debugPrint('Error parsing receiving date filter: $e');
          }
        }

        return true;
      }).toList();
    }

    setState(() {
      filteredOrders = uniqueOrders;
    });
  }

  // Determine the display type based on hybrid logic
  // Replace your _getDisplayType method with this debug version:

  // Replace your _getDisplayType method with this corrected version:

  String _getDisplayType(ProductModel order) {
    // Get ALL products for this order ID to check for hybrid combinations
    List<ProductModel> allOrderProducts = orders
        .where((product) => product.orderId.value == order.orderId.value)
        .toList();

    debugPrint(
      "🔍 Checking order ${order.orderId.value} with ${allOrderProducts.length} products",
    );

    // Collect all unique product types (status values) in this order
    Set<String> productTypes = {};

    for (ProductModel product in allOrderProducts) {
      String status = _asText(product.status.value).toLowerCase().trim();
      debugPrint("🔍 Product ${product.productId.value} status: '$status'");

      if (status.isNotEmpty) {
        // Normalize the status values
        if (status.contains('asset') ||
            status == 'assets' ||
            status == 'asset') {
          productTypes.add('assets');
        } else if (status.contains('consumable') ||
            status == 'consumables' ||
            status == 'consumable') {
          productTypes.add('consumables');
        } else if (status.contains('hybrid') || status == 'hybrid') {
          productTypes.add('hybrid');
        } else {
          // Default unknown types to assets
          productTypes.add('assets');
        }
      } else {
        // Empty status defaults to assets
        productTypes.add('assets');
      }
    }

    debugPrint(
        "🔍 Order ${order.orderId.value} product types found: $productTypes");

    // Determine display type based on combination
    if (productTypes.contains('hybrid')) {
      debugPrint(
        "✅ Order ${order.orderId.value} contains explicit hybrid products -> Hybrid",
      );
      return 'Hybrid';
    } else if (productTypes.contains('assets') &&
        productTypes.contains('consumables')) {
      debugPrint(
        "✅ Order ${order.orderId.value} contains both Assets and Consumables -> Hybrid",
      );
      return 'Hybrid';
    } else if (productTypes.contains('consumables')) {
      debugPrint(
        "✅ Order ${order.orderId.value} contains only Consumables -> Consumable",
      );
      return 'Consumable';
    } else {
      debugPrint(
          "✅ Order ${order.orderId.value} contains only Assets -> Assets");
      return 'Assets';
    }
  }

  // Calculate type counts with hybrid logic

  Map<String, int> _calculateTypeCounts(List<ProductModel> allOrders) {
    // IMPORTANT: Calculate from ALL orders, not filtered ones
    // Create unique orders first (same logic as in _applyOrderFilters)
    Map<String, List<ProductModel>> orderGroupsMap = {};
    for (var order in orders) {
      // Use 'orders' not 'allOrders' parameter
      if (!orderGroupsMap.containsKey(order.orderId.value)) {
        orderGroupsMap[order.orderId.value] = [];
      }
      orderGroupsMap[order.orderId.value]!.add(order);
    }

    // Get unique orders (one representative per order ID)
    List<ProductModel> uniqueOrders =
        orderGroupsMap.values.map((group) => group.first).toList();

    Map<String, int> counts = {"Assets": 0, "Consumable": 0, "Hybrid": 0};

    // Count from ALL unique orders, not filtered ones
    for (var order in uniqueOrders) {
      final displayType = _getDisplayType(order);
      if (counts.containsKey(displayType)) {
        counts[displayType] = counts[displayType]! + 1;
      }
    }

    debugPrint("📊 Type counts calculated:");
    debugPrint("Assets: ${counts['Assets']}");
    debugPrint("Consumables: ${counts['Consumable']}");
    debugPrint("Hybrid: ${counts['Hybrid']}");
    debugPrint("Total unique orders: ${uniqueOrders.length}");

    return counts;
  }

  bool isTabletLandscape(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    return size.width >= 600 && isLandscape;
  }

  String _asText(dynamic v) {
    if (v == null) return '';
    if (v is Map) return _asText(v['value']);
    if (v is Timestamp) return v.toDate().toString();
    if (v is num || v is bool) return '$v';
    return v.toString();
  }

  //////////////////////////////////// Build ////////////////////////////////////
  @override
  Widget build(BuildContext context) {
    final isMobile = context.isPhone;
    final Map<String, int> typeCounts = _calculateTypeCounts(
      orders,
    ); // Changed from filteredOrders to orders

    var lightMode = Theme.of(context).brightness == Brightness.light;
    Localizations.localeOf(context).languageCode == 'ar';

    // Handle loading state
    if (isLoadingOrders) {
      return SafeArea(
        child: Scaffold(
          body: SideFrameMasterServices(
            titleText: S.of(context).inventoryManagement,
            onFirstTap: () {
              Navigator.pop(context);
            },
            secondTitle: S.of(context).addingNewProduct,
            child: Center(child: CircleProgressMaster.inline()),
          ),
        ),
      );
    }

    // Handle error state
    if (orderError.isNotEmpty) {
      return SafeArea(
        child: Scaffold(
          body: SideFrameMasterServices(
            titleText: S.of(context).inventoryManagement,
            onFirstTap: () {
              Navigator.pop(context);
            },
            secondTitle: S.of(context).addingNewProduct,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error loading orders: $orderError',
                    style: StyleText.fontSize16Weight500.copyWith(
                      color: Colors.red,
                    ),
                  ),
                  SizedBox(height: 16.sp),
                  customButton(
                    title: 'Retry',
                    function: _loadOrders,
                    textStyle: StyleText.fontSize16Weight500.copyWith(
                      color: Colors.white,
                    ),
                    width: 100.sp,
                    height: 38.sp,
                    radius: 8.r,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Calculate type counts for the chips

    return SafeArea(
      child: Scaffold(
        body: SideFrameMasterServices(
          titleText: S.of(context).inventoryManagement,
          onFirstTap: () {
            Navigator.pop(context);
          },
          secondTitle: S.of(context).addingNewProduct,
          child: SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            child: Column(
              children: [
                // Filter Section
                isMobile
                    ? SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: filterSection(
                          context,
                          typeCounts,
                          orders
                              .map((o) => o.orderId.value)
                              .toSet()
                              .length, // This gives total unique orders
                        ),
                      )
                    : Row(
                        children: [
                          filterSection(
                            context,
                            typeCounts,
                            orders
                                .map((o) => o.orderId.value)
                                .toSet()
                                .length, // This gives total unique orders
                          ),
                        ],
                      ),

                SizedBox(height: 30.sp),

                // label of Order Details
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      S.of(context).orderDetails,
                      style: StyleText.fontSize16Weight500.copyWith(
                        color: AppColors.blackButton,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 8.sp),

                // Search and filter
                Row(
                  children: [
                    // Search
                    AppSearchTextField(
                      controller: _searchController,
                      onChanged: (query) {
                        // Filters are applied automatically through the listener
                      },
                    ),

                    SizedBox(width: ButtonSizing.toolbarGap(context)),

                    // Filter
                    customButtonWithSvg(
                      title: isMobile || !isTabletLandscape(context)
                          ? ""
                          : S.of(context).filter,
                      function: _showFilterDialog,
                      // 22/10/2026 — Owner: toolbar text is 14 in every module (was 16).
                      textStyle: StyleText.fontSize14Weight500.copyWith(
                        color: activeFilters.isNotEmpty
                            ? AppColors.textButton
                            : AppColors.secondaryText,
                      ),
                      width: isMobile || !isTabletLandscape(context)
                          ? 38.sp
                          : 100.sp,
                      height: ButtonSizing.height,
                      space: 8.sp,
                      radius: 8.r,
                      svgColor: activeFilters.isNotEmpty
                          ? AppColors.textButton
                          : AppColors.secondaryText,
                      color: activeFilters.isNotEmpty
                          ? AppColors.primary
                          : AppColors.card,
                      image:
                          "assets/icons_assets/main_icons_assets/ic_action_filter.svg",
                      widthImage: 20.sp,
                      heightImage: 20.sp,
                      colorBorder: Colors.transparent,
                    ),
                  ],
                ),

                SizedBox(height: 15.sp),
                //
                // // Display filtered results count for debugging
                // if (filteredOrders.length != orders.length)
                //   Padding(
                //     padding: EdgeInsets.only(bottom: 10.sp),
                //     child: Text(
                //       "Showing ${filteredOrders.length} of ${orders
                //           .length} orders",
                //       style: StyleText.fontSize12Weight400.copyWith(
                //         color: lightMode
                //             ? AppColors.secondaryText
                //             : AppColors.grey,
                //       ),
                //     ),
                //   ),

                // Grid View
                SizedBox(
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.zero,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: CrossAxisCountHelper
                          .getCrossAxisCountForDefaultTablet2(
                        context,
                      ),
                      crossAxisSpacing: 15.sp,
                      mainAxisSpacing: 15.sp,
                      mainAxisExtent: 130.sp,
                    ),
                    itemCount: filteredOrders.length,

                    // Replace your existing GridView.builder itemBuilder with this updated version:
                    itemBuilder: (context, index) {
                      final order = filteredOrders[index];

                      // Get ALL products for this specific order ID
                      List<ProductModel> allOrderProducts = orders
                          .where(
                            (product) =>
                                product.orderId.value == order.orderId.value,
                          )
                          .toList();

                      // Combine all product information with "/"
                      String combinedProductNames = allOrderProducts
                          .map(
                            (product) =>
                                _asText(product.productName.value).trim(),
                          )
                          .where((name) => name.isNotEmpty)
                          .join(' / ');

                      String combinedSuppliers = allOrderProducts
                          .map(
                            (product) =>
                                _asText(product.supplierName.value).trim(),
                          )
                          .where((supplier) => supplier.isNotEmpty)
                          .toSet() // Remove duplicates
                          .join(' / ');

                      String combinedQuantities = allOrderProducts
                          .map(
                            (product) => _asText(product.quantity.value).trim(),
                          )
                          .where((qty) => qty.isNotEmpty)
                          .join(' / ');

                      final numberOfProducts = allOrderProducts.length;
                      final displayType = _getDisplayType(order);

                      return GestureDetector(
                        onTap: () async {
                          debugPrint(
                            "🔍 Selected order ${order.orderId.value} with ${allOrderProducts.length} products",
                          );

                          // ✅ FETCH THE COMPLETE ORDER DOCUMENT FROM FIREBASE
                          try {
                            final orderDoc = await FirebaseFirestore.instance
                                .collection("Demo")
                                .doc(InventoryPaths.companyId)
                                .collection("order")
                                .doc(order.orderId.value)
                                .get();

                            if (!orderDoc.exists) {
                              debugPrint(
                                "❌ Order document not found: ${order.orderId.value}",
                              );
                              return;
                            }

                            // ✅ GET THE COMPLETE ORDER DATA
                            final completeOrderData =
                                orderDoc.data() as Map<String, dynamic>;

                            final hasUsageInfo = allOrderProducts.any(
                              (p) => _asText(
                                p.usageFrequency.value,
                              ).trim().isNotEmpty,
                            );
                            final isMultiProduct = allOrderProducts.length > 1;

                            final List<Map<String, dynamic>> productEntries =
                                [];

                            for (int i = 0; i < allOrderProducts.length; i++) {
                              final product = allOrderProducts[i];
                              productEntries.add({
                                "orderId": _asText(product.orderId.value),
                                "productId": _asText(product.productId.value),
                                "productName": _asText(
                                  product.productName.value,
                                ),
                                "quantity": _asText(product.quantity.value),
                                "category": _asText(product.category.value),
                                "subcategory": _asText(
                                  product.subCategory.value,
                                ),
                                "brand": _asText(product.brand.value),
                                "model": _asText(product.model.value),
                                "unitCost": _asText(product.unitCost.value),
                                "currency": _asText(product.currency.value),
                                "supplierName": _asText(
                                  product.supplierName.value,
                                ),
                                "orderDate": _asText(product.orderDate.value),
                                "receivingDate": _asText(
                                  product.receivingDate.timestamp,
                                ),
                                "usageFrequency": _asText(
                                  product.usageFrequency.value,
                                ),
                                "unitOfMeasurement": _asText(
                                  product.unitOfMeasurement.value,
                                ),
                                "maintenanceFrequency": _asText(
                                  product.maintenanceFrequency.value,
                                ),
                                "status": _asText(product.status.value),
                              });
                            }

                            // ✅ MERGE COMPLETE ORDER DATA WITH PRODUCT DATA
                            final orderData = {
                              ...completeOrderData, // Include ALL order-level fields (vat, shipping, orderValue, etc.)
                              "orderId": order.orderId.value,
                              "products": productEntries,
                              "productNames": allOrderProducts
                                  .map((p) => p.productName.value)
                                  .toList(),
                            };

                            if (!context.mounted) return;
                            navigateTo(
                              context,
                              AddingProductAssets(
                                orderData: orderData,
                                isConsumable: hasUsageInfo,
                                isMultiProduct: isMultiProduct,
                                currentProductIndex: 0,
                                productModels: [],
                              ),
                            );
                          } catch (e) {
                            debugPrint(
                                "❌ Error fetching complete order data: $e");
                          }
                        },
                        child: Container(
                          constraints: BoxConstraints(minHeight: 150.sp),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Stack(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(10.sp),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Image + ID + Product Count
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              4.r,
                                            ),
                                            color: lightMode
                                                ? AppColors.grey
                                                : AppColors.background,
                                          ),
                                          width: 30.sp,
                                          height: 30.sp,
                                          child: CustomSvgImage(
                                            assetPath:
                                                "assets/icons_assets/main_icons_assets/ic_data_service_requests.svg",
                                            fit: BoxFit.scaleDown,
                                            color: AppColors.blackButton,
                                            height: 20.sp,
                                            width: 20.sp,
                                          ),
                                        ),
                                        SizedBox(width: 5.sp),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              itemTextProduct(
                                                value: order.orderId.value,
                                                label:
                                                    "${S.of(context).orderID}: ",
                                              ),
                                              SizedBox(height: 2.sp),
                                              itemTextProduct(
                                                value:
                                                    numberOfProducts.toString(),
                                                label:
                                                    "${S.of(context).numberOfProduct}: ",
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Type badge
                                        Container(
                                          constraints: BoxConstraints(
                                            minWidth: 60.sp,
                                            maxWidth: 80.sp,
                                          ),
                                          height: 20.sp,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              4.r,
                                            ),
                                            color: lightMode
                                                ? const Color(0xffF5F5F5)
                                                : AppColors.background,
                                          ),
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 4.sp,
                                          ),
                                          child: Center(
                                            child: Text(
                                              FormatHelper.capitalize(
                                                displayType,
                                              ),
                                              style: StyleText
                                                  .fontSize10Weight400
                                                  .copyWith(
                                                color: AppColors.blackButton,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8.sp),
                                    // Product details with combined information
                                    Column(
                                      children: [
                                        // Combined Product Names with "/"
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "${S.of(context).product}: ",
                                              style: StyleText
                                                  .fontSize10Weight500
                                                  .copyWith(
                                                color: AppColors.secondaryText,
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                FormatHelper.capitalize(
                                                  combinedProductNames,
                                                ),
                                                style: StyleText
                                                    .fontSize10Weight500
                                                    .copyWith(
                                                  color: AppColors.blackButton,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 2,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 4.sp),
                                        // Combined Suppliers with "/"
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "${S.of(context).supplier}: ",
                                              style: StyleText
                                                  .fontSize10Weight500
                                                  .copyWith(
                                                color: AppColors.secondaryText,
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                FormatHelper.capitalize(
                                                  combinedSuppliers,
                                                ),
                                                style: StyleText
                                                    .fontSize10Weight500
                                                    .copyWith(
                                                  color: AppColors.blackButton,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 2,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 4.sp),
                                        // Combined Quantities with "/"
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "${S.of(context).quantity}: ",
                                              style: StyleText
                                                  .fontSize10Weight500
                                                  .copyWith(
                                                color: AppColors.secondaryText,
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                FormatHelper.capitalize(
                                                  combinedQuantities,
                                                ),
                                                style: StyleText
                                                    .fontSize10Weight500
                                                    .copyWith(
                                                  color: AppColors.blackButton,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 4.sp),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            // Order Date - Left side
                                            Expanded(
                                              flex: 1,
                                              child: itemTextProduct(
                                                label:
                                                    "${S.of(context).orderDate}: ",
                                                value: DateFormat(
                                                  'dd MMM yyyy',
                                                ).format(
                                                  order.orderDate.timestamp,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // Receiving Date - Right side
                              Positioned(
                                right: 13.w,
                                bottom: 15.h,
                                child: itemTextProduct(
                                  label: "${S.of(context).receivingDate}: ",
                                  value: DateFormat(
                                    'dd MMM yyyy',
                                  ).format(order.receivingDate.timestamp),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                SizedBox(height: 20.sp),

                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    customButton(
                      title: S.of(context).back,
                      function: () {
                        Navigator.pop(context);
                      },
                      textStyle: StyleText.fontSize16Weight500.copyWith(
                        color: AppColors.blackButton,
                      ),
                      width: 150.sp,
                      height: 38.sp,
                      radius: 8.r,
                      color: AppColors.grey,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /////////////////////////// Helper Methods /////////////////////////////////////////////////////////

  Widget itemTextProduct({required String label, required dynamic value}) {
    final text = _asText(value);

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          FormatHelper.capitalize(label),
          style: StyleText.fontSize10Weight500.copyWith(
            color: AppColors.secondaryText,
          ),
        ),
        Text(
          FormatHelper.capitalize(text),
          style: StyleText.fontSize10Weight500.copyWith(
            color: AppColors.blackButton,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  void _showFilterDialog() {
    // Extract unique suppliers from orders
    Set<String> uniqueSuppliers = {};
    for (var order in orders) {
      final supplier = _asText(order.supplierName.value).trim();
      if (supplier.isNotEmpty) {
        uniqueSuppliers.add(supplier);
      }
    }

    // Convert to the format expected by dropdown
    List<Map<String, String>> supplierOptions = uniqueSuppliers
        .map((supplier) => {'key': supplier, 'value': supplier})
        .toList();

    // Sort suppliers alphabetically for better UX
    supplierOptions.sort((a, b) => a['value']!.compareTo(b['value']!));

    showAppDialog(
      context: context,
      builder: (BuildContext context) {
        return FilterDialog(
          initialFilters: activeFilters,
          availableSuppliers: supplierOptions, // ADD THIS PARAMETER
          onApplyFilter: (filters) {
            setState(() {
              final nonEmptyFilters = Map<String, String>.from(filters);
              nonEmptyFilters.removeWhere(
                (key, value) => value.isEmpty || value == 'null',
              );

              activeFilters = nonEmptyFilters;
              _applyAdvancedFilters(activeFilters);
            });
          },
        );
      },
    );
  }

  void _applyAdvancedFilters(Map<String, String> filters) {
    debugPrint('Applying filters: $filters');
    _applyOrderFilters(); // Apply filters immediately
  }
}
