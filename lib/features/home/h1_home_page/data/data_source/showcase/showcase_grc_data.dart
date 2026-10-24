/// Module: home/h1_home_page / data / data_source / showcase
///
///*************************** FILE INFO ****************************///
/// File Name: showcase_grc_data.dart
/// Purpose: The wording of the GRC showcase: modules, policies, controls,
///          evidence notes, rejection reasons and comment threads, every line
///          in English and Arabic. The records themselves are built in
///          `showcase_grc.dart`.
/// Author: Knowticed Plus team
/// Created at: 21/10/2026
library;

import 'package:knowticed_plus/features/home/h1_home_page/data/data_source/showcase/showcase_common.dart';

/// Lifecycle of a showcase module.
enum GrcModuleKind { active, inactive, scheduled, removed }

/// Lifecycle of a showcase policy.
enum GrcPolicyKind { active, scheduled, draft, inactive, expired }

/// One policy of a module.
class GrcPolicySpec {
  const GrcPolicySpec(this.name, this.kind);

  final Bi name;
  final GrcPolicyKind kind;
}

/// One module with its policies. [slots] says how many controls of each
/// evidence situation the module gets (see `showcase_grc.dart`); a module
/// without slots only gets a few plain controls.
class GrcModuleSpec {
  const GrcModuleSpec({
    required this.code,
    required this.name,
    required this.description,
    required this.kind,
    required this.createdMonth,
    required this.createdDay,
    required this.policies,
    this.slots = const <String, int>{},
    this.activationMonth,
    this.activationDay,
    this.activationNextYear = false,
    this.removedMonth,
    this.departmentIndex = 0,
    this.requestsPerStatus = 0,
    this.controlOffset = 0,
  });

  /// Short prefix used in policy and control numbers.
  final String code;
  final Bi name;
  final Bi description;
  final GrcModuleKind kind;
  final int createdMonth;
  final int createdDay;
  final List<GrcPolicySpec> policies;

  /// Controls per situation: cH cA cB cC cD cE cI (champion is the signed-in
  /// user), oC oD oE oF oG (owner is the signed-in user), gD gE (module owner
  /// gives the score), bg (plain active), un (unassigned).
  final Map<String, int> slots;

  final int? activationMonth;
  final int? activationDay;
  final bool activationNextYear;
  final int? removedMonth;
  final int departmentIndex;

  /// Reassignment requests per status (pending, approved, rejected, canceled).
  final int requestsPerStatus;

  /// Where in the control list this module starts reading names.
  final int controlOffset;

  bool get isFull => slots.isNotEmpty;
}

abstract final class GrcShowcaseData {
  // ── Departments used when the tenant has none loaded ─────────────────
  static const List<Bi> fallbackDepartments = <Bi>[
    Bi('Data Governance', 'حوكمة البيانات'),
    Bi('Information Technology', 'تقنية المعلومات'),
    Bi('Legal and Compliance', 'الشؤون القانونية والامتثال'),
    Bi('Internal Audit', 'التدقيق الداخلي'),
    Bi('Corporate Communications', 'الاتصال المؤسسي'),
    Bi('Finance', 'المالية'),
    Bi('Operations', 'العمليات'),
    Bi('Strategy and Planning', 'الاستراتيجية والتخطيط'),
  ];

