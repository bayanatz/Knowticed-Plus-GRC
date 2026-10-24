/// Module: home/h1_home_page / data / data_source / showcase
///
///*************************** FILE INFO ****************************///
/// File Name: showcase_messages.dart
/// Purpose: Showcase Messages data for the signed-in user: 16 direct
///          conversations (5 with unread messages, 2 sent and not yet seen,
///          9 read; two of them pinned / muted), 6 group chats (public and
///          private, an admins-only channel, a muted group, a pinned
///          message, replies and reactions) and the Knowticed Support
///          conversation.
/// Author: Knowticed Plus team
/// Created at: 21/10/2026
///
/// Same document shapes the module writes itself (all under
/// `{baseUri}/Modules/messages/...`):
///   - `Connections/<user>/Last Message/<other>` from `UsersConnectionModel`
///     (written on both sides, `Connection_ID` = `<me>.<other>`);
///   - `Single Chat Message/<connectionId>/Messages/<id>` from
///     `SingleChatMessageModel`;
///   - `Messaging Groups/<id>` from `GroupModel`;
///   - `Groups Chat/<id>/Messages/<id>` from `GroupChatMessageModel`;
///   - `Support_Chats/<email>` (+ `Messages`) as `SupportChatRepository`;
///   - `Messaging_Chat_Settings/<chatKey>` as `ChatSettingsService` (pin/mute).
/// Message text is encrypted exactly like the app does it
/// (`MessageEncryptionService`, key = the chat id); a group's last-message
/// preview is plain text, as the app stores it.
///
/// The colleagues are the roster of [ShowcaseOrgChart] (their own emails, so
/// no existing conversation or profile is touched); [seed] writes the roster
/// first. The messaging user id is the e-mail, taken exactly as the signed-in
/// employee record holds it.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:knowticed_plus/core/di/app_controllers.dart';
import 'package:knowticed_plus/core/helper/single_value_tracking_model.dart';
import 'package:knowticed_plus/core/network/api_constants.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/data_source/showcase/showcase_common.dart';
import 'package:knowticed_plus/features/home/h1_home_page/data/data_source/showcase/showcase_org_chart.dart';
import 'package:knowticed_plus/features/messaging/helpers/enums/message_types.dart';
import 'package:knowticed_plus/features/messaging/helpers/main/chat_settings_service.dart';
import 'package:knowticed_plus/features/messaging/helpers/messaging_bridge/main_helper/incrption.dart';
import 'package:knowticed_plus/features/messaging/m1_chat/data/models/group_chat_message_model.dart';
import 'package:knowticed_plus/features/messaging/m1_chat/data/models/group_member_seen_model.dart';
import 'package:knowticed_plus/features/messaging/m1_chat/data/models/single_chat_message_model.dart';
import 'package:knowticed_plus/features/messaging/m1_chat/data/models/sub_models/pin_model.dart';
import 'package:knowticed_plus/features/messaging/m1_chat/domain/enum/reacts.dart';
import 'package:knowticed_plus/features/messaging/m2_connections/data/models/user_connection_last_message_info_model.dart';
import 'package:knowticed_plus/features/messaging/m2_connections/data/models/users_connection_model.dart';
import 'package:knowticed_plus/features/messaging/m3_groups/data/models/group_admin_model.dart';
import 'package:knowticed_plus/features/messaging/m3_groups/data/models/group_last_message_info.dart';
import 'package:knowticed_plus/features/messaging/m3_groups/data/models/group_members.dart';
import 'package:knowticed_plus/features/messaging/m3_groups/data/models/group_model.dart';
import 'package:knowticed_plus/features/settings/se7_app_info/data/utils/feedback_collection_paths.dart';

enum _S { unread, sentUnseen, read }

/// One line of a conversation. [who]: in a direct chat 0 = me, 1 = the
/// colleague; in a group the index into the group's member list (0 = me).
class _L {
  const _L(this.who, this.en, this.ar,
      {this.replyTo = 0,
      this.reaction = '',
      this.edited = false,
      this.pinned = false});

  final int who;
  final String en;
  final String ar;

  /// 1-based number of the line this one replies to (0 = none).
  final int replyTo;

  /// A reaction (`like`, `love`, `clap`, …) the other side left on it.
  final String reaction;
  final bool edited;
  final bool pinned;

  String text(bool isArabic) => isArabic ? ar : en;
}

class _D {
  const _D(this.partner, this.state, this.ago, this.gapMin, this.lines,
      {this.pinnedChat = false, this.mutedChat = false});

  /// Roster number of the colleague.
  final int partner;
  final _S state;

  /// How long ago the last message was sent.
  final Duration ago;

  /// Typical minutes between two messages.
  final int gapMin;
  final List<_L> lines;
  final bool pinnedChat;
  final bool mutedChat;
}

class _G {
  const _G(this.en, this.ar, this.descEn, this.descAr, this.members,
      this.creator, this.ago, this.gapMin, this.unread, this.lines,
      {this.admins = const <int>[0],
      this.isPublic = false,
      this.onlyAdmins = false,
      this.muted = false,
      this.pinnedChat = false});

  final String en;
  final String ar;
  final String descEn;
  final String descAr;

  /// Roster numbers; the signed-in user is always member 0 and is not listed.
  final List<int> members;

  /// Member index (0 = me) of the creator.
  final int creator;
  final Duration ago;
  final int gapMin;

  /// Unread messages for me.
  final int unread;
  final List<_L> lines;

  /// Member indexes that are admins.
  final List<int> admins;
  final bool isPublic;
  final bool onlyAdmins;
  final bool muted;
  final bool pinnedChat;
}

