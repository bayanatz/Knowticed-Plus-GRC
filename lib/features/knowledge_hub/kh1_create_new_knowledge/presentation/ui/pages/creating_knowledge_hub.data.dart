/// Module: knowledge_hub/kh1_create_new_knowledge/presentation/ui/pages
///
///*************************** FILE INFO ****************************///
/// File Name: creating_knowledge_hub.data.dart
/// Description: `_CreatingKnowledgeHubData` — split out of `creating_knowledge_hub.dart`.
/// Author: Amr Mesbah
/// Created at: 06/10/2026

part of 'creating_knowledge_hub.dart';

/// Module: knowledge_hub / presentation / s1_create_new_knowledge/master_page/creating_knowledge_hub.data.dart

/// Fields + data/department initialisation for [CreatingKnowledgeHub],
/// split out of the page to keep each file under 800 LOC (§7).
mixin _CreatingKnowledgeHubData on State<CreatingKnowledgeHub> {
  // Controllers
  final _englishController = TextEditingController();
  final _arabicController = TextEditingController();
  final _englishDescController = TextEditingController();
  final _arabicDescController = TextEditingController();

  // Form Keys
  final _documentNameFormKey = GlobalKey<FormState>();
  final _documentDescriptionKey = GlobalKey<FormState>();
  int selectedIndex = 0;
  int innerIndex = 0;
  bool _isEditMode = false;

  // Department Controller
  MainCoreDepartmentCubit get _departmentController =>
      context.read<CreateKnowledgeCubit>().people.departments;

  String _dropDownMenuText = 'Choose Type';
  bool _limitDepartmentAvailability = false;
  bool _schedulePublishing = false;
  bool _isUploading = false;

  /// True while an EDIT is being saved. That save runs inside
  /// CustomDialogManager.showDialogFlow, which already shows its own loading
  /// overlay, so the page's overlay stays off — two spinners were drawn on
  /// top of each other (KH large-screen report p.11).
  bool _suppressPageOverlay = false;

  DateTime? _startDate;
  TimeOfDay? _startTime;
  DateTime? _endDate;
  TimeOfDay? _endTime;

  File? _selectedImage;
  File? _selectedDocument;
  String? _documentFileName;
  String? _documentExtension;
  int _documentSize = 0;
  DateTime? _documentUploadedDate;

  CreateKnowledgeModel? submittedDocument;

  // Department Data
  String? _employeeDepartmentId;
  String? _employeeDepartmentEn;
  String? _employeeEmail;
  String? _selectedOwningDepartmentId; // For dropdown selection

  // Dynamic departments list
  List<DepartmentModelPro> _availableDepartments = [];
  final Map<String, bool> _departmentSelections = {};
  List<String> departments = [];

  bool _isDepartmentDataLoaded = false;

  List<String> get _selectedDepartments => _departmentSelections.entries
      .where((entry) => entry.value)
      .map((entry) => entry.key)
      .toList();

  // Media picker service — keeps FilePicker/ImagePicker out of the UI (§16).
  final MediaPickerService _mediaPicker = KnowledgeHubDI.mediaPicker;

  bool _isFormComplete() {
    // Mirrors the submit-time validation (see _handleSubmitForApproval in
    // creating_knowledge_hub.actions.dart) so the Submit/Save button only turns
    // enabled (primary color) once EVERY required field is filled — until then
    // it stays disabled with the grey disabled color and does nothing on tap.

    // 1. All four text fields have content.
    final hasEnglishName = _englishController.text.trim().isNotEmpty;
    final hasArabicName = _arabicController.text.trim().isNotEmpty;
    final hasEnglishDesc = _englishDescController.text.trim().isNotEmpty;
    final hasArabicDesc = _arabicDescController.text.trim().isNotEmpty;

    // 2. A document type is chosen.
    final hasDocType = _dropDownMenuText != 'Choose Type';

    // 3. A document is attached — a newly picked file, or the existing one when
    //    editing.
    final hasDocument =
        _selectedDocument != null ||
        submittedDocument?.currentDocumentFileName != null;

    // 4. If availability is limited to specific departments, at least one must
    //    be selected.
    final departmentsOk =
        !_limitDepartmentAvailability || _selectedDepartments.isNotEmpty;

    // 5. If scheduling is enabled, a start date must be set.
    final scheduleOk = !_schedulePublishing || _startDate != null;

    return hasEnglishName &&
        hasArabicName &&
        hasEnglishDesc &&
        hasArabicDesc &&
        hasDocType &&
        hasDocument &&
        departmentsOk &&
        scheduleOk;
  }

  Future<void> _initializeData() async {
    // Wait for departments to load first
    await _loadDepartments();
    if (!mounted) return;

    // Then initialize employee data
    _initializeEmployeeData();
  }

  Future<void> _loadDepartments() async {
    await context.read<CreateKnowledgeCubit>().fetchAllDepartments();
    if (mounted) setState(() {});
  }

  void _initializeEmployeeData() {
    final employee = context
        .read<CreateKnowledgeCubit>()
        .people
        .signedInEmployee;

    if (employee != null) {
      _employeeEmail = employee.email;
      _employeeDepartmentId = employee.departmentId;

      // ✅ Initialize selected owning department with employee's department
      _selectedOwningDepartmentId = _employeeDepartmentId;

      // Get department names in both languages
      if (_employeeDepartmentId != null && _isDepartmentDataLoaded) {
        _updateDepartmentNames();
      }

      _logEmployeeAndDepartmentInfo();
    }
  }

  void _updateDepartmentNames() {
    if (_employeeDepartmentId == null) return;

    // Only use the departments we got from cubit
    for (var dept in _availableDepartments) {
      if (dept.departmentID == _employeeDepartmentId) {
        _employeeDepartmentEn = dept.departmentName;
        return;
      }
    }

    // KH-CREATE-10: no made-up "Department <id>" name. Left unset, submit is
    // blocked until the real department is known.
    _employeeDepartmentEn = null;
  }

  // Get selected owning department name
  String _getSelectedOwningDepartmentName(BuildContext context) {
    if (_selectedOwningDepartmentId == null) {
      return _employeeDepartmentEn ?? S.of(context).loadingDepartments;
    }

    for (var dept in _availableDepartments) {
      if (dept.departmentID == _selectedOwningDepartmentId) {
        final String name = KhLocale.pick(
          context,
          en: dept.departmentName ?? '',
          ar: dept.departmentNameInArabic ?? '',
        );
        return name.isEmpty ? S.of(context).unknown : name;
      }
    }

    return _employeeDepartmentEn ?? S.of(context).khUnknownDepartment;
  }

  void _logEmployeeAndDepartmentInfo() {}
}