  // ── Modules ───────────────────────────────────────────────────────────
  static const List<GrcModuleSpec> modules = <GrcModuleSpec>[
    // Six active modules, fully filled.
    GrcModuleSpec(
      code: 'DG',
      name: Bi('Data Governance and NDMO Compliance',
          'حوكمة البيانات والامتثال لمعايير مكتب إدارة البيانات الوطنية'),
      description: Bi(
          'Governs data ownership, quality and sharing across the organisation and tracks compliance with the national data management standards.',
          'تحكم ملكية البيانات وجودتها ومشاركتها في المنظمة وتتابع الامتثال لمعايير إدارة البيانات الوطنية.'),
      kind: GrcModuleKind.active,
      createdMonth: 1,
      createdDay: 5,
      departmentIndex: 0,
      requestsPerStatus: 5,
      controlOffset: 0,
      slots: <String, int>{
        'cH': 5,
        'cA': 5,
        'cB': 5,
        'cC': 3,
        'cD': 3,
        'cE': 5,
        'cI': 5,
        'oC': 5,
        'oD': 5,
        'oE': 5,
        'oF': 5,
        'oG': 5,
        'gD': 5,
        'gE': 5,
        'bg': 5,
        'un': 5,
      },
      policies: <GrcPolicySpec>[
        GrcPolicySpec(Bi('Data Governance Policy', 'سياسة حوكمة البيانات'),
            GrcPolicyKind.active),
        GrcPolicySpec(
            Bi('Data Quality Management Policy', 'سياسة إدارة جودة البيانات'),
            GrcPolicyKind.active),
        GrcPolicySpec(
            Bi('Data Classification and Handling Policy',
                'سياسة تصنيف البيانات والتعامل معها'),
            GrcPolicyKind.active),
        GrcPolicySpec(
            Bi('Metadata and Data Catalogue Policy',
                'سياسة البيانات الوصفية ودليل البيانات'),
            GrcPolicyKind.active),
        GrcPolicySpec(
            Bi('Data Sharing and Exchange Policy',
                'سياسة مشاركة البيانات وتبادلها'),
            GrcPolicyKind.active),
        GrcPolicySpec(
            Bi('Master Data Management Policy',
                'سياسة إدارة البيانات الرئيسية'),
            GrcPolicyKind.scheduled),
        GrcPolicySpec(Bi('Open Data Policy', 'سياسة البيانات المفتوحة'),
            GrcPolicyKind.scheduled),
        GrcPolicySpec(
            Bi('Data Retention and Disposal Policy',
                'سياسة الاحتفاظ بالبيانات والتخلص منها'),
            GrcPolicyKind.scheduled),
        GrcPolicySpec(Bi('Reference Data Policy', 'سياسة البيانات المرجعية'),
            GrcPolicyKind.scheduled),
        GrcPolicySpec(Bi('Data Lineage Policy', 'سياسة مسار البيانات'),
            GrcPolicyKind.scheduled),
        GrcPolicySpec(
            Bi('AI and Analytics Governance Policy',
                'سياسة حوكمة الذكاء الاصطناعي والتحليلات'),
            GrcPolicyKind.draft),
        GrcPolicySpec(Bi('Data Ethics Guideline', 'دليل أخلاقيات البيانات'),
            GrcPolicyKind.draft),
        GrcPolicySpec(Bi('Synthetic Data Policy', 'سياسة البيانات الاصطناعية'),
            GrcPolicyKind.draft),
        GrcPolicySpec(
            Bi('Cross-Border Data Transfer Policy',
                'سياسة نقل البيانات عبر الحدود'),
            GrcPolicyKind.draft),
        GrcPolicySpec(
            Bi('Data Monetisation Guideline',
                'دليل الاستفادة التجارية من البيانات'),
            GrcPolicyKind.draft),
        GrcPolicySpec(
            Bi('Legacy Data Warehouse Policy', 'سياسة مستودع البيانات القديم'),
            GrcPolicyKind.inactive),
        GrcPolicySpec(
            Bi('Spreadsheet Controls Policy',
                'سياسة ضوابط الجداول الإلكترونية'),
            GrcPolicyKind.inactive),
        GrcPolicySpec(
            Bi('Paper Records Digitisation Policy',
                'سياسة رقمنة السجلات الورقية'),
            GrcPolicyKind.inactive),
        GrcPolicySpec(
            Bi('Interim Data Access Policy',
                'سياسة الوصول المؤقت إلى البيانات'),
            GrcPolicyKind.inactive),
        GrcPolicySpec(
            Bi('Data Migration Policy (Phase 1)',
                'سياسة ترحيل البيانات (المرحلة الأولى)'),
            GrcPolicyKind.inactive),
        GrcPolicySpec(
            Bi('2025 Data Governance Charter', 'ميثاق حوكمة البيانات 2025'),
            GrcPolicyKind.expired),
        GrcPolicySpec(
            Bi('Data Governance Roadmap 2025',
                'خارطة طريق حوكمة البيانات 2025'),
            GrcPolicyKind.expired),
        GrcPolicySpec(
            Bi('Pilot Data Stewardship Programme',
                'برنامج أمناء البيانات التجريبي'),
            GrcPolicyKind.expired),
        GrcPolicySpec(
            Bi('Data Awareness Plan 2025', 'خطة التوعية بالبيانات 2025'),
            GrcPolicyKind.expired),
        GrcPolicySpec(
            Bi('Interim Data Quality Standard', 'معيار جودة البيانات المؤقت'),
            GrcPolicyKind.expired),
      ],
    ),
    GrcModuleSpec(
      code: 'IS',
      name:
          Bi('Information Security (ISO 27001)', 'أمن المعلومات (آيزو 27001)'),
      description: Bi(
          'Controls for protecting information assets, access, systems and incident response, aligned with ISO 27001.',
          'ضوابط حماية الأصول المعلوماتية والوصول والأنظمة والاستجابة للحوادث بما يتوافق مع آيزو 27001.'),
      kind: GrcModuleKind.active,
      createdMonth: 1,
      createdDay: 19,
      departmentIndex: 1,
      requestsPerStatus: 3,
      controlOffset: 30,
      slots: <String, int>{
        'cH': 3,
        'cA': 3,
        'cB': 3,
        'cC': 2,
        'cD': 2,
        'cE': 3,
        'cI': 3,
        'oC': 3,
        'oD': 3,
        'oE': 3,
        'oF': 3,
        'oG': 3,
        'gD': 3,
        'gE': 3,
        'bg': 4,
        'un': 2,
      },
      policies: <GrcPolicySpec>[
        GrcPolicySpec(Bi('Information Security Policy', 'سياسة أمن المعلومات'),
            GrcPolicyKind.active),
        GrcPolicySpec(Bi('Access Control Policy', 'سياسة التحكم في الوصول'),
            GrcPolicyKind.active),
        GrcPolicySpec(Bi('Incident Response Policy', 'سياسة الاستجابة للحوادث'),
            GrcPolicyKind.active),
        GrcPolicySpec(
            Bi('Secure Backup and Recovery Policy',
                'سياسة النسخ الاحتياطي والاستعادة الآمنة'),
            GrcPolicyKind.active),
        GrcPolicySpec(Bi('Cloud Security Policy', 'سياسة أمن الخدمات السحابية'),
            GrcPolicyKind.scheduled),
        GrcPolicySpec(
            Bi('Mobile Device Security Policy', 'سياسة أمن الأجهزة المحمولة'),
            GrcPolicyKind.scheduled),
        GrcPolicySpec(
            Bi('Zero Trust Architecture Guideline', 'دليل بنية الثقة الصفرية'),
            GrcPolicyKind.draft),
        GrcPolicySpec(
            Bi('Security Logging Standard', 'معيار تسجيل الأحداث الأمنية'),
            GrcPolicyKind.draft),
        GrcPolicySpec(
            Bi('Removable Media Policy', 'سياسة الوسائط القابلة للإزالة'),
            GrcPolicyKind.inactive),
        GrcPolicySpec(
            Bi('Information Security Awareness Plan 2025',
                'خطة التوعية بأمن المعلومات 2025'),
            GrcPolicyKind.expired),
      ],
    ),
    GrcModuleSpec(
      code: 'RM',
      name: Bi('Enterprise Risk Management', 'إدارة المخاطر المؤسسية'),
      description: Bi(
          'Identifies, assesses and treats strategic and operational risks and reports them to the risk committee.',
          'تحديد المخاطر الاستراتيجية والتشغيلية وتقييمها ومعالجتها ورفع تقارير عنها إلى لجنة المخاطر.'),
      kind: GrcModuleKind.active,
      createdMonth: 2,
      createdDay: 10,
      departmentIndex: 2,
      requestsPerStatus: 1,
      controlOffset: 12,
      slots: <String, int>{
        'cH': 2,
        'cA': 2,
        'cB': 1,
        'cC': 1,
        'cD': 1,
        'cE': 2,
        'cI': 1,
        'oC': 1,
        'oD': 1,
        'oE': 2,
        'oF': 1,
        'oG': 1,
        'gD': 1,
        'gE': 1,
        'bg': 3,
        'un': 1,
      },
      policies: <GrcPolicySpec>[
        GrcPolicySpec(Bi('Risk Management Framework', 'إطار إدارة المخاطر'),
            GrcPolicyKind.active),
        GrcPolicySpec(Bi('Risk Appetite Statement', 'بيان تقبّل المخاطر'),
            GrcPolicyKind.active),
        GrcPolicySpec(Bi('Risk Reporting Standard', 'معيار الإبلاغ عن المخاطر'),
            GrcPolicyKind.active),
        GrcPolicySpec(
            Bi('Emerging Risk Monitoring Policy', 'سياسة رصد المخاطر الناشئة'),
            GrcPolicyKind.scheduled),
        GrcPolicySpec(
            Bi('Climate and ESG Risk Guideline',
                'دليل مخاطر المناخ والاستدامة'),
            GrcPolicyKind.draft),
      ],
    ),
    GrcModuleSpec(
      code: 'PD',
      name: Bi('Privacy and Personal Data Protection',
          'الخصوصية وحماية البيانات الشخصية'),
      description: Bi(
          'Protects personal data throughout its life cycle and supports data subject rights in line with the personal data protection law.',
          'حماية البيانات الشخصية طوال دورة حياتها ودعم حقوق أصحابها بما يتوافق مع نظام حماية البيانات الشخصية.'),
      kind: GrcModuleKind.active,
      createdMonth: 3,
      createdDay: 3,
      departmentIndex: 2,
      requestsPerStatus: 1,
      controlOffset: 48,
      slots: <String, int>{
        'cH': 2,
        'cA': 2,
        'cB': 1,
        'cC': 1,
        'cD': 1,
        'cE': 2,
        'cI': 1,
        'oC': 1,
        'oD': 1,
        'oE': 2,
        'oF': 1,
        'oG': 1,
        'gD': 1,
        'gE': 1,
        'bg': 3,
        'un': 1,
      },
      policies: <GrcPolicySpec>[
        GrcPolicySpec(
            Bi('Privacy Policy', 'سياسة الخصوصية'), GrcPolicyKind.active),
        GrcPolicySpec(
            Bi('Data Subject Rights Procedure', 'إجراء حقوق أصحاب البيانات'),
            GrcPolicyKind.active),
        GrcPolicySpec(
            Bi('Personal Data Breach Response Policy',
                'سياسة الاستجابة لتسرب البيانات الشخصية'),
            GrcPolicyKind.active),
        GrcPolicySpec(
            Bi('Privacy by Design Standard', 'معيار الخصوصية بالتصميم'),
            GrcPolicyKind.scheduled),
        GrcPolicySpec(
            Bi('Interim Consent Management Standard',
                'معيار إدارة الموافقات المؤقت'),
            GrcPolicyKind.expired),
      ],
    ),
    GrcModuleSpec(
      code: 'RC',
      name: Bi('Records and Document Management', 'إدارة السجلات والوثائق'),
      description: Bi(
          'Controls the creation, classification, retention and disposal of official records and documents.',
          'ضبط إنشاء السجلات والوثائق الرسمية وتصنيفها والاحتفاظ بها والتخلص منها.'),
      kind: GrcModuleKind.active,
      createdMonth: 4,
      createdDay: 21,
      departmentIndex: 6,
      requestsPerStatus: 1,
      controlOffset: 24,
      slots: <String, int>{
        'cH': 2,
        'cA': 2,
        'cB': 1,
        'cC': 1,
        'cD': 1,
        'cE': 2,
        'cI': 1,
        'oC': 1,
        'oD': 1,
        'oE': 2,
        'oF': 1,
        'oG': 1,
        'gD': 1,
        'gE': 1,
        'bg': 3,
        'un': 1,
      },
      policies: <GrcPolicySpec>[
        GrcPolicySpec(Bi('Records Management Policy', 'سياسة إدارة السجلات'),
            GrcPolicyKind.active),
        GrcPolicySpec(Bi('Document Control Procedure', 'إجراء ضبط الوثائق'),
            GrcPolicyKind.active),
        GrcPolicySpec(
            Bi('Archive and Preservation Policy', 'سياسة الأرشفة والحفظ'),
            GrcPolicyKind.active),
        GrcPolicySpec(Bi('Paper Filing Procedure', 'إجراء الحفظ الورقي'),
            GrcPolicyKind.inactive),
        GrcPolicySpec(
            Bi('Electronic Signature Guideline', 'دليل التوقيع الإلكتروني'),
            GrcPolicyKind.draft),
      ],
    ),
    GrcModuleSpec(
      code: 'BC',
      name: Bi('Business Continuity Management', 'إدارة استمرارية الأعمال'),
      description: Bi(
          'Keeps critical services running through disruption with tested recovery plans and clear crisis roles.',
          'استمرار الخدمات الحرجة أثناء الانقطاع من خلال خطط استعادة مُختبرة وأدوار أزمة واضحة.'),
      kind: GrcModuleKind.active,
      createdMonth: 6,
      createdDay: 9,
      departmentIndex: 7,
      requestsPerStatus: 1,
      controlOffset: 60,
      slots: <String, int>{
        'cH': 2,
        'cA': 2,
        'cB': 1,
        'cC': 1,
        'cD': 1,
        'cE': 2,
        'cI': 1,
        'oC': 1,
        'oD': 1,
        'oE': 2,
        'oF': 1,
        'oG': 1,
        'gD': 1,
        'gE': 1,
        'bg': 3,
        'un': 1,
      },
      policies: <GrcPolicySpec>[
        GrcPolicySpec(
            Bi('Business Continuity Policy', 'سياسة استمرارية الأعمال'),
            GrcPolicyKind.active),
        GrcPolicySpec(
            Bi('Disaster Recovery Standard', 'معيار التعافي من الكوارث'),
            GrcPolicyKind.active),
        GrcPolicySpec(Bi('Crisis Management Plan', 'خطة إدارة الأزمات'),
            GrcPolicyKind.active),
        GrcPolicySpec(Bi('Pandemic Preparedness Plan', 'خطة الجاهزية للأوبئة'),
            GrcPolicyKind.scheduled),
        GrcPolicySpec(
            Bi('Interim Continuity Arrangement 2025',
                'ترتيبات الاستمرارية المؤقتة 2025'),
            GrcPolicyKind.expired),
      ],
    ),

    // Five inactive modules.
    GrcModuleSpec(
      code: 'OD',
      name: Bi('Open Data Publication', 'نشر البيانات المفتوحة'),
      description: Bi(
          'Rules for releasing datasets to the open data portal, paused while the licensing model is reviewed.',
          'قواعد إصدار مجموعات البيانات في بوابة البيانات المفتوحة، متوقفة مؤقتاً أثناء مراجعة نموذج الترخيص.'),
      kind: GrcModuleKind.inactive,
      createdMonth: 2,
      createdDay: 24,
      departmentIndex: 0,
      controlOffset: 5,
      policies: <GrcPolicySpec>[
        GrcPolicySpec(
            Bi('Open Data Release Policy', 'سياسة إصدار البيانات المفتوحة'),
            GrcPolicyKind.active),
        GrcPolicySpec(
            Bi('Dataset Licensing Standard', 'معيار ترخيص مجموعات البيانات'),
            GrcPolicyKind.active),
      ],
    ),
    GrcModuleSpec(
      code: 'TP',
      name:
          Bi('Third-Party and Vendor Risk', 'مخاطر الأطراف الثالثة والموردين'),
      description: Bi(
          'Assessment and monitoring of suppliers that handle data or deliver critical services.',
          'تقييم الموردين الذين يتعاملون مع البيانات أو يقدمون خدمات حرجة ومتابعتهم.'),
      kind: GrcModuleKind.inactive,
      createdMonth: 3,
      createdDay: 17,
      departmentIndex: 5,
      controlOffset: 38,
      policies: <GrcPolicySpec>[
        GrcPolicySpec(
            Bi('Vendor Risk Assessment Policy', 'سياسة تقييم مخاطر الموردين'),
            GrcPolicyKind.active),
        GrcPolicySpec(
            Bi('Outsourcing Governance Standard', 'معيار حوكمة التعهيد'),
            GrcPolicyKind.active),
      ],
    ),
    GrcModuleSpec(
      code: 'IA',
      name: Bi('Internal Audit Programme', 'برنامج التدقيق الداخلي'),
      description: Bi(
          'Annual audit plan, working papers and follow-up of audit observations.',
          'خطة التدقيق السنوية وأوراق العمل ومتابعة ملاحظات التدقيق.'),
      kind: GrcModuleKind.inactive,
      createdMonth: 4,
      createdDay: 7,
      departmentIndex: 3,
      controlOffset: 70,
      policies: <GrcPolicySpec>[
        GrcPolicySpec(Bi('Internal Audit Charter', 'ميثاق التدقيق الداخلي'),
            GrcPolicyKind.active),
        GrcPolicySpec(
            Bi('Audit Sampling Standard', 'معيار اختيار عينات التدقيق'),
            GrcPolicyKind.active),
      ],
    ),
    GrcModuleSpec(
      code: 'SM',
      name: Bi('Social Media and Digital Channels',
          'وسائل التواصل الاجتماعي والقنوات الرقمية'),
      description: Bi(
          'Governance of official accounts, publishing approvals and response times on digital channels.',
          'حوكمة الحسابات الرسمية واعتمادات النشر وأزمنة الاستجابة على القنوات الرقمية.'),
      kind: GrcModuleKind.inactive,
      createdMonth: 5,
      createdDay: 12,
      departmentIndex: 4,
      controlOffset: 80,
      policies: <GrcPolicySpec>[
        GrcPolicySpec(
            Bi('Social Media Use Policy',
                'سياسة استخدام وسائل التواصل الاجتماعي'),
            GrcPolicyKind.active),
        GrcPolicySpec(
            Bi('Official Accounts Management Standard',
                'معيار إدارة الحسابات الرسمية'),
            GrcPolicyKind.active),
      ],
    ),
    GrcModuleSpec(
      code: 'DA',
      name: Bi(
          'Digital Accessibility Compliance', 'الامتثال لإتاحة المحتوى الرقمي'),
      description: Bi(
          'Makes websites, applications and documents usable by everyone, measured against the accessibility guidelines.',
          'جعل المواقع والتطبيقات والوثائق قابلة للاستخدام من الجميع وقياسها وفق إرشادات الإتاحة.'),
      kind: GrcModuleKind.inactive,
      createdMonth: 7,
      createdDay: 2,
      departmentIndex: 1,
      controlOffset: 86,
      policies: <GrcPolicySpec>[
        GrcPolicySpec(
            Bi('Digital Accessibility Policy', 'سياسة إتاحة المحتوى الرقمي'),
            GrcPolicyKind.active),
        GrcPolicySpec(
            Bi('Accessible Content Authoring Guideline',
                'دليل إعداد المحتوى المتاح'),
            GrcPolicyKind.active),
      ],
    ),

    // Five scheduled modules (activation date still ahead).
    GrcModuleSpec(
      code: 'MC',
      name: Bi('Media Content Standards 2027', 'معايير المحتوى الإعلامي 2027'),
      description: Bi(
          'Editorial standards, fact-checking and rights clearance for content published from January 2027.',
          'المعايير التحريرية والتحقق من الحقائق وتسوية الحقوق للمحتوى الذي يُنشر اعتباراً من يناير 2027.'),
      kind: GrcModuleKind.scheduled,
      createdMonth: 8,
      createdDay: 4,
      activationMonth: 1,
      activationDay: 4,
      activationNextYear: true,
      departmentIndex: 4,
      controlOffset: 80,
      policies: <GrcPolicySpec>[
        GrcPolicySpec(
            Bi('Editorial Standards Policy', 'سياسة المعايير التحريرية'),
            GrcPolicyKind.scheduled),
        GrcPolicySpec(Bi('Fact-Checking Procedure', 'إجراء التحقق من الحقائق'),
            GrcPolicyKind.draft),
      ],
    ),
    GrcModuleSpec(
      code: 'AF',
      name: Bi('Anti-Fraud and Integrity', 'مكافحة الاحتيال والنزاهة'),
      description: Bi(
          'Prevention, detection and reporting of fraud, with declarations of interest and a confidential reporting channel.',
          'منع الاحتيال وكشفه والإبلاغ عنه، مع إقرارات المصالح وقناة بلاغات سرية.'),
      kind: GrcModuleKind.scheduled,
      createdMonth: 8,
      createdDay: 26,
      activationMonth: 11,
      activationDay: 15,
      departmentIndex: 3,
      controlOffset: 40,
      policies: <GrcPolicySpec>[
        GrcPolicySpec(Bi('Anti-Fraud Policy', 'سياسة مكافحة الاحتيال'),
            GrcPolicyKind.scheduled),
        GrcPolicySpec(Bi('Conflict of Interest Policy', 'سياسة تعارض المصالح'),
            GrcPolicyKind.draft),
      ],
    ),
    GrcModuleSpec(
      code: 'DT',
      name: Bi('Digital Transformation Standard (Qiyas)',
          'معيار التحول الرقمي (قياس)'),
      description: Bi(
          'Evidence collection and tracking for the national digital transformation measurement cycle.',
          'جمع الأدلة ومتابعتها لدورة قياس التحول الرقمي الوطنية.'),
      kind: GrcModuleKind.scheduled,
      createdMonth: 9,
      createdDay: 8,
      activationMonth: 12,
      activationDay: 1,
      departmentIndex: 7,
      controlOffset: 54,
      policies: <GrcPolicySpec>[
        GrcPolicySpec(
            Bi('Digital Maturity Assessment Procedure',
                'إجراء تقييم النضج الرقمي'),
            GrcPolicyKind.scheduled),
        GrcPolicySpec(Bi('Digital Services Standard', 'معيار الخدمات الرقمية'),
            GrcPolicyKind.scheduled),
      ],
    ),
    GrcModuleSpec(
      code: 'MQ',
      name:
          Bi('Master Data Quality Programme', 'برنامج جودة البيانات الرئيسية'),
      description: Bi(
          'Quality rules, cleansing cycles and scorecards for the supplier, employee and asset master data.',
          'قواعد الجودة ودورات التنقية وبطاقات القياس للبيانات الرئيسية للموردين والموظفين والأصول.'),
      kind: GrcModuleKind.scheduled,
      createdMonth: 9,
      createdDay: 22,
      activationMonth: 12,
      activationDay: 15,
      departmentIndex: 0,
      controlOffset: 14,
      policies: <GrcPolicySpec>[
        GrcPolicySpec(
            Bi('Master Data Quality Rules', 'قواعد جودة البيانات الرئيسية'),
            GrcPolicyKind.scheduled),
        GrcPolicySpec(Bi('Data Cleansing Procedure', 'إجراء تنقية البيانات'),
            GrcPolicyKind.draft),
      ],
    ),
    GrcModuleSpec(
      code: 'CS',
      name: Bi('Cloud Services Governance', 'حوكمة الخدمات السحابية'),
      description: Bi(
          'Approval, configuration baseline and exit planning for cloud services used by the organisation.',
          'اعتماد الخدمات السحابية المستخدمة في المنظمة وخط أساس إعداداتها وتخطيط الخروج منها.'),
      kind: GrcModuleKind.scheduled,
      createdMonth: 10,
      createdDay: 6,
      activationMonth: 11,
      activationDay: 1,
      departmentIndex: 1,
      controlOffset: 72,
      policies: <GrcPolicySpec>[
        GrcPolicySpec(
            Bi('Cloud Adoption Policy', 'سياسة تبني الخدمات السحابية'),
            GrcPolicyKind.scheduled),
        GrcPolicySpec(
            Bi('Cloud Exit Strategy Standard',
                'معيار استراتيجية الخروج من السحابة'),
            GrcPolicyKind.draft),
      ],
    ),

    // Five removed modules.
    GrcModuleSpec(
      code: 'LA',
      name: Bi('Legacy Archive Retention', 'الاحتفاظ بالأرشيف القديم'),
      description: Bi(
          'Retention rules for the pre-2020 paper archive, closed after the digitisation project.',
          'قواعد الاحتفاظ بالأرشيف الورقي السابق لعام 2020، أُغلقت بعد انتهاء مشروع الرقمنة.'),
      kind: GrcModuleKind.removed,
      createdMonth: 1,
      createdDay: 14,
      removedMonth: 6,
      departmentIndex: 6,
      controlOffset: 26,
      policies: <GrcPolicySpec>[
        GrcPolicySpec(
            Bi('Legacy Archive Retention Rules',
                'قواعد الاحتفاظ بالأرشيف القديم'),
            GrcPolicyKind.active),
        GrcPolicySpec(
            Bi('Archive Disposal Procedure', 'إجراء التخلص من الأرشيف'),
            GrcPolicyKind.active),
      ],
    ),
    GrcModuleSpec(
      code: 'PP',
      name: Bi('Pilot Procurement Controls', 'ضوابط المشتريات التجريبية'),
      description: Bi(
          'Controls tested on a pilot group of tenders, replaced by the corporate procurement module.',
          'ضوابط جُرّبت على مجموعة تجريبية من المناقصات، واستُبدلت بوحدة المشتريات المؤسسية.'),
      kind: GrcModuleKind.removed,
      createdMonth: 2,
      createdDay: 3,
      removedMonth: 7,
      departmentIndex: 5,
      controlOffset: 42,
      policies: <GrcPolicySpec>[
        GrcPolicySpec(
            Bi('Pilot Procurement Policy', 'سياسة المشتريات التجريبية'),
            GrcPolicyKind.active),
        GrcPolicySpec(Bi('Tender Evaluation Guideline', 'دليل تقييم العطاءات'),
            GrcPolicyKind.active),
      ],
    ),
    GrcModuleSpec(
      code: 'ER',
      name: Bi('Interim Editorial Policy Review',
          'مراجعة السياسة التحريرية المؤقتة'),
      description: Bi(
          'One-off review of the interim editorial policy, completed and merged into the media standards.',
          'مراجعة لمرة واحدة للسياسة التحريرية المؤقتة، اكتملت ودُمجت في معايير المحتوى الإعلامي.'),
      kind: GrcModuleKind.removed,
      createdMonth: 3,
      createdDay: 25,
      removedMonth: 8,
      departmentIndex: 4,
      controlOffset: 82,
      policies: <GrcPolicySpec>[
        GrcPolicySpec(
            Bi('Interim Editorial Policy', 'السياسة التحريرية المؤقتة'),
            GrcPolicyKind.active),
        GrcPolicySpec(
            Bi('Correction Procedure', 'إجراء التصحيح'), GrcPolicyKind.active),
      ],
    ),
    GrcModuleSpec(
      code: 'CP',
      name: Bi('2025 Compliance Programme', 'برنامج الامتثال 2025'),
      description: Bi(
          'Last year\'s compliance programme, closed after the year-end report was accepted.',
          'برنامج الامتثال للعام الماضي، أُغلق بعد قبول تقرير نهاية العام.'),
      kind: GrcModuleKind.removed,
      createdMonth: 1,
      createdDay: 28,
      removedMonth: 4,
      departmentIndex: 2,
      controlOffset: 56,
      policies: <GrcPolicySpec>[
        GrcPolicySpec(Bi('2025 Compliance Plan', 'خطة الامتثال 2025'),
            GrcPolicyKind.active),
        GrcPolicySpec(
            Bi('Compliance Reporting Standard 2025',
                'معيار الإبلاغ عن الامتثال 2025'),
            GrcPolicyKind.active),
      ],
    ),
    GrcModuleSpec(
      code: 'RN',
      name: Bi('Records Migration Project', 'مشروع ترحيل السجلات'),
      description: Bi(
          'Controls for the migration of records to the new document system, closed at go-live.',
          'ضوابط ترحيل السجلات إلى نظام الوثائق الجديد، أُغلقت عند التشغيل الفعلي.'),
      kind: GrcModuleKind.removed,
      createdMonth: 4,
      createdDay: 15,
      removedMonth: 9,
      departmentIndex: 6,
      controlOffset: 66,
      policies: <GrcPolicySpec>[
        GrcPolicySpec(Bi('Records Migration Policy', 'سياسة ترحيل السجلات'),
            GrcPolicyKind.active),
        GrcPolicySpec(
            Bi('Migration Validation Procedure', 'إجراء التحقق من الترحيل'),
            GrcPolicyKind.active),
      ],
    ),
  ];