abstract final class ShowcaseMessages {
  // ── Direct conversations ────────────────────────────────────────────────
  static const List<_D> _directs = <_D>[
    // 5 with unread messages (the colleague spoke last)
    _D(
        4,
        _S.unread,
        Duration(hours: 2),
        38,
        <_L>[
          _L(
              1,
              'Good morning. The data quality scorecard for September is ready for your review.',
              'صباح الخير. بطاقة أداء جودة البيانات لشهر سبتمبر جاهزة لمراجعتك.'),
          _L(
              0,
              'Thank you. Did the completeness score for the beneficiary registry improve?',
              'شكراً لك. هل تحسنت نسبة الاكتمال في سجل المستفيدين؟'),
          _L(
              1,
              'Yes, it moved from 91% to 96% after we closed the duplicate records.',
              'نعم، ارتفعت من 91% إلى 96% بعد معالجة السجلات المكررة.',
              reaction: 'like'),
          _L(
              0,
              'Excellent. Please include that in the briefing for the steering committee.',
              'ممتاز. يرجى إدراج ذلك في الإحاطة الخاصة باللجنة التوجيهية.'),
          _L(
              1,
              'Done. I have also attached the list of remaining exceptions by owner.',
              'تم. كما أرفقت قائمة الاستثناءات المتبقية حسب المالك.'),
          _L(1, 'Could we discuss it tomorrow at 10:00?',
              'هل يمكننا مناقشتها غداً في الساعة 10:00؟'),
        ],
        pinnedChat: true),
    _D(8, _S.unread, Duration(hours: 6), 45, <_L>[
      _L(
          1,
          "The ministry's media office asked for the latest figures on service coverage.",
          'طلب المكتب الإعلامي للوزارة أحدث أرقام تغطية الخدمات.'),
      _L(0, 'Which period do they need?', 'ما هي الفترة التي يحتاجونها؟'),
      _L(1, 'The first three quarters of 2026, with a comparison to last year.',
          'الأرباع الثلاثة الأولى من 2026 مع مقارنة بالعام الماضي.'),
      _L(
          0,
          'I will prepare it today. Please confirm the wording with the legal team before release.',
          'سأعده اليوم. يرجى تأكيد الصياغة مع الإدارة القانونية قبل النشر.'),
      _L(1, 'Understood. I will send the draft to them this afternoon.',
          'مفهوم. سأرسل المسودة إليهم بعد الظهر.'),
      _L(1, 'Also, the press conference has moved to Thursday.',
          'كما تم نقل المؤتمر الصحفي إلى يوم الخميس.'),
    ]),
    _D(5, _S.unread, Duration(hours: 20), 55, <_L>[
      _L(0, 'Do we have the revised budget for the data platform upgrade?',
          'هل لدينا الميزانية المعدلة لترقية منصة البيانات؟'),
      _L(
          1,
          'Yes, the revision was approved on Sunday with a 4% reduction in licences.',
          'نعم، تم اعتماد التعديل يوم الأحد مع خفض بنسبة 4% في التراخيص.'),
      _L(0, 'Please share the breakdown by quarter.',
          'يرجى مشاركة التفصيل حسب الربع.'),
      _L(1, 'Attached. The largest commitment falls in the fourth quarter.',
          'مرفق. أكبر التزام يقع في الربع الرابع.',
          edited: true),
      _L(1, 'Let me know if you need the supplier quotations as well.',
          'أخبرني إن كنت تحتاج إلى عروض الموردين أيضاً.'),
    ]),
    _D(11, _S.unread, Duration(hours: 27), 70, <_L>[
      _L(
          1,
          'The internal audit visit starts next Monday. Which records should we prepare?',
          'تبدأ زيارة التدقيق الداخلي يوم الاثنين القادم. ما السجلات التي يجب تجهيزها؟'),
      _L(
          0,
          'Access logs, role assignments and the approval trail for the third quarter.',
          'سجلات الدخول وتعيينات الأدوار وسجل الموافقات للربع الثالث.'),
      _L(1, 'Noted. Should the exports be signed by the data owners?',
          'تم العلم. هل يجب أن توقع التصديرات من مالكي البيانات؟'),
      _L(0, 'Yes, a signed cover note is required for each export.',
          'نعم، يلزم خطاب توقيع مرفق بكل تصدير.',
          pinned: true),
      _L(1, 'Understood, we will have them ready by Sunday evening.',
          'مفهوم، سنجهزها بحلول مساء الأحد.'),
    ]),
    _D(7, _S.unread, Duration(hours: 49), 60, <_L>[
      _L(
          1,
          'Two new data analysts join on the 1st. Which access profile should they receive?',
          'ينضم محللا بيانات جديدان في الأول من الشهر. ما ملف الصلاحيات الذي سيمنحان إياه؟'),
      _L(
          0,
          'Data Governance Lead for the first, and view-only for the second until the training ends.',
          'قائد حوكمة البيانات للأول، وعرض فقط للثاني حتى انتهاء التدريب.'),
      _L(1, 'Understood. I will raise the request today.',
          'مفهوم. سأرفع الطلب اليوم.'),
      _L(0, 'Please also schedule the orientation with the knowledge team.',
          'يرجى أيضاً جدولة التهيئة مع فريق المعرفة.'),
      _L(1, 'Booked for Tuesday at 11:00 in the main meeting room.',
          'تم الحجز يوم الثلاثاء الساعة 11:00 في قاعة الاجتماعات الرئيسية.'),
      _L(1, 'I will send the invitation now.', 'سأرسل الدعوة الآن.'),
    ]),
    // 2 sent by me, not yet seen
    _D(10, _S.sentUnseen, Duration(hours: 26), 50, <_L>[
      _L(
          1,
          'A service request from the regional office has been waiting for three days.',
          'طلب خدمة من المكتب الإقليمي ينتظر منذ ثلاثة أيام.'),
      _L(0, 'I saw it. Who is the approver?', 'اطلعت عليه. من هو المعتمد؟'),
      _L(1, 'The operations coordinator; he is on leave until Thursday.',
          'منسق العمليات، وهو في إجازة حتى يوم الخميس.'),
      _L(
          0,
          'Please reassign it to the service desk supervisor so it can proceed today.',
          'يرجى إعادة إسناده إلى مشرف مكتب الخدمة ليستمر اليوم.'),
    ]),
    _D(6, _S.sentUnseen, Duration(hours: 70), 90, <_L>[
      _L(
          1,
          'Can you review the quarterly performance report before it goes out?',
          'هل يمكنك مراجعة تقرير الأداء الفصلي قبل إصداره؟'),
      _L(0, 'Of course. Send it over.', 'بالطبع. أرسله لي.'),
      _L(1, 'Sent. Please focus on the response-time section.',
          'تم الإرسال. يرجى التركيز على قسم زمن الاستجابة.'),
      _L(0, 'Reviewed. The response-time chart needs the new target line.',
          'تمت المراجعة. يحتاج مخطط زمن الاستجابة إلى خط المستهدف الجديد.'),
      _L(0, 'Once it is added, you can issue the report.',
          'بعد إضافته يمكنك إصدار التقرير.'),
    ]),
    // 9 read conversations, older (last message from 10 to 282 days ago)
    _D(27, _S.read, Duration(days: 10), 300, <_L>[
      _L(0, 'How is the attendance for the data literacy workshop?',
          'كيف هي نسبة الحضور لورشة الثقافة البيانية؟'),
      _L(1, 'Thirty-two participants registered, from nine departments.',
          'سجل اثنان وثلاثون مشاركاً من تسع إدارات.'),
      _L(0, 'Great. Please keep a waiting list for the second session.',
          'ممتاز. يرجى الاحتفاظ بقائمة انتظار للدورة الثانية.'),
      _L(1, 'Already done. Eighteen people are on it.',
          'تم ذلك. هناك ثمانية عشر شخصاً فيها.',
          reaction: 'clap'),
      _L(0, 'Thank you, that is encouraging.', 'شكراً لك، هذا مشجع.'),
    ]),
    _D(34, _S.read, Duration(days: 44), 420, <_L>[
      _L(1, 'The updated data retention policy is ready for your comments.',
          'سياسة الاحتفاظ بالبيانات المحدثة جاهزة لتعليقاتك.'),
      _L(0, 'I will review it this week. Is the archive schedule included?',
          'سأراجعها هذا الأسبوع. هل جدول الأرشفة مضمن؟'),
      _L(
          1,
          'Yes, section four lists the retention period for each record class.',
          'نعم، يحدد القسم الرابع مدة الاحتفاظ لكل فئة من السجلات.'),
      _L(0, 'Good. I will send my comments by Wednesday.',
          'جيد. سأرسل ملاحظاتي بحلول الأربعاء.'),
      _L(1, 'Thank you.', 'شكراً لك.'),
    ]),
    _D(28, _S.read, Duration(days: 78), 360, <_L>[
      _L(0, 'Is the statement on the new national data portal approved?',
          'هل تم اعتماد البيان الخاص بالبوابة الوطنية للبيانات؟'),
      _L(1, 'Approved by the director this morning, we publish at noon.',
          'اعتمده المدير صباح اليوم وسننشره ظهراً.'),
      _L(0, 'Please send me the final version for the records.',
          'يرجى إرسال النسخة النهائية لي للسجلات.'),
      _L(1, 'Sent to your email, in Arabic and English.',
          'أرسلتها إلى بريدك بالعربية والإنجليزية.'),
    ]),
    _D(
        22,
        _S.read,
        Duration(days: 112),
        480,
        <_L>[
          _L(
              1,
              'The vendor delivered the licences. Shall I register them in the asset list?',
              'سلّم المورد التراخيص. هل أسجلها في قائمة الأصول؟'),
          _L(0, 'Yes, and attach the delivery note to the purchase order.',
              'نعم، وأرفق إشعار التسليم بأمر الشراء.'),
          _L(1, 'Done. The invoice is also with finance for payment.',
              'تم. والفاتورة أيضاً لدى المالية للسداد.'),
          _L(0, 'Perfect, thanks.', 'ممتاز، شكراً.'),
        ],
        mutedChat: false),
    _D(3, _S.read, Duration(days: 146), 400, <_L>[
      _L(
          1,
          'We completed the quarterly access recertification. Two accounts were revoked.',
          'أنجزنا إعادة اعتماد الصلاحيات الفصلية. تم إلغاء حسابين.'),
      _L(0, 'Were they reviewed with the line managers?',
          'هل تمت مراجعتهما مع المديرين المباشرين؟'),
      _L(1, 'Yes, both managers confirmed the staff left the department.',
          'نعم، أكد المديران أن الموظفين غادرا الإدارة.'),
      _L(0, 'Good. Please log the closure in the register.',
          'جيد. يرجى تسجيل الإغلاق في السجل.'),
      _L(1, 'Logged.', 'تم التسجيل.'),
    ]),
    _D(
        16,
        _S.read,
        Duration(days: 180),
        520,
        <_L>[
          _L(
              0,
              'What is the status of the records migration to the new archive?',
              'ما حالة ترحيل السجلات إلى الأرشيف الجديد؟'),
          _L(
              1,
              'Seventy percent migrated. The remaining batches are the 2019 and 2020 files.',
              'تم ترحيل سبعين بالمئة. الدفعات المتبقية هي ملفات 2019 و2020.'),
          _L(0, 'Any quality issues so far?', 'هل هناك مشكلات جودة حتى الآن؟'),
          _L(
              1,
              'Only 112 records with missing metadata; the owners are correcting them.',
              'فقط 112 سجلاً تنقصها البيانات الوصفية، ويعمل المالكون على تصحيحها.'),
          _L(0, 'Thank you for the update.', 'شكراً على التحديث.'),
        ],
        mutedChat: true),
    _D(2, _S.read, Duration(days: 214), 340, <_L>[
      _L(1, 'Can we move the data council meeting to 13:00 on Wednesday?',
          'هل يمكن نقل اجتماع مجلس البيانات إلى الساعة 13:00 يوم الأربعاء؟'),
      _L(0, 'That works for me. Please update the invitation.',
          'مناسب لي. يرجى تحديث الدعوة.'),
      _L(1, 'Updated, and I added the agenda.',
          'تم التحديث وأضفت جدول الأعمال.'),
      _L(0, 'Thanks. I will bring the comparison with last year.',
          'شكراً. سأحضر المقارنة مع العام الماضي.'),
    ]),
    _D(9, _S.read, Duration(days: 248), 450, <_L>[
      _L(
          1,
          'The tender documents for the digital archive project are ready for your signature.',
          'وثائق المناقصة الخاصة بمشروع الأرشيف الرقمي جاهزة لتوقيعك.'),
      _L(0, 'Please send them to me. When is the closing date?',
          'يرجى إرسالها لي. ما هو الموعد النهائي للتقديم؟'),
      _L(
          1,
          'The closing date is the 28th. I attached the evaluation criteria as well.',
          'الموعد النهائي هو يوم 28. وأرفقت معايير التقييم أيضاً.'),
      _L(0, 'Signed and returned. Good luck.',
          'تم التوقيع والإرجاع. بالتوفيق.'),
    ]),
    _D(36, _S.read, Duration(days: 282), 380, <_L>[
      _L(
          1,
          'The next release is scheduled for Thursday evening, with the new role management screens.',
          'الإصدار القادم مجدول مساء الخميس ويتضمن شاشات إدارة الأدوار الجديدة.'),
      _L(
          0,
          'Has the access review been completed on the pre-production environment?',
          'هل اكتملت مراجعة الصلاحيات على بيئة ما قبل الإنتاج؟'),
      _L(1, 'Yes, all scenarios passed and the rollback plan is documented.',
          'نعم، نجحت جميع السيناريوهات وخطة التراجع موثقة.',
          reaction: 'like'),
      _L(0, 'Approved. Please notify the service desk before the release.',
          'معتمد. يرجى إبلاغ مكتب الخدمة قبل الإصدار.'),
      _L(1, 'Will do.', 'حاضر.'),
    ]),
  ];

