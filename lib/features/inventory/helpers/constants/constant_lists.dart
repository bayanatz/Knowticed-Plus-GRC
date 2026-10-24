import 'package:knowticed_plus/generated/l10n.dart';

class ConstantLists {
  static List<Map<String, String>> paymentMethod() => [
        {"key": "cash", "value": S.current.deliveryMethodCash},
        {"key": "credit_card", "value": S.current.deliveryMethodCreditCard},
        {"key": "bank_transfer", "value": S.current.deliveryMethodBankTransfer},
        {
          "key": "cash_on_delivery",
          "value": S.current.deliveryMethodCashOnDelivery
        },
      ];
  static List<Map<String, String>> deliveryMethod() => [
        {"key": "Pickup", "value": S.current.pickup},
        {"key": "Delivery", "value": S.current.delivery},
      ];
  static List<Map<String, String>> currencyList() => [
        // Major World Currencies
        {"key": "USD", "value": "USD - US Dollar"},
        {"key": "EUR", "value": "EUR - Euro"},
        {"key": "GBP", "value": "GBP - British Pound"},
        {"key": "JPY", "value": "JPY - Japanese Yen"},
        {"key": "CHF", "value": "CHF - Swiss Franc"},
        {"key": "CAD", "value": "CAD - Canadian Dollar"},
        {"key": "AUD", "value": "AUD - Australian Dollar"},
        {"key": "NZD", "value": "NZD - New Zealand Dollar"},

        // Middle East & Africa
        {"key": "EGP", "value": "EGP - Egyptian Pound"},
        {"key": "SAR", "value": "SAR - Saudi Riyal"},
        {"key": "AED", "value": "AED - UAE Dirham"},
        {"key": "QAR", "value": "QAR - Qatari Riyal"},
        {"key": "KWD", "value": "KWD - Kuwaiti Dinar"},
        {"key": "BHD", "value": "BHD - Bahraini Dinar"},
        {"key": "OMR", "value": "OMR - Omani Rial"},
        {"key": "JOD", "value": "JOD - Jordanian Dinar"},
        {"key": "LBP", "value": "LBP - Lebanese Pound"},
        {"key": "ILS", "value": "ILS - Israeli Shekel"},
        {"key": "TRY", "value": "TRY - Turkish Lira"},
        {"key": "IRR", "value": "IRR - Iranian Rial"},
        {"key": "ZAR", "value": "ZAR - South African Rand"},
        {"key": "MAD", "value": "MAD - Moroccan Dirham"},
        {"key": "TND", "value": "TND - Tunisian Dinar"},
        {"key": "DZD", "value": "DZD - Algerian Dinar"},
        {"key": "LYD", "value": "LYD - Libyan Dinar"},
        {"key": "SDG", "value": "SDG - Sudanese Pound"},
        {"key": "ETB", "value": "ETB - Ethiopian Birr"},
        {"key": "KES", "value": "KES - Kenyan Shilling"},
        {"key": "UGX", "value": "UGX - Ugandan Shilling"},
        {"key": "TZS", "value": "TZS - Tanzanian Shilling"},
        {"key": "RWF", "value": "RWF - Rwandan Franc"},
        {"key": "NGN", "value": "NGN - Nigerian Naira"},
        {"key": "GHS", "value": "GHS - Ghanaian Cedi"},

        // Asian Currencies
        {"key": "CNY", "value": "CNY - Chinese Yuan"},
        {"key": "INR", "value": "INR - Indian Rupee"},
        {"key": "KRW", "value": "KRW - South Korean Won"},
        {"key": "SGD", "value": "SGD - Singapore Dollar"},
        {"key": "HKD", "value": "HKD - Hong Kong Dollar"},
        {"key": "MYR", "value": "MYR - Malaysian Ringgit"},
        {"key": "THB", "value": "THB - Thai Baht"},
        {"key": "PHP", "value": "PHP - Philippine Peso"},
        {"key": "IDR", "value": "IDR - Indonesian Rupiah"},
        {"key": "VND", "value": "VND - Vietnamese Dong"},
        {"key": "PKR", "value": "PKR - Pakistani Rupee"},
        {"key": "BDT", "value": "BDT - Bangladeshi Taka"},
        {"key": "LKR", "value": "LKR - Sri Lankan Rupee"},
        {"key": "NPR", "value": "NPR - Nepalese Rupee"},
        {"key": "AFN", "value": "AFN - Afghan Afghani"},
        {"key": "MMK", "value": "MMK - Myanmar Kyat"},
        {"key": "KHR", "value": "KHR - Cambodian Riel"},
        {"key": "LAK", "value": "LAK - Lao Kip"},
        {"key": "BND", "value": "BND - Brunei Dollar"},
        {"key": "TWD", "value": "TWD - Taiwan Dollar"},
        {"key": "MOP", "value": "MOP - Macanese Pataca"},

        // European Currencies (Non-Euro)
        {"key": "NOK", "value": "NOK - Norwegian Krone"},
        {"key": "SEK", "value": "SEK - Swedish Krona"},
        {"key": "DKK", "value": "DKK - Danish Krone"},
        {"key": "ISK", "value": "ISK - Icelandic Krona"},
        {"key": "PLN", "value": "PLN - Polish Zloty"},
        {"key": "CZK", "value": "CZK - Czech Koruna"},
        {"key": "HUF", "value": "HUF - Hungarian Forint"},
        {"key": "RON", "value": "RON - Romanian Leu"},
        {"key": "BGN", "value": "BGN - Bulgarian Lev"},
        {"key": "HRK", "value": "HRK - Croatian Kuna"},
        {"key": "RSD", "value": "RSD - Serbian Dinar"},
        {"key": "BAM", "value": "BAM - Bosnia-Herzegovina Mark"},
        {"key": "MKD", "value": "MKD - Macedonian Denar"},
        {"key": "ALL", "value": "ALL - Albanian Lek"},
        {"key": "RUB", "value": "RUB - Russian Ruble"},
        {"key": "UAH", "value": "UAH - Ukrainian Hryvnia"},
        {"key": "BYN", "value": "BYN - Belarusian Ruble"},
        {"key": "MDL", "value": "MDL - Moldovan Leu"},
        {"key": "GEL", "value": "GEL - Georgian Lari"},
        {"key": "AMD", "value": "AMD - Armenian Dram"},
        {"key": "AZN", "value": "AZN - Azerbaijani Manat"},

        // South American Currencies
        {"key": "BRL", "value": "BRL - Brazilian Real"},
        {"key": "ARS", "value": "ARS - Argentine Peso"},
        {"key": "CLP", "value": "CLP - Chilean Peso"},
        {"key": "COP", "value": "COP - Colombian Peso"},
        {"key": "PEN", "value": "PEN - Peruvian Sol"},
        {"key": "UYU", "value": "UYU - Uruguayan Peso"},
        {"key": "PYG", "value": "PYG - Paraguayan Guarani"},
        {"key": "BOB", "value": "BOB - Bolivian Boliviano"},
        {"key": "VES", "value": "VES - Venezuelan Bolívar"},
        {"key": "GYD", "value": "GYD - Guyanese Dollar"},
        {"key": "SRD", "value": "SRD - Surinamese Dollar"},

        // North/Central American & Caribbean
        {"key": "MXN", "value": "MXN - Mexican Peso"},
        {"key": "GTQ", "value": "GTQ - Guatemalan Quetzal"},
        {"key": "HNL", "value": "HNL - Honduran Lempira"},
        {"key": "NIO", "value": "NIO - Nicaraguan Córdoba"},
        {"key": "CRC", "value": "CRC - Costa Rican Colón"},
        {"key": "PAB", "value": "PAB - Panamanian Balboa"},
        {"key": "CUP", "value": "CUP - Cuban Peso"},
        {"key": "DOP", "value": "DOP - Dominican Peso"},
        {"key": "HTG", "value": "HTG - Haitian Gourde"},
        {"key": "JMD", "value": "JMD - Jamaican Dollar"},
        {"key": "BBD", "value": "BBD - Barbadian Dollar"},
        {"key": "TTD", "value": "TTD - Trinidad & Tobago Dollar"},
        {"key": "XCD", "value": "XCD - Eastern Caribbean Dollar"},

        // Pacific & Oceania
        {"key": "FJD", "value": "FJD - Fijian Dollar"},
        {"key": "PGK", "value": "PGK - Papua New Guinea Kina"},
        {"key": "SBD", "value": "SBD - Solomon Islands Dollar"},
        {"key": "VUV", "value": "VUV - Vanuatu Vatu"},
        {"key": "WST", "value": "WST - Samoan Tala"},
        {"key": "TOP", "value": "TOP - Tongan Paʻanga"},

        // Central Asian & Others
        {"key": "KZT", "value": "KZT - Kazakhstani Tenge"},
        {"key": "UZS", "value": "UZS - Uzbekistani Som"},
        {"key": "KGS", "value": "KGS - Kyrgyzstani Som"},
        {"key": "TJS", "value": "TJS - Tajikistani Somoni"},
        {"key": "TMT", "value": "TMT - Turkmenistani Manat"},
        {"key": "MNT", "value": "MNT - Mongolian Tugrik"},
        {"key": "KPW", "value": "KPW - North Korean Won"},

        // Digital/Crypto (if you want to include them)
        {"key": "BTC", "value": "BTC - Bitcoin"},
        {"key": "ETH", "value": "ETH - Ethereum"},
        {"key": "USDT", "value": "USDT - Tether"},
        {"key": "USDC", "value": "USDC - USD Coin"},
      ];
  static List<Map<String, String>> vatMethod() => [
        {"key": "0", "value": "0%"},
        {"key": "5", "value": "5%"},
        {"key": "10", "value": "10%"},
        {"key": "15", "value": "15%"},
        {"key": "20", "value": "20%"},
      ];
  static List<Map<String, String>> orderOrderList() => [
        {"key": "Purchase", "value": "Purchase"},
        {"key": "Return", "value": "Return"},
      ];
  static List<Map<String, String>> orderProductList() => [
        {"key": "Assets", "value": "Assets"},
        {"key": "Consumable", "value": "Consumable"},
      ];