  // ── Policy descriptions (picked by index) ─────────────────────────────
  static const List<Bi> policyDescriptions = <Bi>[
    Bi('Defines the principles, roles and minimum requirements that apply across all departments, reviewed annually by the policy owner.',
        'تحدد المبادئ والأدوار والحد الأدنى من المتطلبات المطبقة في جميع الإدارات، وتُراجع سنوياً من مالك السياسة.'),
    Bi('Sets the standards every department must follow, the evidence required to prove compliance and the escalation path for exceptions.',
        'تضع المعايير التي يجب على كل إدارة الالتزام بها، والأدلة المطلوبة لإثبات الامتثال، ومسار تصعيد الاستثناءات.'),
    Bi('Describes how the subject is governed, monitored and reported to the governance committee each quarter.',
        'توضح كيفية حوكمة الموضوع ومتابعته ورفع تقارير عنه إلى لجنة الحوكمة كل ربع سنة.'),
    Bi('Establishes responsibilities, controls and the review cycle, aligned with national regulations and the organisation\'s risk appetite.',
        'ترسي المسؤوليات والضوابط ودورة المراجعة، بما يتوافق مع الأنظمة الوطنية ومستوى تقبّل المخاطر في المنظمة.'),
  ];

  // ── Control names (generic enough to be reused across modules) ────────
  static const List<Bi> controls = <Bi>[
    Bi('Quarterly user access rights review',
        'مراجعة صلاحيات المستخدمين ربع السنوية'),
    Bi('Privileged account monitoring',
        'مراقبة الحسابات ذات الصلاحيات العالية'),
    Bi('Joiner, mover and leaver access check',
        'التحقق من صلاحيات المنضمين والمنتقلين والمغادرين'),
    Bi('Password policy enforcement check',
        'التحقق من تطبيق سياسة كلمات المرور'),
    Bi('Multi-factor authentication coverage', 'تغطية المصادقة متعددة العوامل'),
    Bi('Monthly vulnerability scan review', 'مراجعة فحص الثغرات الشهري'),
    Bi('Annual penetration test follow-up', 'متابعة اختبار الاختراق السنوي'),
    Bi('Security patch compliance', 'الامتثال لتحديثات الحماية'),
    Bi('Backup completion verification', 'التحقق من اكتمال النسخ الاحتياطي'),
    Bi('Quarterly backup restoration test',
        'اختبار استعادة النسخ الاحتياطي ربع السنوي'),
    Bi('Firewall rule review', 'مراجعة قواعد جدار الحماية'),
    Bi('Security incident register review', 'مراجعة سجل الحوادث الأمنية'),
    Bi('Security awareness training completion',
        'إتمام التدريب على الوعي الأمني'),
    Bi('Phishing simulation results', 'نتائج محاكاة التصيد الإلكتروني'),
    Bi('Data classification labelling check', 'التحقق من وسم تصنيف البيانات'),
    Bi('Critical data elements register update',
        'تحديث سجل عناصر البيانات الحرجة'),
    Bi('Data owner and steward confirmation', 'تأكيد مالكي البيانات وأمنائها'),
    Bi('Business glossary approval', 'اعتماد المصطلحات التعريفية للأعمال'),
    Bi('Data quality scorecard publication', 'نشر بطاقة قياس جودة البيانات'),
    Bi('Duplicate records resolution', 'معالجة السجلات المكررة'),
    Bi('Data lineage documentation', 'توثيق مسار البيانات'),
    Bi('Metadata completeness check', 'التحقق من اكتمال البيانات الوصفية'),
    Bi('Data sharing agreement review', 'مراجعة اتفاقيات مشاركة البيانات'),
    Bi('Open data release approval', 'اعتماد إصدار البيانات المفتوحة'),
    Bi('Master data change approval', 'اعتماد تغييرات البيانات الرئيسية'),
    Bi('Data retention schedule review', 'مراجعة جدول الاحتفاظ بالبيانات'),
    Bi('Records destruction approval', 'اعتماد إتلاف السجلات'),
    Bi('Archive integrity check', 'التحقق من سلامة الأرشيف'),
    Bi('Document version control audit', 'تدقيق ضبط إصدارات الوثائق'),
    Bi('Policy acknowledgement tracking', 'متابعة إقرار الموظفين بالسياسات'),
    Bi('Annual policy review', 'المراجعة السنوية للسياسات'),
    Bi('Exception register review', 'مراجعة سجل الاستثناءات'),
    Bi('Risk register update', 'تحديث سجل المخاطر'),
    Bi('Risk assessment for new projects', 'تقييم المخاطر للمشاريع الجديدة'),
    Bi('Risk treatment plan follow-up', 'متابعة خطط معالجة المخاطر'),
    Bi('Key risk indicator reporting', 'رفع تقارير مؤشرات المخاطر الرئيسية'),
    Bi('Risk appetite compliance check',
        'التحقق من الالتزام بمستوى تقبّل المخاطر'),
    Bi('Residual risk acceptance sign-off', 'اعتماد قبول المخاطر المتبقية'),
    Bi('Third-party risk assessment', 'تقييم مخاطر الأطراف الثالثة'),
    Bi('Supplier due diligence review', 'مراجعة العناية الواجبة للموردين'),
    Bi('Contract compliance clauses check',
        'التحقق من بنود الامتثال في العقود'),
    Bi('Vendor performance review', 'مراجعة أداء الموردين'),
    Bi('Procurement approval workflow check',
        'التحقق من مسار اعتماد المشتريات'),
    Bi('Conflict of interest declarations', 'إقرارات تعارض المصالح'),
    Bi('Gifts and hospitality register', 'سجل الهدايا والضيافة'),
    Bi('Whistleblowing channel testing', 'اختبار قناة الإبلاغ عن المخالفات'),
    Bi('Anti-fraud controls testing', 'اختبار ضوابط مكافحة الاحتيال'),
    Bi('Segregation of duties review', 'مراجعة الفصل بين المهام'),
    Bi('Financial approval limits check', 'التحقق من حدود الصلاحيات المالية'),
    Bi('Internal audit findings closure', 'إغلاق ملاحظات التدقيق الداخلي'),
    Bi('External audit evidence pack', 'حزمة أدلة التدقيق الخارجي'),
    Bi('Regulatory change monitoring', 'رصد التغييرات التنظيمية'),
    Bi('Regulatory return submission', 'رفع التقارير الرقابية'),
    Bi('Compliance self-assessment', 'التقييم الذاتي للامتثال'),
    Bi('Compliance training attendance', 'حضور تدريب الامتثال'),
    Bi('Personal data inventory update', 'تحديث سجل البيانات الشخصية'),
    Bi('Consent records verification', 'التحقق من سجلات الموافقة'),
    Bi('Data subject request handling', 'معالجة طلبات أصحاب البيانات'),
    Bi('Privacy impact assessment review', 'مراجعة تقييم الأثر على الخصوصية'),
    Bi('Personal data breach drill', 'تمرين الاستجابة لتسرب البيانات الشخصية'),
    Bi('Cross-border transfer approval', 'اعتماد النقل خارج الحدود'),
    Bi('Cookie and tracking notice check',
        'التحقق من إشعار ملفات تعريف الارتباط'),
    Bi('Business impact analysis refresh', 'تحديث تحليل أثر الأعمال'),
    Bi('Recovery time objective testing', 'اختبار أهداف زمن الاستعادة'),
    Bi('Disaster recovery drill', 'تمرين التعافي من الكوارث'),
    Bi('Crisis communication plan test', 'اختبار خطة الاتصال في الأزمات'),
    Bi('Alternate site readiness check', 'التحقق من جاهزية الموقع البديل'),
    Bi('Emergency contact list verification',
        'التحقق من قائمة جهات الاتصال للطوارئ'),
    Bi('Critical supplier continuity plans', 'خطط استمرارية الموردين الحرجين'),
    Bi('Change management approval check', 'التحقق من اعتماد إدارة التغيير'),
    Bi('Release readiness review', 'مراجعة جاهزية الإصدارات'),
    Bi('Asset inventory reconciliation', 'مطابقة سجل الأصول'),
    Bi('Software licence compliance check',
        'التحقق من الامتثال لتراخيص البرمجيات'),
    Bi('Cloud configuration baseline review',
        'مراجعة الإعدادات الأساسية للخدمات السحابية'),
    Bi('Log retention and monitoring review',
        'مراجعة الاحتفاظ بالسجلات والمراقبة'),
    Bi('Encryption key rotation', 'تدوير مفاتيح التشفير'),
    Bi('Mobile device compliance check', 'التحقق من امتثال الأجهزة المحمولة'),
    Bi('Remote access approval review', 'مراجعة اعتماد الوصول عن بُعد'),
    Bi('Physical access log review', 'مراجعة سجلات الدخول المادي'),
    Bi('Clean desk inspection', 'فحص مكاتب العمل'),
    Bi('Editorial standards compliance review',
        'مراجعة الالتزام بالمعايير التحريرية'),
    Bi('Source verification checklist', 'قائمة التحقق من المصادر'),
    Bi('Media asset rights and licences check',
        'التحقق من حقوق وتراخيص الأصول الإعلامية'),
    Bi('Corrections and retractions log', 'سجل التصحيحات والتراجعات'),
    Bi('Embargo and release timing control', 'ضبط الحظر الإعلامي وتوقيت النشر'),
    Bi('Social media account access review',
        'مراجعة صلاحيات حسابات التواصل الاجتماعي'),
    Bi('Press release approval workflow', 'مسار اعتماد البيانات الصحفية'),
    Bi('Accessibility conformance check', 'التحقق من الامتثال لمعايير الإتاحة'),
    Bi('Service level agreement reporting', 'رفع تقارير اتفاقيات مستوى الخدمة'),
    Bi('Customer complaints trend review', 'مراجعة اتجاهات الشكاوى'),
    Bi('Knowledge base accuracy review', 'مراجعة دقة قاعدة المعرفة'),
    Bi('Management review meeting minutes', 'محاضر اجتماعات المراجعة الإدارية'),
    Bi('Corrective action tracking', 'متابعة الإجراءات التصحيحية'),
    Bi('Internal control self-testing', 'الاختبار الذاتي للضوابط الداخلية'),
    Bi('Data protection impact register', 'سجل أثر حماية البيانات'),
    Bi('Digital certificate expiry monitoring',
        'مراقبة انتهاء الشهادات الرقمية'),
  ];