  // ── Groups ──────────────────────────────────────────────────────────────
  static const List<_G> _groups = <_G>[
    _G(
        'Data Quality Working Group',
        'مجموعة عمل جودة البيانات',
        'Weekly coordination of data quality indicators, exceptions and owners.',
        'تنسيق أسبوعي لمؤشرات جودة البيانات والاستثناءات والمالكين.',
        <int>[4, 16, 17, 18, 19],
        0,
        Duration(hours: 5),
        55,
        3,
        <_L>[
          _L(
              1,
              'Reminder: please update your exception lists before Thursday noon so the weekly scorecard can be issued.',
              'تذكير: يرجى تحديث قوائم الاستثناءات قبل ظهر الخميس ليتم إصدار بطاقة الأداء الأسبوعية.'),
          _L(
              2,
              'Beneficiary registry completeness is now 96%. Two owners still have open items.',
              'اكتمال سجل المستفيدين أصبح 96%. لا يزال لدى مالكين اثنين بنود مفتوحة.'),
          _L(0, 'Please send me the owner names so I can follow up directly.',
              'يرجى إرسال أسماء المالكين لأتابع معهم مباشرة.'),
          _L(2, 'Sent to you by email just now.',
              'أرسلتها إليك بالبريد الإلكتروني الآن.'),
          _L(
              3,
              'The national ID validation rule is live in the pre-production environment.',
              'قاعدة التحقق من الهوية الوطنية مفعلة الآن في بيئة ما قبل الإنتاج.'),
          _L(
              0,
              'Good progress. Let us review the impact of the rule on Sunday.',
              'تقدم جيد. لنراجع أثر القاعدة يوم الأحد.',
              replyTo: 5),
          _L(
              4,
              'I will prepare the before and after comparison for the meeting.',
              'سأعد مقارنة قبل وبعد للاجتماع.'),
          _L(1, 'Thank you all. The next sync is on Sunday at 10:00.',
              'شكراً لكم جميعاً. الاجتماع القادم يوم الأحد الساعة 10:00.'),
          _L(5, 'I have closed the 112 records with missing metadata.',
              'أغلقت 112 سجلاً كانت تنقصها البيانات الوصفية.',
              reaction: 'clap'),
          _L(1, 'Excellent work.', 'عمل ممتاز.'),
        ],
        admins: <int>[0, 1]),
    _G(
        'Executive Steering Committee',
        'اللجنة التوجيهية التنفيذية',
        'Decisions, agenda and papers for the quarterly steering meetings.',
        'القرارات وجدول الأعمال والأوراق لاجتماعات اللجنة التوجيهية الفصلية.',
        <int>[1, 3, 5, 6, 7],
        1,
        Duration(days: 3),
        420,
        0,
        <_L>[
          _L(
              1,
              'Welcome to the steering committee channel. Decisions and agenda items will be shared here.',
              'مرحباً بكم في قناة اللجنة التوجيهية. سيتم نشر القرارات وبنود الأجندة هنا.'),
          _L(
              0,
              'The quarterly agenda is attached. Priority items: the data platform budget, the access recertification and the annual audit plan.',
              'جدول أعمال الربع مرفق. البنود ذات الأولوية: ميزانية منصة البيانات وإعادة اعتماد الصلاحيات وخطة التدقيق السنوية.',
              pinned: true),
          _L(
              1,
              'Approved. Please circulate the supporting papers 48 hours before the meeting.',
              'معتمد. يرجى تعميم الأوراق الداعمة قبل الاجتماع بـ 48 ساعة.',
              reaction: 'like'),
          _L(0, 'The papers will be circulated on Sunday morning.',
              'ستُعمم الأوراق صباح الأحد.'),
          _L(1, 'The next meeting is on Tuesday at 09:30 in the board room.',
              'الاجتماع القادم يوم الثلاثاء الساعة 09:30 في قاعة المجلس.'),
          _L(0, 'Noted. The meeting room and the video link are booked.',
              'تم العلم. تم حجز القاعة ورابط الاجتماع المرئي.'),
        ],
        admins: <int>[0, 1],
        onlyAdmins: true,
        pinnedChat: true),
    _G(
        'Government Relations Team',
        'فريق العلاقات الحكومية',
        'Coordination with ministries and public sector partners.',
        'التنسيق مع الوزارات وشركاء القطاع العام.',
        <int>[9, 30, 31, 11, 2],
        0,
        Duration(hours: 28),
        75,
        2,
        <_L>[
          _L(
              1,
              'The ministry confirmed the workshop on national data standards for the 12th.',
              'أكدت الوزارة ورشة المعايير الوطنية للبيانات يوم 12.'),
          _L(0, 'Great. Who is presenting the quality indicators?',
              'ممتاز. من سيعرض مؤشرات الجودة؟'),
          _L(
              2,
              'I can present them, with the data management team providing the figures.',
              'يمكنني عرضها مع تزويد فريق إدارة البيانات بالأرقام.'),
          _L(0, 'Agreed. Please send the draft slides by Thursday.',
              'اتفقنا. يرجى إرسال المسودة بحلول الخميس.'),
          _L(
              3,
              'The ministry also asked for a short note on our data sharing agreement.',
              'طلبت الوزارة كذلك مذكرة مختصرة عن اتفاقية مشاركة البيانات.'),
          _L(4, 'Legal will prepare a one-page summary tomorrow.',
              'ستعد الإدارة القانونية ملخصاً من صفحة واحدة غداً.'),
          _L(5, 'I added the workshop to the executive calendar.',
              'أضفت الورشة إلى التقويم التنفيذي.'),
          _L(3, 'Thank you. I will share the attendee list shortly.',
              'شكراً. سأشارك قائمة الحضور قريباً.'),
        ],
        isPublic: true),
    _G(
        'Media and Communications Desk',
        'مكتب الإعلام والاتصال',
        'Press releases, publication approvals and campaign schedules.',
        'البيانات الصحفية واعتمادات النشر وجداول الحملات.',
        <int>[8, 28, 29, 10],
        0,
        Duration(days: 9),
        500,
        0,
        <_L>[
          _L(
              1,
              'The press release on the data portal launch is ready for review.',
              'بيان إطلاق بوابة البيانات جاهز للمراجعة.'),
          _L(
              0,
              'Reviewed. Please soften the second paragraph and add the portal address.',
              'تمت المراجعة. يرجى تخفيف الفقرة الثانية وإضافة عنوان البوابة.'),
          _L(2, 'Updated and sent to the ministry media office.',
              'تم التحديث والإرسال إلى المكتب الإعلامي للوزارة.'),
          _L(3, 'The social media schedule for the launch week is attached.',
              'جدول وسائل التواصل لأسبوع الإطلاق مرفق.'),
          _L(
              4,
              'Customer support has prepared answers to the likely questions.',
              'جهز فريق دعم العملاء إجابات للأسئلة المتوقعة.',
              reaction: 'like'),
          _L(0, 'Perfect. Let us do a final check on Monday.',
              'ممتاز. لنجري مراجعة أخيرة يوم الاثنين.'),
          _L(1, 'Confirmed.', 'تم التأكيد.'),
        ],
        admins: <int>[0, 1],
        muted: true),
    _G(
        'Governance Policy Review',
        'مراجعة سياسات الحوكمة',
        'Review cycle for data governance and retention policies.',
        'دورة مراجعة سياسات حوكمة البيانات والاحتفاظ بها.',
        <int>[11, 34, 35, 4, 7],
        1,
        Duration(hours: 50),
        95,
        1,
        <_L>[
          _L(
              1,
              'The data retention policy is open for comments until the 25th.',
              'سياسة الاحتفاظ بالبيانات مفتوحة للتعليقات حتى يوم 25.'),
          _L(
              2,
              'Section 4 needs an explicit reference to the archiving regulation.',
              'يحتاج القسم الرابع إلى إشارة صريحة إلى نظام الأرشفة.'),
          _L(0, 'Agreed. Please add the article number.',
              'أتفق. يرجى إضافة رقم المادة.',
              replyTo: 2),
          _L(3, 'From the audit side, I suggest an annual review cycle.',
              'من جانب التدقيق، أقترح دورة مراجعة سنوية.'),
          _L(
              4,
              'Data owners can support that with the existing review calendar.',
              'يمكن لمالكي البيانات دعم ذلك عبر تقويم المراجعة الحالي.'),
          _L(5, 'HR will add the policy to the onboarding pack.',
              'ستضيف الموارد البشرية السياسة إلى حزمة التهيئة.'),
          _L(1, 'Thank you. I will issue the consolidated version on the 28th.',
              'شكراً. سأصدر النسخة المجمعة يوم 28.'),
        ],
        admins: <int>[0, 1]),
    _G(
        'Quarterly Reporting Task Force',
        'فريق إعداد التقرير الفصلي',
        'Consolidation of departmental figures into the quarterly management report.',
        'توحيد أرقام الإدارات في التقرير الإداري الفصلي.',
        <int>[5, 6, 21, 22, 24, 12],
        0,
        Duration(hours: 7),
        40,
        5,
        <_L>[
          _L(
              1,
              'Please send your quarter figures by Wednesday so the consolidated report can start.',
              'يرجى إرسال أرقام الربع بحلول الأربعاء لبدء إعداد التقرير الموحد.'),
          _L(
              2,
              'Operations figures are ready. Service delivery improved by 6%.',
              'أرقام العمليات جاهزة. تحسن تقديم الخدمة بنسبة 6%.'),
          _L(
              3,
              'Finance will share the budget execution table tomorrow morning.',
              'ستشارك المالية جدول تنفيذ الميزانية صباح الغد.'),
          _L(0, 'Thanks. Please keep the same template as last quarter.',
              'شكراً. يرجى الالتزام بنفس قالب الربع الماضي.'),
          _L(4, 'Procurement: 14 orders closed, 3 still waiting for delivery.',
              'المشتريات: أغلقت 14 طلباً ولا تزال 3 طلبات بانتظار التسليم.'),
          _L(5, 'Service desk response time is now 3.2 hours on average.',
              'متوسط زمن الاستجابة في مكتب الخدمة أصبح 3.2 ساعة.'),
          _L(6, 'The software release notes are added to the shared folder.',
              'أضيفت ملاحظات الإصدار البرمجي إلى المجلد المشترك.'),
          _L(
              2,
              'One correction: the figure for the regional offices is 82, not 78.',
              'تصحيح: رقم المكاتب الإقليمية هو 82 وليس 78.'),
          _L(3, 'Noted, I am updating the table.', 'تم العلم، سأحدّث الجدول.'),
          _L(
              1,
              'Great teamwork. The draft report goes to the director on Sunday.',
              'عمل جماعي رائع. ستصل المسودة إلى المدير يوم الأحد.'),
        ],
        admins: <int>[0, 1],
        isPublic: true),
  ];

