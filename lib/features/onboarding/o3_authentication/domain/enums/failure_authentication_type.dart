/// ******************************* FILE INFO ******************************* ///
/// File Name: failure_authentication_type.dart
/// Purpose: Authentication failure types with specific error messages
/// ✅ UPDATED: Added emailNotFound for specific email validation
/// ✅ UPDATED: Added Arabic and English support for all messages
/// ✅ UPDATED: Added moduleUserLimitReached for per-module user limit enforcement

import 'package:get/get.dart';

enum FailureAuthenticationType {
  wrongPassword,
  emailNotFound,
  notFound,
  subscriptionError,
  subscriptionExpired,
  beforActivationDate,
  demoCancelled,
  wrongActivationPassword,
  notFoundInCompanyDatabase,
  dontHavePermission,
  tooManyUsers,
  moduleUserLimitReached; // ✅ NEW

  /// ✅ Get localized dialog message (supports Arabic and English)
  String get dialogBoxMessage {
    switch (this) {
      case FailureAuthenticationType.emailNotFound:
        return Get.locale?.languageCode == 'ar'
            ? 'لم يتم العثور على حساب بهذا البريد الإلكتروني. يرجى التحقق من بريدك الإلكتروني والمحاولة مرة أخرى، أو الاتصال بالمسؤول إذا كنت تعتقد أن هذا خطأ.'
            : 'No account found with this email address. Please check your email and try again, or contact your administrator if you believe this is an error.';

      case FailureAuthenticationType.wrongPassword:
        return Get.locale?.languageCode == 'ar'
            ? 'كلمة المرور التي أدخلتها غير صحيحة. يرجى التحقق من بيانات الاعتماد والمحاولة مرة أخرى. إذا نسيت كلمة المرور، يمكنك إعادة تعيينها باستخدام خيار "نسيت كلمة المرور".'
            : 'The password you entered is incorrect. Please verify your credentials and try again. If you have forgotten your password, you may reset it using the "Forgot Password" option.';

      case FailureAuthenticationType.demoCancelled:
        return Get.locale?.languageCode == 'ar'
            ? 'تم إلغاء هذه النسخة التجريبية وتم إلغاء الوصول. للحصول على مزيد من المساعدة أو لطلب نسخة تجريبية جديدة، يرجى الاتصال بمسؤول النظام.'
            : 'This demo trial has been canceled and access has been revoked. For further assistance or to request a new demo, please contact your system administrator.';

      case FailureAuthenticationType.beforActivationDate:
        return Get.locale?.languageCode == 'ar'
            ? 'الوصول إلى هذه النسخة التجريبية غير نشط بعد. سيتم منح الوصول بمجرد بدء الفترة التجريبية رسميًا. يرجى التحقق من وقت البدء المجدول.'
            : 'This demo access is not yet active. Access will be granted once the trial period officially begins. Please check the scheduled start time.';

      case FailureAuthenticationType.notFound:
        return Get.locale?.languageCode == 'ar'
            ? 'مجموعة البريد الإلكتروني وكلمة المرور المقدمة لا تتوافق مع أي حساب نشط في نظامنا. يرجى إعادة التحقق من بيانات الاعتماد الخاصة بك.'
            : 'The provided email and password combination does not correspond to any active account in our system. Please recheck your credentials.';

      case FailureAuthenticationType.subscriptionError:
        return Get.locale?.languageCode == 'ar'
            ? 'خطأ في الاشتراك. يرجى الاتصال بمسؤول النظام.'
            : 'Subscription Error. Please contact your system administrator.';

      case FailureAuthenticationType.subscriptionExpired:
        return Get.locale?.languageCode == 'ar'
            ? 'انتهت هذه الفترة التجريبية ولم يعد الوصول متاحًا. لمتابعة استكشاف النظام، يرجى طلب نسخة تجريبية جديدة أو الاتصال بمسؤول النظام.'
            : 'This demo period has ended and access is no longer available. To continue exploring the system, please request a new trial or contact your system administrator.';

      case FailureAuthenticationType.wrongActivationPassword:
        return Get.locale?.languageCode == 'ar'
            ? 'كلمة مرور التفعيل المؤقتة التي أدخلتها غير صحيحة. يرجى التحقق من كلمة المرور المرسلة إلى بريدك الإلكتروني والمحاولة مرة أخرى.'
            : 'The temporary activation password you entered is incorrect. Please check the password sent to your email and try again.';

      case FailureAuthenticationType.notFoundInCompanyDatabase:
        return Get.locale?.languageCode == 'ar'
            ? 'حسابك موجود ولكنه غير مهيأ بشكل صحيح في قاعدة بيانات الشركة. يرجى الاتصال بمسؤول النظام.'
            : 'Your account exists but is not properly configured in the company database. Please contact your system administrator.';

      case FailureAuthenticationType.dontHavePermission:
        return Get.locale?.languageCode == 'ar'
            ? 'ليس لديك إذن بالوصول إلى النظام الآن. يرجى الاتصال بالمسؤول لطلب الوصول.'
            : 'You do not have permission to access the system now. Please contact your administrator to request access.';

      case FailureAuthenticationType.tooManyUsers:
        return Get.locale?.languageCode == 'ar'
            ? 'تم تقليل عدد المستخدمين النشطين. يرجى مراجعة وتحديث سجلات الموظفين في Active Directory لتعكس الحد الجديد.'
            : 'The number of active users has been reduced. Please review and update the employee records in the Active Directory to reflect the new limit.';

    // ✅ NEW
      case FailureAuthenticationType.moduleUserLimitReached:
        return Get.locale?.languageCode == 'ar'
            ? 'تم الوصول للحد الأقصى لعدد المستخدمين في أحد الوحدات أو أكثر في هذا الدور. يرجى التواصل مع المسؤول.'
            : 'The user limit for one or more modules in this role has been reached. Please contact your administrator.';

      default:
        return Get.locale?.languageCode == 'ar'
            ? 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.'
            : 'An unexpected error occurred. Please try again.';
    }
  }