  /// Three phrasings of a control description; `%` is replaced by the name.
  static const List<Bi> controlDescriptions = <Bi>[
    Bi('Evidence that "%" was carried out for the period, reviewed and signed off by the control owner.',
        'دليل على تنفيذ «%» خلال الفترة ومراجعته واعتماده من مالك الضابط.'),
    Bi('Complete the "%" activity and attach the supporting report or log for the audit trail.',
        'إتمام نشاط «%» وإرفاق التقرير أو السجل الداعم لمسار التدقيق.'),
    Bi('Confirm that "%" meets the required standard and record any exceptions with their owners.',
        'التأكد من استيفاء «%» للمعيار المطلوب وتسجيل الاستثناءات مع أصحابها.'),
  ];

  // ── Evidence submissions ──────────────────────────────────────────────
  static const List<Bi> submissionNotes = <Bi>[
    Bi('Evidence for the period is attached and has been reviewed by the control owner.',
        'الدليل الخاص بالفترة مرفق وقد راجعه مالك الضابط.'),
    Bi('Please find the signed report and the supporting log extract.',
        'مرفق التقرير الموقع ومقتطف السجل الداعم.'),
    Bi('All exceptions found in the period are listed in the last page with their owners.',
        'جميع الاستثناءات المرصودة في الفترة مدرجة في الصفحة الأخيرة مع أصحابها.'),
    Bi('Submitted on time. Screenshots were taken from the production system.',
        'تم الرفع في الموعد. أُخذت لقطات الشاشة من النظام الفعلي.'),
    Bi('This is the monthly extract; the quarterly summary follows next week.',
        'هذا هو المستخرج الشهري، وسيصل الملخص الربعي الأسبوع القادم.'),
    Bi('Updated version after the comments received from the department manager.',
        'نسخة محدثة بعد الملاحظات الواردة من مدير الإدارة.'),
    Bi('Evidence covers all departments in scope, including the new unit.',
        'الدليل يغطي جميع الإدارات المشمولة بما فيها الوحدة الجديدة.'),
    Bi('Attached the review sheet with dates and approvers for each item.',
        'مرفق نموذج المراجعة متضمناً التواريخ والمعتمدين لكل بند.'),
  ];