  // ── Knowticed Support ───────────────────────────────────────────────────
  static const List<_L> _support = <_L>[
    _L(0, 'Hello, the export of the user list stops at 500 rows.',
        'مرحباً، يتوقف تصدير قائمة المستخدمين عند 500 صف.'),
    _L(
        1,
        'Thank you for reporting this. Could you tell us which filters were active?',
        'شكراً لإبلاغنا. هل يمكنك إخبارنا بالفلاتر المفعلة؟'),
    _L(0, 'Only the Active status filter.', 'فلتر الحالة نشط فقط.'),
    _L(
        1,
        'We reproduced it and the fix is included in the next update, planned for next week.',
        'تمكنا من إعادة المشكلة وسيتم إصلاحها في التحديث القادم الأسبوع المقبل.'),
    _L(1, 'We will notify you here as soon as it is released.',
        'سنبلغك هنا فور إصداره.'),
  ];

  static const String _supportName = 'Knowticed Support';

  static String _moduleBase() => '${ApiConstants.baseUri}/Modules/messages';

  static String _userKey(String email) =>
      email.trim().toLowerCase().replaceAll('.', '---');

  static Timestamp _ts(DateTime d) => Timestamp.fromDate(d);

  /// Times of [count] messages ending at [last], each [gapMin] minutes (plus
  /// a little variation) after the one before.
  static List<DateTime> _times(DateTime last, int count, int gapMin, int salt) {
    final List<DateTime> t = List<DateTime>.filled(count, last);
    for (int j = count - 2; j >= 0; j--) {
      final int extra = (salt * 7 + j * 13) % (gapMin ~/ 2 + 5);
      t[j] = t[j + 1].subtract(Duration(minutes: gapMin + extra));
    }
    return t;
  }