  /// ✅ Get localized dialog title (supports Arabic and English)
  String get dialogBoxTitle {
    switch (this) {
      case FailureAuthenticationType.emailNotFound:
        return Get.locale?.languageCode == 'ar'
            ? 'البريد الإلكتروني غير موجود'
            : 'Email Not Found';

      case FailureAuthenticationType.wrongPassword:
        return Get.locale?.languageCode == 'ar'
            ? 'كلمة مرور غير صحيحة'
            : 'Incorrect Password';

      case FailureAuthenticationType.demoCancelled:
        return Get.locale?.languageCode == 'ar'
            ? 'تم إلغاء النسخة التجريبية'
            : 'Demo Trial Canceled';

      case FailureAuthenticationType.beforActivationDate:
        return Get.locale?.languageCode == 'ar'
            ? 'محاولة الوصول قبل تفعيل النسخة التجريبية'
            : 'Access Attempt Before Demo Activation';

      case FailureAuthenticationType.notFound:
        return Get.locale?.languageCode == 'ar'
            ? 'بيانات الدخول غير معترف بها'
            : 'Login Credentials Unrecognized';

      case FailureAuthenticationType.subscriptionError:
        return Get.locale?.languageCode == 'ar'
            ? 'خطأ في الاشتراك'
            : 'Subscription Error';

      case FailureAuthenticationType.subscriptionExpired:
        return Get.locale?.languageCode == 'ar'
            ? 'انتهت صلاحية النسخة التجريبية'
            : 'Demo Trial Expired';

      case FailureAuthenticationType.wrongActivationPassword:
        return Get.locale?.languageCode == 'ar'
            ? 'كلمة مرور تفعيل غير صحيحة'
            : 'Incorrect Activation Password';

      case FailureAuthenticationType.notFoundInCompanyDatabase:
        return Get.locale?.languageCode == 'ar'
            ? 'خطأ في إعدادات الحساب'
            : 'Account Configuration Error';

      case FailureAuthenticationType.dontHavePermission:
        return Get.locale?.languageCode == 'ar'
            ? 'تم رفض الوصول'
            : 'Access Denied';

      case FailureAuthenticationType.tooManyUsers:
        return Get.locale?.languageCode == 'ar'
            ? 'مطلوب تعديل حد المستخدمين'
            : 'User Limit Adjustment Required';

    // ✅ NEW
      case FailureAuthenticationType.moduleUserLimitReached:
        return Get.locale?.languageCode == 'ar'
            ? 'تم الوصول للحد الأقصى'
            : 'Module User Limit Reached';

      default:
        return Get.locale?.languageCode == 'ar'
            ? 'خطأ'
            : 'Error';
    }
  }
}