  static const List<Bi> managerRejections = <Bi>[
    Bi('The attached file is not signed. Please attach the signed version.',
        'الملف المرفق غير موقّع. يرجى إرفاق النسخة الموقعة.'),
    Bi('The evidence covers only part of the period. Please attach the full period.',
        'الدليل يغطي جزءاً من الفترة فقط. يرجى إرفاق الفترة كاملة.'),
    Bi('The report does not show the date of execution. Please resubmit with the date visible.',
        'التقرير لا يوضح تاريخ التنفيذ. يرجى إعادة الرفع مع إظهار التاريخ.'),
    Bi('The attached document is a previous version of the template.',
        'المستند المرفق نسخة سابقة من النموذج.'),
    Bi('Exceptions are mentioned but without owners. Please list the owner of each exception.',
        'ذُكرت استثناءات دون تحديد أصحابها. يرجى إضافة المسؤول عن كل استثناء.'),
    Bi('The screenshot is unreadable. Please attach a clear export.',
        'لقطة الشاشة غير واضحة. يرجى إرفاق تصدير واضح.'),
  ];

  static const List<Bi> managerApprovals = <Bi>[
    Bi('Evidence is complete and consistent with the control description.',
        'الدليل مكتمل ومتوافق مع وصف الضابط.'),
    Bi('Reviewed with no remarks.', 'تمت المراجعة دون ملاحظات.'),
    Bi('Approved. Please keep the original file in the department register.',
        'تم الاعتماد. يرجى الاحتفاظ بالأصل في سجل الإدارة.'),
    Bi('Clear and well documented, approved.',
        'واضح وموثق جيداً، تم الاعتماد.'),
    Bi('Approved after the clarification in the inquiries thread.',
        'تم الاعتماد بعد التوضيح في محادثة الاستفسارات.'),
  ];