  static List<Map<String, String>> startDateList() => [
        {"key": "Preferred", "value": "Preferred"},
        {"key": "Approved", "value": "Approved"},
        {"key": "Approved", "value": "Approved"},
      ];

  static List<Map<String, String>> statusList() => [
        {"key": "Open", "value": "Open"},
        {"key": "Received", "value": "Received"},
        {"key": "Partially Received", "value": "Partially Received"},
        {"key": "Cancel", "value": "Cancel"},
      ];

  // Access Level
  static List<Map<String, String>> accessLevelList() => [
        {"key": "Public Access", "value": S.current.publicAccess},
        {"key": "Internal Access Only", "value": S.current.internalAccessOnly},
        {
          "key": "Authorized Personnel Only",
          "value": S.current.authorizedPersonnelOnly
        },
        {
          "key": "Department-Restricted",
          "value": S.current.departmentRestricted
        },
        {"key": "Managerial Access", "value": S.current.managerialAccess},
        {"key": "Admin-Only Access", "value": S.current.adminOnlyAccess},
        {
          "key": "Confidential / Secure Access",
          "value": S.current.confidentialSecureAccess
        },
      ];

// Storage Capacity
  static List<Map<String, String>> storageCapacityList() => [
        {"key": "Units", "value": S.current.units},
        {"key": "Volume", "value": S.current.volume},
        {"key": "Pallet Space", "value": S.current.palletSpace},
        {"key": "Weight", "value": S.current.weight},
      ];

// Condition Of Storage
  static List<Map<String, String>> conditionOfStorageList() => [
        {"key": "Standard", "value": S.current.standard},
        {
          "key": "Temperature-Controlled",
          "value": S.current.temperatureControlled
        },
        {"key": "Humidity-Controlled", "value": S.current.humidityControlled},
        {"key": "Dry Storage", "value": S.current.dryStorage},
        {"key": "Cold Storage", "value": S.current.coldStorage},
        {"key": "Frozen Storage", "value": S.current.frozenStorage},
        {"key": "Ambient Storage", "value": S.current.ambientStorage},
        {"key": "Secure Storage", "value": S.current.secureStorage},
      ];

// Location Type
  static List<Map<String, String>> locationTypeList() => [
        {"key": "Warehouse", "value": S.current.warehouse},
        {"key": "Main Storage", "value": S.current.mainStorage},
        {"key": "Secure Vault", "value": S.current.secureVault},
        {"key": "Outdoor Yard", "value": S.current.outdoorYard},
        {"key": "Locker", "value": S.current.locker},
        {"key": "Cabinet", "value": S.current.cabinet},
        {"key": "Shelf", "value": S.current.shelf},
        {"key": "Dispatch Zone", "value": S.current.dispatchZone},
        {"key": "Receiving Zone", "value": S.current.receivingZone},
        {"key": "Archive Room", "value": S.current.archiveRoom},
        {"key": "External", "value": S.current.external},
      ];

// Equipment Available
  static List<Map<String, String>> equipmentAvailableList() => [
        {"key": "Forklift", "value": S.current.forklift},
        {
          "key": "Hand Pallet Truck (Manual Jack)",
          "value": S.current.handPalletTruck
        },
        {
          "key": "Notified Security Team",
          "value": S.current.notifiedSecurityTeam
        },
        {"key": "Conveyor System", "value": S.current.conveyorSystem},
        {"key": "Lifting Crane / Hoist", "value": S.current.liftingCrane},
        {
          "key": "Shelving / Racking System",
          "value": S.current.shelvingRackingSystem
        },
        {
          "key": "Temperature Monitoring Devices",
          "value": S.current.temperatureMonitoringDevices
        },
        {"key": "Security Cameras (CCTV)", "value": S.current.securityCameras},
        {
          "key": "Shelving / Racking System",
          "value": S.current.shelvingRacking
        },
        {
          "key": "Labeling / Scanning Devices",
          "value": S.current.labelingScanningDevices
        },
        {
          "key": "Packaging / Unpacking Station",
          "value": S.current.packagingUnpackingStation
        },
        {"key": "Workstations System", "value": S.current.workstationsSystem},
        {
          "key": "Hazardous Material Handling Kit",
          "value": S.current.hazardousMaterialHandlingKit
        },
        {
          "key": "Computer Terminal / Inventory Access Point",
          "value": S.current.computerTerminal
        },
        {"key": "None", "value": S.current.none},
      ];

