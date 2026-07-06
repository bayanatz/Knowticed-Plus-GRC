// Date: 23/9/2024
// By: Mohamed Ashraf, Youssef Ashraf, Nada Mohammed
// Last update: 23/9/2024
// Objectives: This file is responsible for providing the translations of the application.
// Available languages now --> English, Arabic

import 'package:get/get.dart';

class MessagingLanguages extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        // ****************************************** ENGLISH LANGUAGE ******************************************
        'en_US': {
          'Group Details': 'Group Details',
          'Allows Users To Either View  Or Participate By Joining With An Invitation':
              'Allows Users To Either View  Or Participate By Joining With An Invitation',
          'Private': 'Private',
          'Only Admins Can Share Content ': 'Only Admins Can Share Content ',
          'editGroup': 'Edit Group',
          'media': 'Media',
          'links': 'Links',
          'documents': 'Documents',
          'mediaLinksAndDocs': 'Media, links, and docs',
          'all': 'All',
          'directMessages': 'Direct Messages',
          'groups': 'Groups',
          'See Less': 'See Less',
          'See More': 'See More',
          "unReadMessages": "Unread Messages",
          "readMessages": "Read Messages",
          "Sort": "Sort",
          "You Successfully Created New Group":
              "You Successfully Created New Group",
          "Are You Sure You Want To Create This Group ?":
              "Are You Sure You Want To Create This Group ?",
          "Creating New Group": "Creating New Group",
          'Departments': 'Departments',
          // add english translations here
          'Choose Here': 'Choose Here',
          'Search': 'Search',
          'Frequently Contacted': 'Frequently Contacted',
          'Recently Contacted': 'Recently Contacted',
          'Forward to': 'Forward to',
          'Send': 'Send',

          'All': 'All',
          'Design': 'Design',
          'Marketing': 'Marketing',
          'Software Developing': 'Software Developing',

          'Direct Messages': 'Direct Messages',
          'Groups': 'Groups',

          'No messages sent or received': 'No messages sent or received',
          'You are not involved in group discussions':
              'You are not involved in group discussions',
          'Create Group': 'Create Group',

          'Messages': 'Messages',
          'Chats': 'Chats',

          'About': 'About',
          'Member': 'Member',
          'Shared Content': 'Shared Content',

          'Mute': 'Mute',
          'Apply': 'Apply',
          'Cancel': 'Cancel',

          'View Contact': 'View Contact',
          'View Group': 'View Group',
          'Media, links, and docs': 'Media, links, and docs',
          'Mute notifications': 'Mute notifications',
          'Disappearing messages': 'Disappearing messages',
          'Schedule a message': 'Schedule a message',

          'No one else in this chat will see that you muted it, and you will still be notified if you are mentioned.':
              'No one else in this chat will see that you muted it, and you will still be notified if you are mentioned.',
          'Make messages in this chat disappear.':
              'Make messages in this chat disappear.',

          'Message removed from starred messages!':
              'Message removed from starred messages!',
          'Message added to starred messages!':
              'Message added to starred messages!',
          'Copied to device clipboard!': 'Copied to device clipboard!',

          'Error Occured, Please try again': 'Error Occured, Please try again',
          'Please enable location services!':
              'Please enable location services!',

          'Poll Details': 'Poll Details',
          'Create Poll': 'Create Poll',
          'Question': 'Question',
          'Ask a Question': 'Ask a Question',
          'Options': 'Options',
          'Option': 'Option',
          'Add Option': 'Add Option',
          'Allow Multiple Answers': 'Allow Multiple Answers',
          'of': 'of',
          'members voted': 'members voted',
          'Select one choice': 'Select one choice',
          'Select one or more choice': 'Select one or more choice',
          'View Votes': 'View Votes',

          'Please add a question': 'Please add a question',
          'Fill at least two options': 'Fill at least two options',
          'Options must be unique': 'Options must be unique',
          'Please enable microphone service!':
              'Please enable microphone service!',
          'Edited': 'Edited',
          'You deleted this message': 'This message is deleted',

          'pages': 'pages',
          'MB': 'MB',
          'Swipe Left To Cancel': 'Swipe Left To Cancel',

          'Add Caption': 'Add Caption',

          'Clear': 'Clear',
          'Clear This Chat?': 'Clear This Chat?',

          'Are you sure you want to delete this message?':
              'Are you sure you want to delete this message?',
          'Delete Message': 'Delete Message',

          'Total Picked Files': 'Total Picked Files',

          'Star': 'Star',
          'Unstar': 'Unstar',
          'Edit': 'Edit',
          'Reply': 'Reply',
          'Forward': 'Forward',
          'Copy': 'Copy',
          'Pin': 'Pin',
          'Share': 'Share',
          'Delete': 'Delete',
          'Unpin': 'Unpin',

          'Contact': 'Contact',
          'Document': 'Document',
          'Location': 'Location',
          'Poll': 'Poll',
          'Audio': 'Audio',
          'Gallery': 'Gallery',
          'Camera': 'Camera',

          'Voice Message': 'Voice Message',

          'No groups in common': 'No groups in common',
          'Groups in common': 'Groups in common',
          'Create a new group with': 'Create a new group with',
          'You,': 'You,',

          'Starred Messages': 'Starred Messages',
          'No starred messages': 'No starred messages',
          'Tap and hold on a message to star it, and it will show up here.':
              'Tap and hold on a message to star it, and it will show up here.',

          'Search members': 'Search members',
          'Save': 'Save',
          'Done': 'Done',
          'Message': 'Message',
          'Choose Date': 'Choose Date',
          'Choose Time': 'Choose Time',
          'Date': 'Date',
          'Time': 'Time',

          'Remove': 'Remove',
          'Make Admin': 'Make Admin',
          'Only View': 'Only View',

          'Group Name': 'Group Name',
          'Text Here': 'Text Here',
          'Description': 'Description',
          'Make Private': 'Make Private',
          'It can view or Join with invite': 'It can view or Join with invite',
          'Admin Only': 'Admin Only',
          'Only Admins can share content': 'Only Admins can share content',

          'No Media': 'No Media',
          'No Links': 'No Links',
          'No Docs': 'No Docs',

          'None': 'None',
          'You': 'You',

          'Pick a location': 'Pick a location',

          'Media': 'Media',
          'Links': 'Links',
          'Documents': 'Documents',

          'Type your Message...': 'Type your Message...',
          'Members': 'Members',
          '24 hours': '24 hours',
          '7 days': '7 days',
          '90 days': '90 days',
          'Always': 'Always',
          'Off': 'Off',

          '8 hours': '8 hours',
          '1 week': '1 week',

          'Contact Info': 'Contact Info',
          'Direct Message': 'Direct Message',
          'Selected': 'Selected',
          'Add option': 'Add option',
          'Today': 'Today',
          'Last Month': 'Last Month',
          'Week Ago': 'Week Ago',
          'This Week': 'This Week',

          "Add Member": "Add Member",
          "Create": "Create",

          "You Successfully Created a Group":
              "You Successfully Created a Group",
          'Collapse': 'Collapse',
          'Expansion': 'Expansion',
          'At': 'At',
        },

        // ****************************************** ARABIC LANGUAGE ******************************************
        'ar_EG': {
          'Allows Users To Either View  Or Participate By Joining With An Invitation':
              'يسمح للمستخدمين إما بعرض أو المشاركة من خلال الانضمام بدعوة',
          'Private': 'خاص',
          'Only Admins Can Share Content ':
              'يمكن للمسؤولين فقط مشاركة المحتوى ',

          'Collapse': 'طي',
          'Expansion': 'توسيع',
          'At': 'في',
          'media': 'الوسائط',
          'links': 'الروابط',
          'documents': 'المستندات',
          'editGroup': 'تعديل المجموعة',
          'mediaLinksAndDocs': 'الوسائط والروابط والمستندات',
          'all': 'الكل',
          'directMessages': 'الرسائل المباشرة',
          'groups': 'المجموعات',
          "unReadMessages": "رسائل غير مقروءة",
          "readMessages": "رسائل مقروءة",
          "Sort": "ترتيب",
          "You Successfully Created New Group":
              "لقد قمت بإنشاء مجموعة جديدة بنجاح",
          "Are You Sure You Want To Create This Group ?":
              "هل أنت متأكد أنك تريد إنشاء هذه المجموعة؟",
          "Creating New Group": "إنشاء مجموعة جديدة",
          // add arabic translations here
          'Departments': 'الأقسام',
          'Choose Here': 'اختر هنا',
          'Search': 'بحث',
          'Frequently Contacted': 'الأكثر تواصلاً',
          'Recently Contacted': 'الأخيرة تواصلاً',
          'Forward to': 'إعادة توجيه إلى',
          'Send': 'إرسال',
          'Unpin': 'إلغاء التثبيت',
          'All': 'الكل',
          'Design': 'تصميم',
          'Marketing': 'تسويق',
          'Software Developing': 'تطوير برمجي',

          'Direct Messages': 'الرسائل المباشرة',
          'Groups': 'المجموعات',

          'No messages sent or received': 'لم يتم إرسال أو استقبال رسائل',
          'You are not involved in group discussions':
              'أنت لست مشارك في المحادثات الجماعية',
          'Create Group': 'إنشاء مجموعة',

          'Messages': 'الرسائل',
          'Chats': 'المحادثات',

          'About': 'حول',
          'Member': 'عضو',
          'Shared Content': 'المحتوى المشترك',

          'Mute': 'كتم',
          'Apply': 'تطبيق',
          'Cancel': 'إلغاء',

          'View Contact': 'عرض جهة الاتصال',
          'View Group': 'عرض المجموعة',
          'Media, links, and docs': 'الوسائط والروابط والمستندات',
          'Mute notifications': 'كتم الإشعارات',
          'Disappearing messages': 'رسائل مختفية',
          'Schedule a message': 'جدولة رسالة',
          'See Less': 'See Less',
          'No one else in this chat will see that you muted it, and you will still be notified if you are mentioned.':
              'لن يرى أحد آخر في هذه المحادثة أنك كتمتها، وسيتم إعلامك بالإشعار إذا تمت إشارتك.',
          'Make messages in this chat disappear.':
              'جعل الرسائل في هذه المحادثة تختفي.',

          'Message removed from starred messages!':
              'تمت إزالة الرسالة من الرسائل المميزة!',
          'Message added to starred messages!':
              'تمت إضافة الرسالة إلى الرسائل المميزة!',
          'Copied to device clipboard!': 'تم نسخها إلى الحافظة!',

          'Error Occured, Please try again': 'حدث خطأ، يرجى المحاولة مرة أخرى',
          'Please enable location services!': 'يرجى تمكين خدمات الموقع!',

          'Poll Details': 'تفاصيل الاستطلاع',
          'Create Poll': 'إنشاء استطلاع',
          'Question': 'سؤال',
          'Ask a Question': 'اسأل سؤال',
          'Options': 'خيارات',
          'Option': 'خيار',
          'Add Option': 'إضافة خيار',
          'Allow Multiple Answers': 'السماح بإجابات متعددة',
          'of': 'من',
          'members voted': 'أعضاء صوتوا',
          'Select one choice': 'اختر خيارًا واحدًا',
          'Select one or more choice': 'اختر خيارًا واحدًا أو أكثر',
          'View Votes': 'عرض التصويت',

          'Please add a question': 'يرجى إضافة سؤال',
          'Fill at least two options': 'املأ خيارين على الأقل',
          'Options must be unique': 'يجب أن تكون الخيارات فريدة',

          'Edited': 'تم التعديل',
          'You deleted this message': 'لقد حذفت هذه الرسالة',

          'pages': 'صفحات',
          'MB': 'ميجابايت',
          'Swipe Left To Cancel': 'اسحب لليسار للإلغاء',

          'Add Caption': 'إضافة تسمية',

          'Clear': 'مسح',
          'Clear This Chat?': 'مسح هذه المحادثة؟',

          'Are you sure you want to delete this message?':
              'هل أنت متأكد أنك تريد حذف هذه الرسالة؟',
          'Delete Message': 'حذف الرسالة',

          'Total Picked Files': 'إجمالي الملفات المختارة',

          'Star': 'تمييز',
          'Unstar': 'إلغاء التمييز',
          'Edit': 'تعديل',
          'Reply': 'الرد',
          'Forward': 'إعادة توجيه',
          'Copy': 'نسخ',
          'Pin': 'تثبيت',
          'Share': 'مشاركة',
          'Delete': 'حذف',

          'Contact': 'جهة الاتصال',
          'Document': 'مستند',
          'Location': 'الموقع',
          'Poll': 'استطلاع',
          'Audio': 'صوت',
          'Gallery': 'المعرض',
          'Camera': 'الكاميرا',

          'Voice Message': 'رسالة صوتية',

          'No groups in common': 'لا توجد مجموعات مشتركة',
          'Groups in common': 'مجموعات مشتركة',
          'Create a new group with': 'إنشاء مجموعة جديدة مع',
          'You,': 'أنت،',

          'Starred Messages': 'الرسائل المميزة',
          'No starred messages': 'لا توجد رسائل مميزة',
          'Tap and hold on a message to star it, and it will show up here.':
              'انقر واستمر في الرسالة لتمييزها، وسيظهر هنا.',

          'Search members': 'البحث عن الأعضاء',
          'Save': 'حفظ',
          'Done': 'تم',
          'Message': 'رسالة',
          'Choose Date': 'اختر التاريخ',
          'Choose Time': 'اختر الوقت',
          'Date': 'التاريخ',
          'Time': 'الوقت',

          'Remove': 'إزالة',
          'Make Admin': 'جعله مسؤول',
          'Only View': 'عرض فقط',

          'Group Name': 'اسم المجموعة',
          'Text Here': 'النص هنا',
          'Description': 'الوصف',
          'Make Private': 'جعله خاص',
          'It can view or Join with invite':
              'يمكنه عرضه أو الانضمام بهذه الدعوة',
          'Admin Only': 'المسؤول فقط',
          'Only Admins can share content': 'يمكن للمسؤولين فقط مشاركة المحتوى',

          'No Media': 'لا توجد وسائط',
          'No Links': 'لا توجد روابط',
          'No Docs': 'لا توجد مستندات',

          'None': 'لا شيء',
          'You': 'أنت',

          'Pick a location': 'اختر موقعًا',

          'Media': 'وسائط',
          'Links': 'روابط',
          'Documents': 'مستندات',

          'Type your Message...': 'اكتب رسالتك...',

          '24 hours': '٢٤ ساعة',
          '7 days': '٧ أيام',
          '90 days': '٩٠ يومًا',
          'Always': 'دائمًا',
          'Off': 'إيقاف',

          '8 hours': '٨ ساعات',
          '1 week': '١ أسبوع',

          'Contact Info': 'معلومات الاتصال',
          'See More': 'المزيد',
          'Direct Message': 'رسالة مباشرة',
          'Selected': 'محدد',
          'Add option': 'إضافة خيار',
          'This Week': 'هذا الاسبوع',
          'Last Month': 'الشهر الماضي',
          'Week Ago': 'منذ اسبوع',
          'Today': 'اليوم',

          "Add Member": "إضافة عضو",
          'Group Details': 'تفاصيل المجموعة',
          'Members': 'الأعضاء',
          "Create": "إنشاء",
          'Please enable microphone service!': 'الرجاء تفعيل خدمة الميكروفون!',

          "You Successfully Created a Group": "لقد قمت بإنشاء مجموعة بنجاح",
        },
      };
}