  static const List<Bi> ownerRejections = <Bi>[
    Bi('The sample size is below the agreed minimum.',
        'حجم العينة أقل من الحد الأدنى المتفق عليه.'),
    Bi('The results contradict the figures reported for the previous period.',
        'النتائج تتعارض مع الأرقام المرفوعة للفترة السابقة.'),
    Bi('The approver named in the evidence is no longer in that role.',
        'المعتمِد المذكور في الدليل لم يعد في هذا الدور.'),
    Bi('The test was performed outside the control period.',
        'أُجري الاختبار خارج فترة الضابط.'),
    Bi('Please provide the supporting log extract.',
        'يرجى تزويدنا بمقتطف السجل الداعم.'),
  ];

  static const List<Bi> scoreJustifications = <Bi>[
    Bi('Evidence is complete and covers the whole period; no exceptions found.',
        'الدليل مكتمل ويغطي الفترة كاملة ولا توجد استثناءات.'),
    Bi('Control performed on time with minor documentation gaps.',
        'نُفّذ الضابط في موعده مع نواقص بسيطة في التوثيق.'),
    Bi('Two exceptions were recorded and closed within the agreed time.',
        'سُجل استثناءان وأُغلقا خلال المدة المتفق عليها.'),
    Bi('Partial coverage of departments; a follow-up action was agreed.',
        'تغطية جزئية للإدارات، وتم الاتفاق على إجراء متابعة.'),
    Bi('Strong evidence and clear ownership across the period.',
        'أدلة قوية وملكية واضحة طوال الفترة.'),
    Bi('Results are consistent with the previous period.',
        'النتائج متسقة مع الفترة السابقة.'),
    Bi('Evidence is acceptable but the sampling method needs to be documented.',
        'الدليل مقبول لكن يلزم توثيق طريقة اختيار العينات.'),
    Bi('Several items were closed late; the score reflects the delay.',
        'أُغلقت عدة بنود متأخرة، والدرجة تعكس التأخير.'),
  ];