  static List<String> listOfEquipmentAvailableList() => [
        S.current.forklift,
        S.current.handPalletTruck,
        S.current.notifiedSecurityTeam,
        S.current.conveyorSystem,
        S.current.liftingCrane,
        S.current.shelvingRackingSystem,
        S.current.temperatureMonitoringDevices,
        S.current.securityCameras,
        S.current.shelvingRacking,
        S.current.labelingScanningDevices,
        S.current.packagingUnpackingStation,
        S.current.workstationsSystem,
        S.current.hazardousMaterialHandlingKit,
        S.current.computerTerminal,
        S.current.none,
      ];

  static List<Map<String, String>> businessTypeList() => [
        {
          "key": "Agriculture, Forestry & Fishing",
          "value": "Agriculture, Forestry & Fishing"
        },
        {"key": "Mining & Quarrying", "value": "Mining & Quarrying"},
        {"key": "Manufacturing", "value": "Manufacturing"},
        {"key": "Construction", "value": "Construction"},
        {"key": "Wholesale Trade", "value": "Wholesale Trade"},
        {"key": "Retail Trade", "value": "Retail Trade"},
        {
          "key": "Food & Beverage Services",
          "value": "Food & Beverage Services"
        },
        {"key": "E-Commerce", "value": "E-Commerce"},
        {
          "key": "Information Technology & Software",
          "value": "Information Technology & Software"
        },
        {"key": "Telecommunications", "value": "Telecommunications"},
        {
          "key": "Media, Entertainment & Publishing",
          "value": "Media, Entertainment & Publishing"
        },
        {
          "key": "Creative & Design Services",
          "value": "Creative & Design Services"
        },
        {
          "key": "Professional Services (Legal, Accounting, Consulting)",
          "value": "Professional Services (Legal, Accounting, Consulting)"
        },
        {
          "key": "Human Resources & Recruitment",
          "value": "Human Resources & Recruitment"
        },
        {"key": "Marketing & Advertising", "value": "Marketing & Advertising"},
        {"key": "Real Estate Services", "value": "Real Estate Services"},
        {
          "key": "Financial Services (Banking, Investment, Insurance, FinTech)",
          "value":
              "Financial Services (Banking, Investment, Insurance, FinTech)"
        },
        {
          "key": "Transportation (Air, Land, Sea)",
          "value": "Transportation (Air, Land, Sea)"
        },
        {"key": "Warehousing & Logistics", "value": "Warehousing & Logistics"},
        {
          "key": "Postal & Courier Services",
          "value": "Postal & Courier Services"
        },
        {
          "key": "Healthcare & Social Assistance",
          "value": "Healthcare & Social Assistance"
        },
        {
          "key": "Pharmaceuticals & Biotechnology",
          "value": "Pharmaceuticals & Biotechnology"
        },
        {"key": "Education & Training", "value": "Education & Training"},
        {"key": "Childcare Services", "value": "Childcare Services"},
        {"key": "Hotels & Resorts", "value": "Hotels & Resorts"},
        {"key": "Travel & Tourism", "value": "Travel & Tourism"},
        {"key": "Sports & Recreation", "value": "Sports & Recreation"},
        {"key": "Arts & Culture", "value": "Arts & Culture"},
        {"key": "Environmental Services", "value": "Environmental Services"},
        {
          "key": "NGOs & Non-Profit Organizations",
          "value": "NGOs & Non-Profit Organizations"
        },
        {"key": "Religious Organizations", "value": "Religious Organizations"},
        {
          "key": "Community & Social Services",
          "value": "Community & Social Services"
        },
        {
          "key": "Government Administration",
          "value": "Government Administration"
        },
        {"key": "Defense & Security", "value": "Defense & Security"},
        {
          "key": "Public Safety & Emergency Services",
          "value": "Public Safety & Emergency Services"
        },
        {
          "key": "Energy & Utilities (Electricity, Gas, Water)",
          "value": "Energy & Utilities (Electricity, Gas, Water)"
        },
      ];

  static List<Map<String, String>> departmentTranslationsCamel() => [
        {"key": "marketing", "value": S.current.marketing},
        {"key": "sales", "value": S.current.sales},
        {"key": "hr", "value": S.current.hr},
        {"key": "executive", "value": S.current.executive},
        {"key": "customerSupport", "value": S.current.customerSupport},
        {"key": "operations", "value": S.current.operations},
        {"key": "finance", "value": S.current.finance},
        {
          "key": "informationTechnology",
          "value": S.current.informationTechnology
        },
        {"key": "humanResources", "value": S.current.humanResources},
        {"key": "dataManagement", "value": S.current.dataManagement},
        {"key": "complianceAndLegal", "value": S.current.complianceAndLegal},
        {"key": "software", "value": S.current.software},
      ];
}