  /// Function Name: [seed]
  ///
  /// Purpose: Writes the conversations, groups and support chat of the
  /// signed-in user; returns how many documents were written.
  static Future<int> seed({
    required FirebaseFirestore firestore,
    required ShowcasePerson me,
    required bool isArabic,
    required DateTime now,
  }) async {
    // Colleagues must exist as employees (profiles, departments).
    await ShowcaseOrgChart.seedEmployees(
        firestore: firestore, me: me, now: now);
    final Map<String, String> deptIds =
        await ShowcaseOrgChart.departmentIds(firestore);

    final String domain = ShowcaseOrgChart.domainOf(me);
    final String meEmail = (AppControllers.isEmployeeRegistered
                ? AppControllers.employee.employeeEntity?.email
                : null)
            ?.trim() ??
        me.email;
    final String meNorm = meEmail.toLowerCase();
    final MessageEncryptionService crypto = MessageEncryptionService();
    final String base = _moduleBase();
    final List<void Function(WriteBatch)> ops = <void Function(WriteBatch)>[];

    // ── Direct conversations ───────────────────────────────────────────
    final CollectionReference<Map<String, dynamic>> myConnections =
        firestore.collection('$base/Connections/$meEmail/Last Message');
    for (int k = 0; k < _directs.length; k++) {
      final _D d = _directs[k];
      final ShowcaseStaff partner = ShowcaseOrgChart.staff(d.partner);
      final String partnerEmail = partner.email(domain);
      final String chatId = '$meEmail.$partnerEmail';
      final int count = d.lines.length;
      final DateTime last = now.subtract(d.ago);
      final List<DateTime> times = _times(last, count, d.gapMin, k);

      // Trailing run of the side whose messages are still unseen.
      int run = 0;
      for (int j = count - 1; j >= 0; j--) {
        final bool incoming = d.lines[j].who == 1;
        final bool counts = d.state == _S.unread
            ? incoming
            : (d.state == _S.sentUnseen ? !incoming : false);
        if (!counts) break;
        run++;
      }
      final int myUnread = d.state == _S.unread ? run.clamp(0, 3) : 0;
      final int otherUnread = d.state == _S.sentUnseen ? run.clamp(0, 2) : 0;
      final bool lastIsMe = d.lines.last.who == 0;
      final String lastId = ShowcaseCommon.id('dm${k + 1}', count);
      final String lastPlain = d.lines.last.text(isArabic);
      final String lastCipher = crypto.encrypt(lastPlain, chatId: chatId);

      final UsersConnectionModel mine = UsersConnectionModel(
        connectionId: chatId,
        userPrimaryLanguageName: partner.nameEn,
        userSecondaryLanguageName: partner.nameAr,
        userPrimaryLanguageSubInfo: partner.titleEn,
        userSecondaryLanguageSubInfo: partner.titleAr,
        userImageUri: '',
        userId: partnerEmail,
        userPhone: '',
        userCategoryId: deptIds[partner.dept],
        startedConnectionTime:
            _ts(times.first.subtract(const Duration(hours: 1))),
      )..lastMessageInfo = UserConnectionLastMessageInfoModel(
          messageType: MessageTypes.text,
          isLastMessageSenderCurrentUser: lastIsMe,
          textMessage: lastCipher,
          myUnreadMessagesCount: myUnread,
          otherUnreadMessagesCount: otherUnread,
          lastMessageTime: _ts(last),
          messageId: lastId,
        );
      final UsersConnectionModel theirs = UsersConnectionModel(
        connectionId: chatId,
        userPrimaryLanguageName: me.nameEn,
        userSecondaryLanguageName: me.nameAr,
        userPrimaryLanguageSubInfo: me.titleEn,
        userSecondaryLanguageSubInfo: me.titleAr,
        userImageUri: '',
        userId: meEmail,
        userPhone: '',
        userCategoryId: null,
        startedConnectionTime:
            _ts(times.first.subtract(const Duration(hours: 1))),
      )..lastMessageInfo = UserConnectionLastMessageInfoModel(
          messageType: MessageTypes.text,
          isLastMessageSenderCurrentUser: !lastIsMe,
          textMessage: lastCipher,
          myUnreadMessagesCount: otherUnread,
          otherUnreadMessagesCount: myUnread,
          lastMessageTime: _ts(last),
          messageId: lastId,
        );
      ops.add((WriteBatch b) =>
          b.set(myConnections.doc(partnerEmail), mine.toMap()));
      ops.add((WriteBatch b) => b.set(
          firestore
              .collection('$base/Connections/$partnerEmail/Last Message')
              .doc(meEmail),
          theirs.toMap()));

      final CollectionReference<Map<String, dynamic>> messages =
          firestore.collection('$base/Single Chat Message/$chatId/Messages');
      for (int j = 0; j < count; j++) {
        final _L line = d.lines[j];
        final bool fromMe = line.who == 0;
        final String id = ShowcaseCommon.id('dm${k + 1}', j + 1);
        final bool seen = !((d.state == _S.unread &&
                !fromMe &&
                j >= count - myUnread) ||
            (d.state == _S.sentUnseen && fromMe && j >= count - otherUnread));
        final String reactor = fromMe ? partnerEmail : meEmail;
        final Map<String, dynamic> data = SingleChatMessageModel(
          chatId: chatId,
          messageId: id,
          sendTime: _ts(times[j]),
          senderId: fromMe ? meEmail : partnerEmail,
          receiverId: fromMe ? partnerEmail : meEmail,
          isSeen: seen,
          isDeleted: false,
          isEdited: line.edited,
          isForwarded: false,
          messageType: MessageTypes.text,
          messageContent: crypto.encrypt(line.text(isArabic), chatId: chatId),
          repliedMessageId: line.replyTo > 0
              ? ShowcaseCommon.id('dm${k + 1}', line.replyTo)
              : null,
          pinModel: line.pinned
              ? PinModel(
                  isPinned: <bool>[true],
                  userId: <String>[meEmail],
                  pinnedAt: <Timestamp>[
                    _ts(times[j].add(const Duration(minutes: 20)))
                  ],
                )
              : null,
          reacts: line.reaction.isEmpty
              ? const <Reacts>[]
              : <Reacts>[Reacts.values.byName(line.reaction)],
        ).toMap();
        if (line.reaction.isNotEmpty) {
          // As ReactWriter stores it: one reaction per user.
          data['reacts_by'] = <String, String>{
            _userKey(reactor): line.reaction,
          };
          data['reacts_legacy'] = const <String>[];
        }
        ops.add((WriteBatch b) => b.set(messages.doc(id), data));
      }

      if (d.pinnedChat || d.mutedChat) {
        ops.add((WriteBatch b) => b.set(
              firestore
                  .collection(ChatSettingsService.collection)
                  .doc(ChatSettingsService.directKey(meEmail, partnerEmail)),
              <String, dynamic>{
                if (d.pinnedChat)
                  ChatSettingsService.pinnedByKey: <String>[meNorm],
                if (d.mutedChat) ...<String, dynamic>{
                  ChatSettingsService.mutedByKey: <String>[meNorm],
                  ChatSettingsService.mutedUntilKey: <String, dynamic>{
                    meNorm: null
                  },
                },
              },
              SetOptions(merge: true),
            ));
      }
    }

    // ── Groups ─────────────────────────────────────────────────────────
    final CollectionReference<Map<String, dynamic>> groupsCol =
        firestore.collection('$base/Messaging Groups');
    for (int g = 0; g < _groups.length; g++) {
      final _G grp = _groups[g];
      final String groupId = ShowcaseCommon.id('group', g + 1);
      final List<String> emails = <String>[
        meEmail,
        for (final int n in grp.members)
          ShowcaseOrgChart.staff(n).email(domain),
      ];
      final int count = grp.lines.length;
      final DateTime last = now.subtract(grp.ago);
      final List<DateTime> times = _times(last, count, grp.gapMin, g + 3);
      final DateTime created = ShowcaseCommon.spread(g, _groups.length, now,
          endGap: const Duration(days: 60));
      final String creator = emails[grp.creator];

      final Map<String, GroupMember> members = <String, GroupMember>{};
      for (int m = 0; m < emails.length; m++) {
        final bool isMe = m == 0;
        final ShowcaseStaff? s =
            isMe ? null : ShowcaseOrgChart.staff(grp.members[m - 1]);
        members[emails[m]] = GroupMember(
          memberId: emails[m],
          primaryLanguageName: isMe ? me.nameEn : s!.nameEn,
          secondaryLanguageName: isMe ? me.nameAr : s!.nameAr,
          primaryLanguageSubInfo: isMe ? me.titleEn : s!.titleEn,
          secondaryLanguageSubInfo: isMe ? me.titleAr : s!.titleAr,
          memberPhone: '',
          memberImage: '',
          isMember: <bool>[true],
          timestamps: <Timestamp>[_ts(created)],
          categoryId: isMe ? null : deptIds[s!.dept],
          numOfUnreadMessages: isMe ? grp.unread : 0,
        );
      }
      final Map<String, GroupAdminModel> admins = <String, GroupAdminModel>{
        for (final int a in grp.admins)
          emails[a]: GroupAdminModel(
            adminId: emails[a],
            isAdmin: <bool>[true],
            timestamps: <Timestamp>[_ts(created)],
          ),
      };

      final String pinnedId = () {
        for (int j = 0; j < count; j++) {
          if (grp.lines[j].pinned) {
            return ShowcaseCommon.id('gm${g + 1}', j + 1);
          }
        }
        return '';
      }();
      final _L lastLine = grp.lines.last;
      final GroupModel model = GroupModel(
        groupId: groupId,
        createdBy: creator,
        groupName: SingleValueTrackingModel<String>(
            values: <String>[grp.en], timestamps: <Timestamp>[_ts(created)]),
        groupNameAr: SingleValueTrackingModel<String>(
            values: <String>[grp.ar], timestamps: <Timestamp>[_ts(created)]),
        groupDescription: SingleValueTrackingModel<String>(
            values: <String>[grp.descEn],
            timestamps: <Timestamp>[_ts(created)]),
        groupDescriptionAr: SingleValueTrackingModel<String>(
            values: <String>[grp.descAr],
            timestamps: <Timestamp>[_ts(created)]),
        groupImage: SingleValueTrackingModel<String>(
            values: <String>[], timestamps: <Timestamp>[]),
        creationTime: _ts(created),
        isPublic: SingleValueTrackingModel<bool>(
            values: <bool>[grp.isPublic],
            timestamps: <Timestamp>[_ts(created)]),
        isOnlyAdminsCanSend: SingleValueTrackingModel<bool>(
            values: <bool>[grp.onlyAdmins],
            timestamps: <Timestamp>[_ts(created)]),
        isDeleted: false,
        deletedTime: null,
        isUnMuted: SingleValueTrackingModel<bool>(
            values: <bool>[!grp.muted], timestamps: <Timestamp>[_ts(created)]),
        groupMembers: GroupMembers(members: members),
        groupAdmins: GroupAdminsModel(adminData: admins),
        isDisappearingMessages: SingleValueTrackingModel<bool>(
            values: <bool>[false], timestamps: <Timestamp>[_ts(created)]),
        currentExistingMembers: emails,
        groupLastMessageInfo: GroupLastMessageInfo(
          messageType: MessageTypes.text,
          textMessage: lastLine.text(isArabic),
          lastMessageTime: _ts(last),
          messageId: ShowcaseCommon.id('gm${g + 1}', count),
          senderId: emails[lastLine.who],
        ),
        pinnedMessageId: pinnedId.isEmpty ? null : pinnedId,
      );
      ops.add((WriteBatch b) => b.set(groupsCol.doc(groupId), model.toMap()));

      final CollectionReference<Map<String, dynamic>> gMessages =
          firestore.collection('$base/Groups Chat/$groupId/Messages');
      for (int j = 0; j < count; j++) {
        final _L line = grp.lines[j];
        final String id = ShowcaseCommon.id('gm${g + 1}', j + 1);
        final String sender = emails[line.who];
        // Everyone saw an older message; the newest [unread] are unseen by me.
        final bool unseenByMe = j >= count - grp.unread;
        final List<GroupMemberSeenModel> seenBy = <GroupMemberSeenModel>[
          for (int m = 0; m < emails.length; m++)
            if (emails[m] == sender || !(m == 0 && unseenByMe))
              GroupMemberSeenModel(
                memberId: emails[m],
                seenTime: _ts(times[j].add(Duration(minutes: 1 + m * 3))),
              ),
        ];
        final String reactor = emails[(line.who + 1) % emails.length];
        final Map<String, dynamic> data = GroupChatMessageModel(
          groupId: groupId,
          messageId: id,
          sendTime: _ts(times[j]),
          senderId: sender,
          seenBy: seenBy,
          isDeleted: false,
          isEdited: false,
          isForwarded: false,
          messageType: MessageTypes.text,
          messageContent: crypto.encrypt(line.text(isArabic), chatId: groupId),
          repliedMessageId: line.replyTo > 0
              ? ShowcaseCommon.id('gm${g + 1}', line.replyTo)
              : null,
          pinModel: line.pinned
              ? PinModel(
                  isPinned: <bool>[true],
                  userId: <String>[creator],
                  pinnedAt: <Timestamp>[
                    _ts(times[j].add(const Duration(minutes: 30)))
                  ],
                )
              : null,
          reacts: line.reaction.isEmpty
              ? const <String>[]
              : <String>[line.reaction],
        ).toMap();
        if (line.reaction.isNotEmpty) {
          data['reacts_by'] = <String, String>{
            _userKey(reactor): line.reaction,
          };
          data['reacts_legacy'] = const <String>[];
        }
        ops.add((WriteBatch b) => b.set(gMessages.doc(id), data));
      }

      if (grp.pinnedChat || grp.muted) {
        ops.add((WriteBatch b) => b.set(
              firestore
                  .collection(ChatSettingsService.collection)
                  .doc(ChatSettingsService.groupKey(groupId)),
              <String, dynamic>{
                if (grp.pinnedChat)
                  ChatSettingsService.pinnedByKey: <String>[meNorm],
                if (grp.muted) ...<String, dynamic>{
                  ChatSettingsService.mutedByKey: <String>[meNorm],
                  ChatSettingsService.mutedUntilKey: <String, dynamic>{
                    meNorm: null
                  },
                },
              },
              SetOptions(merge: true),
            ));
      }
    }

    // ── Knowticed Support conversation ─────────────────────────────────
    final DocumentReference<Map<String, dynamic>> supportRef = firestore
        .doc(FeedbackCollectionPaths.settingsDoc)
        .collection('Support_Chats')
        .doc(meEmail.trim().toLowerCase());
    const List<int> supportHoursAgo = <int>[52, 51, 50, 6, 5];
    for (int j = 0; j < _support.length; j++) {
      final _L line = _support[j];
      final bool fromAdmin = line.who == 1;
      ops.add((WriteBatch b) => b.set(
            supportRef
                .collection('Messages')
                .doc(ShowcaseCommon.id('support', j + 1)),
            <String, dynamic>{
              'Text': line.text(isArabic),
              'Type': 'text',
              'Sender': fromAdmin ? 'admin' : 'user',
              'Sender_Name': fromAdmin ? _supportName : me.name(isArabic),
              'Send_Time':
                  _ts(now.subtract(Duration(hours: supportHoursAgo[j]))),
              'Media_Url': '',
              'File_Name': '',
              'Is_Seen': !(fromAdmin && j >= _support.length - 2),
            },
          ));
    }
    ops.add((WriteBatch b) => b.set(
          supportRef,
          <String, dynamic>{
            'Employee_Email': meEmail,
            'Employee_Id': me.id,
            'Employee_Name': me.name(isArabic),
            'Last_Message': <String, dynamic>{
              'Text': _support.last.text(isArabic),
              'Type': 'text',
              'Sender': 'admin',
              'Time': _ts(now.subtract(const Duration(hours: 5))),
            },
            'Unread_By_Admin': 0,
            'Unread_By_User': 2,
            'Updated_At': _ts(now.subtract(const Duration(hours: 5))),
          },
          SetOptions(merge: true),
        ));

    // ── commit in chunks of 400 ────────────────────────────────────────
    for (int start = 0; start < ops.length; start += 400) {
      final WriteBatch batch = firestore.batch();
      final int end = start + 400 > ops.length ? ops.length : start + 400;
      for (final void Function(WriteBatch) op in ops.sublist(start, end)) {
        op(batch);
      }
      await batch.commit();
    }
    return ops.length;
  }
}