  // ── Request notes ─────────────────────────────────────────────────────
  static const List<Bi> requestNotes = <Bi>[
    Bi('The current assignee has moved to another project.',
        'انتقل المكلّف الحالي إلى مشروع آخر.'),
    Bi('Workload balance across the team.', 'موازنة أعباء العمل بين الفريق.'),
    Bi('The new assignee manages this area day to day.',
        'المكلّف الجديد يدير هذا المجال يومياً.'),
    Bi('Planned leave during the next control period.',
        'إجازة مخططة خلال فترة الضابط القادمة.'),
    Bi('Reorganisation of the department responsibilities.',
        'إعادة تنظيم مسؤوليات الإدارة.'),
    Bi('Handover agreed in the monthly governance meeting.',
        'تم الاتفاق على التسليم في اجتماع الحوكمة الشهري.'),
  ];

  static const List<Bi> requestRejections = <Bi>[
    Bi('The proposed assignee already owns too many controls this quarter.',
        'المكلّف المقترح يملك عدداً كبيراً من الضوابط هذا الربع.'),
    Bi('Please wait until the current evidence cycle is closed.',
        'يرجى الانتظار حتى إغلاق دورة الأدلة الحالية.'),
    Bi('The department head did not confirm the handover.',
        'لم يؤكد رئيس الإدارة عملية التسليم.'),
  ];

  // ── Comment threads: manager <-> champion on one piece of evidence ────
  static const List<List<Bi>> approvalThreads = <List<Bi>>[
    <Bi>[
      Bi('Please attach the signed approval page; the current file ends before the sign-off.',
          'يرجى إرفاق صفحة الاعتماد الموقعة، فالملف الحالي ينتهي قبل التوقيع.'),
      Bi('Understood, I will upload the signed version today.',
          'تم، سأرفع النسخة الموقعة اليوم.'),
      Bi('The signed version is attached now, please review.',
          'تم إرفاق النسخة الموقعة، يرجى المراجعة.'),
      Bi('Received, thank you. I will complete the review shortly.',
          'استلمتها، شكراً لك. سأُكمل المراجعة قريباً.'),
    ],
    <Bi>[
      Bi('The report covers July and August only. Is September included elsewhere?',
          'التقرير يغطي يوليو وأغسطس فقط. هل سبتمبر مشمول في موضع آخر؟'),
      Bi('September is in the second sheet of the workbook, I will add a note on the first page.',
          'سبتمبر في الورقة الثانية من الملف، وسأضيف ملاحظة في الصفحة الأولى.'),
      Bi('Thank you. Please also confirm the number of systems in scope.',
          'شكراً لك. يرجى أيضاً تأكيد عدد الأنظمة المشمولة.'),
      Bi('Twelve systems, the same list as the previous period.',
          'اثنا عشر نظاماً، وهي نفس قائمة الفترة السابقة.'),
      Bi('Clear. Approving now.', 'واضح. سأعتمد الآن.'),
    ],
    <Bi>[
      Bi('Can you explain the three exceptions listed on page 4?',
          'هل يمكنك شرح الاستثناءات الثلاثة المذكورة في الصفحة 4؟'),
      Bi('Two were closed within the week. The third is waiting for the supplier and is tracked in the register.',
          'أُغلق استثناءان خلال الأسبوع، والثالث بانتظار المورد ومتابَع في السجل.'),
      Bi('Please add the register reference to the report.',
          'يرجى إضافة مرجع السجل إلى التقرير.'),
      Bi('Added in the new version.', 'تمت الإضافة في النسخة الجديدة.'),
    ],
    <Bi>[
      Bi('The screenshots have no visible date. Could you re-export them with the system clock?',
          'لقطات الشاشة لا تُظهر التاريخ. هل يمكنك إعادة تصديرها مع ساعة النظام؟'),
      Bi('Yes, I will retake them from the production console.',
          'نعم، سأعيد التقاطها من وحدة التحكم الفعلية.'),
      Bi('New screenshots attached, the date is in the top bar.',
          'أُرفقت لقطات جديدة، والتاريخ في الشريط العلوي.'),
    ],
    <Bi>[
      Bi('Is this the latest version of the template approved by the committee?',
          'هل هذه أحدث نسخة من النموذج المعتمد من اللجنة؟'),
      Bi('It is version 3.1, approved in the March meeting.',
          'هي النسخة 3.1 المعتمدة في اجتماع مارس.'),
      Bi('Thank you, that matches the register. Continuing the review.',
          'شكراً لك، وهذا يطابق السجل. أواصل المراجعة.'),
      Bi('Please let me know if anything else is needed.',
          'أخبرني إن لزم أي شيء آخر.'),
    ],
    <Bi>[
      Bi('The submission arrived after the cut-off. I will accept it this time, but please plan earlier.',
          'وصل الرفع بعد الموعد النهائي. سأقبله هذه المرة، لكن يرجى التخطيط مبكراً.'),
      Bi('Thank you, the delay was caused by the system maintenance window.',
          'شكراً لك، سبب التأخير نافذة صيانة النظام.'),
      Bi('Understood. Please note it in the exceptions register.',
          'مفهوم. يرجى تسجيله في سجل الاستثناءات.'),
      Bi('Done.', 'تم.'),
    ],
  ];

