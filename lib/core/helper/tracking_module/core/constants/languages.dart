// Date: 29/9/2024
// By: Youssef Ashraf, Nada Mohammed, Mohammed Ashraf
// Last update: 29/9/2024
// Objectives: This file is responsible for providing the translations of the application.
// Available languages now --> English, Arabic

import 'package:get/get.dart';

class TrackingLanguages extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        // ****************************************** ENGLISH LANGUAGE ******************************************
        'en_US': {
          // add english translations here
          'Date Of Request:': 'Date Of Request:',
          'Type:': 'Type:',
          'Total Time:': 'Total Time:',
          'Max': 'Max',
          'Min': 'Min',
          'Total': 'Total',
          'Average': 'Average',
          'Request Description:': 'Request Description:',
          'Attachments:': 'Attachments:',
          'Reasons of Rejection': 'Reasons of Rejection',
          'Text Here': 'Text Here',
          'Submit': 'Submit',
          'Status:': 'Status:',
          'Attachments Required': 'Attachments Required',
          'Request Type Required': 'Request Type Required',
          'Start Date Required': 'Start Date Required',
          'End Date Required': 'End Date Required',
          'Description Required': 'Description Required',
          'Photo': 'Photo',
          'First Name': 'First Name',
          'Last Name': 'Last Name',
          'Date': 'Date',
          'Type': 'Type',
          'Status': 'Status',
          'Action': 'Action',

          'Total Time': 'Total Time',
          'Total Days': 'Total Days',
          'Late History': 'Late History',

          'Oncoming Time': 'Oncoming Time',
          'Leaving Time': 'Leaving Time',
          'Break Time': 'Break Time',

          'Check In': 'Check In',
          'Check Out': 'Check Out',

          'Department': 'Department',
          'Time': 'Time',
          'Location': 'Location',

          'Request Types': 'Request Types',
          'Request Status': 'Request Status',
          'Absence History': 'Absence History',
          'Requests History': 'Requests History',

          'Custom Data Selector': 'Custom Data Selector',
          'Apply': 'Apply',

          'Employee': 'Employee',
          'Manager': 'Manager',
          'HR': 'HR',

          'Day': 'Day',
          'Week': 'Week',
          'Month': 'Month',
          'Year': 'Year',
          'Custom': 'Custom',

          'All': 'All',
          'Branch 1': 'Branch 1',
          'Branch 2': 'Branch 2',
          'Main Office': 'Main Office',

          'My Dashboard': 'My Dashboard',
          'Human Resources': 'Human Resources',

          'Approved': 'Approved',
          'Pending': 'Pending',
          'Rejected': 'Rejected',

          'Present': 'Present',
          'Late': 'Late',
          'Absent': 'Absent',
          'Excused': 'Excused',
          'Vacations Credit': 'Vacations Credit',

          'Counts': 'Counts',
          'Minutes': 'Minutes',

          'timeMinutes': 'Minutes',
          'Dashboard': 'Dashboard',
          'Attendance': 'Attendance',
          'Requests': 'Requests',
          'Approvals': 'Approvals',
          'Locations': 'Locations',

          'Tracking Time': 'Tracking Time',

          'Email': 'Email',
          'Phone': 'Phone',
          'Supervisor': 'Supervisor',
          'Chat with employee': 'Chat with employee',

          'Hide This Section': 'Hide This Section',
          'Resume': 'Resume',
          'Pause': 'Pause',

          'Check In Time': 'Check In Time',
          'Check Out Time': 'Check Out Time',
          'Break': 'Break',
          '30 Min': '30 min',

          'MB': 'MB',
          'Upload Attachments': 'Upload Attachments',
          'Attachments': 'Attachments',
          'Add More': 'Add More',

          'Add New card': 'Add New card',
          'Edit Location': 'Edit Location',
          'Step 1 of 2 : Location Description':
              'Step 1 of 2 : Location Description',
          'Location Name': 'Location Name',
          'Address of the card': 'Address of the card',
          'Location at Google Maps': 'Location at Google Maps',
          'Coordinates': 'Coordinates',
          'Latitude': 'Latitude',
          'Longitude': 'Longitude',
          'Accuracy': 'Accuracy',
          'Choose Here': 'Choose Here',
          'Geofencing': 'Geofencing',
          'Meter': 'Meter',
          'Next': 'Next',
          'Step 2 of 2 : Location Settings': 'Step 2 of 2 : Location Settings',
          'Allow Breaks in attendance': 'Allow Breaks in attendance',
          'Allow Pause': 'Allow Pause',
          'Allowance Period': 'Allowance Period',
          'Text allowance Period here': 'Text allowance Period here',
          'Period': 'Period',
          'Save': 'Save',
          'Successful': 'Successful',
          'You successfully added card!': 'You successfully added card!',
          'You successfully edited card!': 'You successfully edited card!',

          'Leave Type': 'Leave Type',

          'Filter': 'Filter',
          'Reset': 'Reset',

          'Add Transaction': 'Add Transaction',
          'Transaction Description': 'Transaction Description',
          'You successfully added transaction!':
              'You successfully added transaction!',
          'Send': 'Send',

          'Send Request': 'Send Request',
          'Request Type': 'Request Type',
          'All Day': 'All Day',
          'Request Description': 'Request Description',
          'You Successful Send': 'You Successful Send',

          'Start Time': 'Start Time',
          'End Time': 'End Time',
          'Take a break': 'Take a break',
          'Did you take your 30 minutes break?':
              'Did you take your 30 minutes break?',
          'Total Hours': 'Total Hours',
          'End Shift': 'End Shift',

          'Start Date': 'Start Date',
          'End Date': 'End Date',
          'Choose Date': 'Choose Date',

          'Address': 'Address',
          'Wrong Location': 'Wrong Location',
          'Your determined card is': 'Your Determined Location Is',
          'Please check in at this card and make sure to be there precisely.':
              'Please Check In At This Location And Make Sure To Be There Precisely.',
          'Confirmed': 'Confirmed',
          'Your card matches the company\'s card.':
              'Your Location Matches The Company\'s Location.',

          'Add Request Type': 'Add Request Type',
          'Add Location': 'Add Location',
          'Search Here...': 'Search Here...',

          'Name': 'Name',
          'Google Map': 'Google Map',
          'Could not open the map.': 'Could Not Open The Map.',

          'Location Description': 'Location Description',
          'Location Settings': 'Location Settings',
          'List of Individuals': 'List of Individuals',

          'Job Title': 'Job Title',

          'Google Maps': 'Google Maps',

          'Delete Location': 'Delete Location',
          'Are you sure you want to delete this card?':
              'Are You Sure You Want To Delete This Location?',

          'Chat': 'Chat',

          'A reminder was sent on': 'A Reminder Was Sent On',
          'You can only send a reminder once every two days . Feel free to contact your supervisor directly for assistance':
              'You Can Only Send A Reminder Once Every Two Days . Feel Free To Contact Your Supervisor Directly For Assistance',
          'Reminder Sent': 'Reminder Sent',
          'Send Reminder': 'Send Reminder',

          'Description': 'Description',
          'Hr Approval': 'Hr Approval',
          'Adding Description': 'Adding Description',
          'Adding Attachments': 'Adding Attachments',

          'Please fill all fields and choose the required options.':
              'Please Fill All Fields And Choose The Required Options.',

          'Hr Approval  ': 'Hr Approval  ',
          'Adding Description  ': 'Adding Description  ',
          'Adding Attachment  ': 'Adding Attachment  ',

          'This field is': 'This Field Is',
          'required': 'Required',
          'optional': 'Optional',
          'HR Approval': 'HR Approval',
          'No Available Locations Were Added':
              'No Available Locations Were Added',
          'Edit Request Type': 'Edit Request Type',
          'Edit': 'Edit',
          'Delete': 'Delete',
          'Are you sure you want to delete this Request Type?':
              'Are you sure you want to delete this Request Type?',
          'Delete Request Type': 'Delete Request Type',

          'Click': 'Click',
          'Yes': 'Yes',
          'No': 'No',

          'Choose Time': 'Choose Time',
          'Your current card': 'Your Current Location',
          'status': 'Status',

          'Business Mission': 'Business Mission',
          'Excused - Urgent Personal': 'Excused - Urgent Personal',
          'Personal Leave': 'Personal Leave',
          'Excused - Personal': 'Excused - Personal',
          'Excused - Paternity': 'Excused - Paternity',
          'Paternity Leave': 'Paternity Leave',
          'Sick Leave': 'Sick Leave',
          'Excused - Conference': 'Excused - Conference',
          'Annual Vacation': 'Annual Vacation',
          'Death Vacation': 'Death Vacation',
          'Birth Vacation': 'Birth Vacation',
          'Excused - Workshop': 'Excused - Workshop',
          'Marriage Vacation': 'Marriage Vacation',
          'Sick Vacation': 'Sick Vacation',
          'Emergency Vacation': 'Emergency Vacation',
          "You Can's take a break before": "You Can's take a break before",
          'Unknown Action': 'Unknown Action',
          'Enter Description': 'Enter Description',
          'Reason Of Rejection': 'Reason Of Rejection',
          'Months': 'Months',
          'Days': 'Days',
          'Seconds': 'Seconds',
          'seconds': 'seconds',
          'Second': 'Second',
          'Minute': 'Minute',
          'Hours': 'Hours',
          'Hour': 'Hour',
          'Attention': 'Attention',
          'Add New Location': 'Add New Location',
          'Location Name Required': 'Location Name Required',
          'Geofencing Required': 'Geofencing Required',
          'Location At Google Maps Required': 'Location At Google MapsRequired',
          'Location At Google Maps': 'Location At Google Maps',
          'low': 'Low',
          'medium': 'Medium',
          'high': 'High',
          'Mins': 'Mins',
          'Hrs': 'Hrs',
          'Text Allowance Period Here': 'Text Allowance Period Here',
          'You Successfully Added Location!':
              'You Successfully Added Location!',
          'You Successfully Deleted Location!':
              'You Successfully Deleted Location!',
          'You Successfully Edited Location!':
              'You Successfully Edited Location!',
          'Allow Breaks In Attendance': 'Allow Breaks In Attendance',
          'Select Period': 'Select Period',
          'Availability': 'Availability',
          'M': 'M',
          'KM': 'KM',

          'Set Date': 'Set Date',
          'Cancel': 'Cancel',

          'Please Enter The Text In English Language':
              'Please Enter The Text In English Language',
          'Please Enter The Text In Arabic Language':
              'Please Enter The Text In Arabic Language',

          'This Field Is Required': 'This Field Is Required',
          'No data found': 'No data found',

          'Geofencing Area': 'Geofencing Area',
          'Geofencing Perimeter': 'Geofencing Perimeter',
          'Allowance Geofence': 'Allowance Geofence',
          'Meter²': 'Meter²',
          'State or Province': 'State or Province',
          'Country': 'Country',
          'City': 'City',
          'Postal Code': 'Postal Code',

          'You Successfully Added a Request Type!':
              'You Successfully Added a Request Type!',
          "Invalid Location": "Invalid Location",
          "Please select at least 3 points": "Please select at least 3 points",
          'Did you take your': 'Did you take your',
          'break?': 'break?',
        },

        // ****************************************** ARABIC LANGUAGE ******************************************
        'ar_EG': {
          // add arabic translations here

          'Did you take your': 'أذا كانت',
          'Max': 'الحد الاقصى',
          'Min': 'الحد الادنى',
          'Average': 'المتوسط',
          'Total': 'الكلي',
          "break?": "استقطاع؟",
          "Please select at least 3 points": "الرجاء تحديد على الاقل ٣ نقاط",
          "Invalid Location": "موقع غير صالح",
          'Date Of Request:': 'تاريخ الطلب:',
          'Type:': 'النوع:',
          'Total Time:': 'الوقت الكلي:',
          'Request Description:': 'وصف الطلب:',
          'Attachments:': 'المرفقات:',
          'Reasons of Rejection': 'أسباب الرفض',
          'Text Here': 'أكتب هنا',
          'Submit': 'إرسال',
          'Status:': 'الحالة:',

          'Photo': 'صورة',
          'First Name': 'الاسم الأول',
          'Last Name': 'الاسم الأخير',
          'Date': 'التاريخ',
          'Type': 'النوع',
          'Status': 'الحالة',
          'Action': 'الإجراء',
          'Attachments Required': 'المرفقات مطلوبة',
          'Request Type Required': 'نوع الطلب مطلوب',
          'Start Date Required': 'تاريخ البدء مطلوب',
          'End Date Required': 'تاريخ الانتهاء مطلوب',
          'Description Required': 'الوصف مطلوب',

          'Total Time': 'الوقت الكلي',
          'Late History': 'سجل التأخير',
          'Total Days': 'الأيام الكلية',

          'Oncoming Time': 'وقت الوصول',
          'Leaving Time': 'وقت المغادرة',
          'Break Time': 'وقت الاستراحة',

          'Check In': 'تسجيل الدخول',
          'Check Out': 'تسجيل الخروج',

          'Department': 'القسم',
          'Time': 'الوقت',
          'Location': 'الموقع',

          'Request Types': 'أنواع الطلبات',
          'Request Status': 'حالة الطلب',
          'Absence History': 'سجل الغياب',
          'Requests History': 'سجل الطلبات',

          'Custom Data Selector': 'اختيار البيانات المخصصة',
          'Apply': 'تطبيق',

          'Employee': 'موظف',
          'Manager': 'مدير',
          'HR': 'موارد بشرية',

          'Day': 'يوم',
          'Week': 'أسبوع',
          'Month': 'شهر',
          'Year': 'سنة',
          'Custom': 'مخصص',

          'All': 'الكل',
          'Branch 1': 'الفرع ١',
          'Branch 2': 'الفرع ٢',
          'Main Office': 'المكتب الرئيسي',

          'My Dashboard': 'لوحة تحكمي',
          'Human Resources': 'الموارد البشرية',

          'Approved': 'تمت الموافقة',
          'Pending': 'قيد الانتظار',
          'Rejected': 'تم الرفض',

          'Present': 'حاضر',
          'Late': 'متأخر',
          'Absent': 'غائب',
          'Excused': 'معذر',
          'Vacations Credit': 'رصيد الإجازات',

          'Counts': 'العدد',
          'Minutes': 'الدقائق',
          'timeMinutes': 'دقائق',

          'Dashboard': 'لوحة التحكم',
          'Attendance': 'الحضور',
          'Requests': 'الطلبات',
          'Approvals': 'الموافقات',
          'Locations': 'المواقع',

          'Tracking Time': 'تتبع الوقت',

          'Email': 'البريد الإلكتروني',
          'Phone': 'الهاتف',
          'Supervisor': 'المشرف',
          'Chat with employee': 'الدردشة مع الموظف',

          'Hide This Section': 'إخفاء هذا القسم',
          'Resume': 'استئناف',
          'Pause': 'إيقاف',

          'Check In Time': 'وقت الدخول',
          'Check Out Time': 'وقت الخروج',
          'Break': 'استراحة',
          '30 Min': '٣٠ دقيقة',

          'MB': 'ميجا بايت',
          'Upload Attachments': 'رفع المرفقات',
          'Attachments': 'المرفقات',
          'Add More': 'إضافة المزيد',

          'Add New card': 'إضافة موقع جديد',

          'Edit Location': 'تعديل الموقع',
          'Step 1 of 2 : Location Description': 'الخطوة ١ من ٢ : وصف الموقع',
          'Location Name': 'اسم الموقع',
          'Address of the card': 'عنوان الموقع',
          'Location at Google Maps': 'الموقع على خرائط جوجل',
          'Coordinates': 'الإحداثيات',
          'Latitude': 'خط العرض',
          'Longitude': 'خط الطول',
          'Accuracy': 'الدقة',
          'Choose Here': 'اختر هنا',
          'Geofencing': 'التحديد الجغرافي',
          'Meter': 'متر',
          'Next': 'التالي',
          'Step 2 of 2 : Location Settings': 'الخطوة ٢ من ٢ : إعدادات الموقع',
          'Allow Breaks in attendance': 'السماح بالاستراحات في الحضور',
          'Allow Pause': 'السماح بالإيقاف',
          'Allowance Period': 'فترة السماح',
          'Text allowance Period here': 'نص فترة السماح هنا',
          'Period': 'الفترة',
          'Save': 'حفظ',
          'Successful': 'ناجح',
          'You successfully added card!': 'لقد قمت بإضافة الموقع بنجاح!',
          'You successfully edited card!': 'لقد قمت بتعديل الموقع بنجاح!',

          'Leave Type': 'نوع الإجازة',

          'Filter': 'تصفية',
          'Reset': 'إعادة',
          'Attention': 'انتبه',
          'Add Transaction': 'إضافة معاملة',
          'Transaction Description': 'وصف المعاملة',
          'You successfully added transaction!':
              'لقد قمت بإضافة المعاملة بنجاح!',
          'Send': 'إرسال',
          'You Successfully Deleted Location!': 'لقد قمت بحذف الموقع بنجاح!',
          'Send Request': 'إرسال الطلب',
          'Request Type': 'نوع الطلب',
          'All Day': 'طوال اليوم',
          'Request Description': 'وصف الطلب',
          'You Successful Send': 'لقد قمت بالإرسال بنجاح',

          'Start Time': 'وقت البدء',
          'End Time': 'وقت الانتهاء',
          'Take a break': 'خذ استراحة',
          'Did you take your 30 minutes break?':
              'هل قمت بأخذ استراحتك لمدة ٣٠ دقيقة؟',
          'Total Hours': 'الوقت الكلي',
          'hours': 'ساعات',
          'End Shift': 'نهاية الوردية',

          'Start Date': 'تاريخ البدء',
          'End Date': 'تاريخ الانتهاء',
          'Choose Date': 'اختر التاريخ',

          'Address': 'العنوان',
          'Wrong Location': 'الموقع خاطئ',
          'Your determined card is': 'الموقع الذي تم تحديده هو',
          'Please check in at this card and make sure to be there precisely.':
              'يرجى تسجيل الدخول في هذا الموقع والتأكد من وجودك هناك بدقة.',
          'Confirmed': 'تم التأكيد',
          'Your card matches the company\'s card.':
              'موقعك يتطابق مع موقع الشركة.',
          "You Can's take a break before": 'لا يمكنك اخذ استراحة قبل',
          'Add Request Type': 'إضافة نوع الطلب',
          'Add Location': 'إضافة موقع',
          'Search Here...': 'ابحث هنا...',
          'seconds': 'ثواني',
          'Name': 'الاسم',
          'Google Map': 'خرائط جوجل',
          'Could not open the map.': 'لا يمكن فتح الخريطة.',

          'Location Description': 'وصف الموقع',
          'Location Settings': 'إعدادات الموقع',
          'List of Individuals': 'قائمة الأفراد',

          'Job Title': 'المسمى الوظيفي',

          'Google Maps': 'خرائط جوجل',

          'Delete Location': 'حذف الموقع',
          'Are you sure you want to delete this card?':
              'هل أنت متأكد أنك تريد حذف هذا الموقع؟',

          'Chat': 'الدردشة',

          'A reminder was sent on': 'تم إرسال تذكير في',
          'You can only send a reminder once every two days . Feel free to contact your supervisor directly for assistance':
              'يمكنك إرسال تذكير مرة واحدة فقط كل يومين. لا تتردد في الاتصال بمشرفك مباشرة للحصول على المساعدة',
          'Reminder Sent': 'تم إرسال التذكير',
          'Send Reminder': 'إرسال تذكير',

          'Description': 'الوصف',
          'Hr Approval': 'موافقة الموارد البشرية',
          'Adding Description': 'إضافة الوصف',
          'Adding Attachments': 'إضافة المرفقات',

          'Please fill all fields and choose the required options.':
              'يرجى ملء جميع الحقول واختيار الخيارات المطلوبة.',

          'Hr Approval  ': 'موافقة الموارد البشرية  ',
          'Adding Description  ': 'إضافة الوصف  ',
          'Adding Attachment  ': 'إضافة المرفق  ',

          'This field is': 'هذا الحقل',
          'required': 'مطلوب',
          'optional': 'اختياري',
          'HR Approval': 'موافقة الموارد البشرية',
          'No Available Locations Were Added': 'لم يتم إضافة أي مواقع متاحة',
          'Edit Request Type': 'تعديل نوع الطلب',
          'Edit': 'تعديل',
          'Delete': 'حذف',
          'Are you sure you want to delete this Request Type?':
              'هل أنت متأكد أنك تريد حذف هذا النوع من الطلبات؟',
          'Delete Request Type': 'حذف نوع الطلب',

          'Click': 'انقر',
          'Yes': 'نعم',
          'No': 'لا',

          'Choose Time': 'اختر الوقت',
          'Your current card': 'موقعك الحالي',
          'status': 'الحالة',

          'Business Mission': 'مهمة عمل',
          'Excused - Urgent Personal': 'معذر - شخصي عاجل',
          'Personal Leave': 'إجازة شخصية',
          'Excused - Personal': 'معذر - شخصي',
          'Excused - Paternity': 'معذر - إجازة أبوية',
          'Paternity Leave': 'إجازة أبوية',
          'Sick Leave': 'إجازة مرضية',
          'Excused - Conference': 'معذر - مؤتمر',
          'Annual Vacation': 'إجازة سنوية',
          'Death Vacation': 'إجازة حداد',
          'Birth Vacation': 'إجازة ولادة',
          'Excused - Workshop': 'معذر - ورشة عمل',
          'Marriage Vacation': 'إجازة زواج',
          'Sick Vacation': 'اجازة مرضية',
          'Emergency Vacation': 'إجازة طارئة',

          'Unknown Action': 'إجراء غير معروف',
          'Enter Description': 'أدخل الوصف',
          'Reason Of Rejection': 'سبب الرفض',

          'Months': 'اشهر',
          'Days': 'ايام',
          'Seconds': 'ثواني',
          'Second': 'ثانية',
          'Minute': 'دقيقة',
          'Hours': 'ساعات',
          'Hour': 'ساعه',

          'Add New Location': 'إضافة موقع جديد',
          'Location Name Required': 'اسم الموقع مطلوب',
          'Geofencing Required': 'التسييج الجغرافي مطلوب',
          'Location At Google Maps Required': 'الموقع على خرائط جوجل مطلوب',
          'Location At Google Maps': 'الموقع على خرائط جوجل',
          'low': 'منخفض',
          'medium': 'متوسط',
          'high': 'مرتفع',
          'Mins': 'دقيقة',
          'Hrs': 'ساعات',
          'Text Allowance Period Here': 'أدخل فترة السماح هنا',
          'You Successfully Added Location!': 'لقد أضفت الموقع بنجاح!',
          'You Successfully Edited Location!': 'لقد قمت بتحرير الموقع بنجاح!',
          'Allow Breaks In Attendance': 'السماح بفترات الاستراحة في الحضور',
          'Select Period': 'اختر المدة',
          'Availability': 'التوفر',
          'M': 'م',
          'KM': 'كم',

          'Set Date': 'تعيين التاريخ',
          'Cancel': 'إلغاء',

          'Please Enter The Text In English Language':
              'الرجاء إدخال النص باللغة الإنجليزية',
          'Please Enter The Text In Arabic Language':
              'الرجاء إدخال النص باللغة العربية',

          'This Field Is Required': 'هذا الحقل مطلوب',
          'No Data Found': 'لم يتم العثور على بيانات',
          'No data found': 'لم يتم العثور على بيانات',

          'Geofencing Area': 'منطقة السياج الجغرافي',
          'Geofencing Perimeter': 'محيط السياج الجغرافي',
          'Allowance Geofence': 'حدود السياج الجغرافي',
          'Meter²': 'متر مربع',
          'State or Province': 'الولاية أو المقاطعة',
          'Country': 'البلد',
          'City': 'المدينة',
          'Postal Code': 'الرمز البريدي',

          'You Successfully Added a Request Type!': '!لقد أضفت نوع طلب بنجاح',
        },
      };
}