  // ── Comment threads: owner <-> champion on an audited control ─────────
  static const List<List<Bi>> auditThreads = <List<Bi>>[
    <Bi>[
      Bi('I reviewed the evidence. Which sample did you use for the testing?',
          'راجعتُ الدليل. ما العينة التي اعتمدتها في الاختبار؟'),
      Bi('We tested 25 items selected randomly from the full population of 140.',
          'اختبرنا 25 بنداً مختارة عشوائياً من إجمالي 140.'),
      Bi('Good. Please document the selection method in the report.',
          'جيد. يرجى توثيق طريقة الاختيار في التقرير.'),
      Bi('I will add a paragraph and resubmit this week.',
          'سأضيف فقرة وأعيد الرفع هذا الأسبوع.'),
    ],
    <Bi>[
      Bi('The result is lower than last quarter. What changed?',
          'النتيجة أقل من الربع الماضي. ما الذي تغيّر؟'),
      Bi('Two new systems were added to the scope and their configuration was not yet aligned.',
          'أُضيف نظامان جديدان إلى النطاق ولم تكن إعداداتهما متوافقة بعد.'),
      Bi('Understood. Is there a remediation date?',
          'مفهوم. هل هناك موعد للمعالجة؟'),
      Bi('Yes, the end of next month. It is tracked in the action plan.',
          'نعم، نهاية الشهر القادم، وهو مسجل في خطة العمل.'),
      Bi('Thank you. I will score based on the plan.',
          'شكراً لك. سأحتسب الدرجة بناءً على الخطة.'),
    ],
    <Bi>[
      Bi('Could you confirm who approved the exception on item 12?',
          'هل يمكنك تأكيد من اعتمد الاستثناء في البند 12؟'),
      Bi('The head of the department approved it by email on the 14th.',
          'اعتمده رئيس الإدارة عبر البريد الإلكتروني في 14 من الشهر.'),
      Bi('Please attach that email to the evidence.',
          'يرجى إرفاق ذلك البريد بالدليل.'),
      Bi('Attached.', 'تم الإرفاق.'),
    ],
    <Bi>[
      Bi('The evidence is complete. I have one remark about the file naming.',
          'الدليل مكتمل. لدي ملاحظة واحدة حول تسمية الملفات.'),
      Bi('Happy to align, which format do you prefer?',
          'يسعدني التوافق، ما الصيغة التي تفضلها؟'),
      Bi('Control number, period and version, for example DG-C-014_Q3_v2.',
          'رقم الضابط ثم الفترة ثم النسخة، مثل DG-C-014_Q3_v2.'),
      Bi('I will apply it from the next period.',
          'سأطبقها ابتداءً من الفترة القادمة.'),
    ],
    <Bi>[
      Bi('The test date is outside the control period. Can you clarify?',
          'تاريخ الاختبار خارج فترة الضابط. هل يمكنك التوضيح؟'),
      Bi('The test was done on the first working day after the period closed because of the holiday.',
          'أُجري الاختبار في أول يوم عمل بعد إغلاق الفترة بسبب الإجازة.'),
      Bi('Accepted. Please add that explanation to the notes.',
          'مقبول. يرجى إضافة هذا التوضيح إلى الملاحظات.'),
    ],
    <Bi>[
      Bi('Thank you for the quick submission this month.',
          'شكراً لك على سرعة الرفع هذا الشهر.'),
      Bi('Thank you. The new checklist helped a lot.',
          'شكراً لك. ساعدتنا قائمة التحقق الجديدة كثيراً.'),
      Bi('I will share it with the other champions in the next meeting.',
          'سأشاركها مع بقية المسؤولين في الاجتماع القادم.'),
      Bi('Great, I can present it if useful.',
          'ممتاز، يمكنني عرضها إن كان ذلك مفيداً.'),
    ],
  ];

  // ── Comment threads: reporting and audit (management level) ───────────
  static const List<List<Bi>> departmentThreads = <List<Bi>>[
    <Bi>[
      Bi('The compliance score moved up this quarter. Which controls drove the change?',
          'ارتفعت درجة الامتثال هذا الربع. ما الضوابط التي ساهمت في التحسن؟'),
      Bi('Mainly the access reviews and the backup tests, both now completed on time.',
          'بشكل رئيسي مراجعات الصلاحيات واختبارات النسخ الاحتياطي، وكلاهما أصبح يُنجز في موعده.'),
      Bi('Please add that to the committee pack.',
          'يرجى إضافة ذلك إلى ملف اللجنة.'),
      Bi('Added to the pack for the next meeting.',
          'أُضيف إلى الملف للاجتماع القادم.'),
    ],
    <Bi>[
      Bi('Three controls remain below the baseline. Who owns the recovery plan?',
          'ما زالت ثلاثة ضوابط دون الحد الأدنى. من المسؤول عن خطة التعافي؟'),
      Bi('Each control owner has a plan with dates; I will consolidate them in one view.',
          'لدى كل مالك ضابط خطة بتواريخ، وسأجمعها في عرض واحد.'),
      Bi('Thank you. I need it before the audit kick-off.',
          'شكراً لك. أحتاجها قبل بدء التدقيق.'),
    ],
    <Bi>[
      Bi('Can we see the trend for this department over the last six months?',
          'هل يمكننا الاطلاع على اتجاه هذه الإدارة خلال الأشهر الستة الماضية؟'),
      Bi('The chart above shows it. The dip in July was the system migration.',
          'يوضحه الرسم أعلاه. الانخفاض في يوليو كان بسبب ترحيل النظام.'),
      Bi('Understood. Please note it as a known cause in the report.',
          'مفهوم. يرجى تسجيله كسبب معروف في التقرير.'),
      Bi('Noted.', 'تم التسجيل.'),
    ],
    <Bi>[
      Bi('The external auditors asked for evidence of the quarterly review. Is it ready?',
          'طلب المدققون الخارجيون دليلاً على المراجعة الربعية. هل هو جاهز؟'),
      Bi('Yes, it is under Approved Evidence for this policy.',
          'نعم، موجود ضمن الأدلة المعتمدة لهذه السياسة.'),
      Bi('Perfect, I will share the export with them.',
          'ممتاز، سأرسل لهم التصدير.'),
    ],
    <Bi>[
      Bi('Why is this policy missing from the Arabic report?',
          'لماذا هذه السياسة غير موجودة في التقرير العربي؟'),
      Bi('The Arabic document was uploaded yesterday; the report will include it from tomorrow.',
          'رُفع المستند العربي أمس، وسيظهر في التقرير ابتداءً من الغد.'),
      Bi('Thank you for the quick fix.', 'شكراً لك على المعالجة السريعة.'),
    ],
    <Bi>[
      Bi('Please remind the owners that the evidence cut-off is the 25th.',
          'يرجى تذكير الملاك بأن الموعد النهائي للأدلة هو يوم 25.'),
      Bi('Reminder sent to all owners this morning.',
          'أُرسل التذكير إلى جميع الملاك هذا الصباح.'),
      Bi('Three owners have already replied with their dates.',
          'ردّ ثلاثة ملاك بالفعل بمواعيدهم.'),
      Bi('Good, thank you.', 'جيد، شكراً لك.'),
    ],
  ];
}
