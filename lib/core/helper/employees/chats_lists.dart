// Date Created :21/November/2023
// Developer Name : Mazen shabaan
//App Version : Version 2
// Date of Last Edit :21/November/2023
// Objectives: this is a widget to customize the ;lists in the app
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:demo_app/core/helper/employees/core_widgets/main_widget/day_container.dart';

/*
List<GroupData> channels = [
  GroupData(
      groupName: "Bayanatz Ui Design",
      imageUrl: "assets/images/original.png",
      messageContent: "React to Message"),
  GroupData(
      groupName: "Bayanatz Backend",
      imageUrl: "assets/images/original.png",
      messageContent: "React to Message"),
  GroupData(
      groupName: "Bayanatz ui/UX",
      imageUrl: "assets/images/original.png",
      messageContent: "React to Message"),
  GroupData(
      groupName: "Bayanatz Ui Design",
      imageUrl: "assets/images/original.png",
      messageContent: "React to Message"),
  GroupData(
      groupName: "Bayanatz Ui Design",
      imageUrl: "assets/images/original.png",
      messageContent: "React to Message"),
  GroupData(
      groupName: "Bayanatz Ui Design",
      imageUrl: "assets/images/original.png",
      messageContent: "React to Message"),
  GroupData(
      groupName: "Bayanatz Ui Design",
      imageUrl: "assets/images/original.png",
      messageContent: "React to Message"),
  GroupData(
      groupName: "Bayanatz Ui Design",
      imageUrl: "assets/images/original.png",
      messageContent: "React to Message"),
];
List<DmCard> dms = [
  const DmCard(
      imageUrl: "assets/images/profile.png",
      name: "Ahmed Magdy",
      jobTitle: "Leader",
      messageText: "I have a problem with the app cause I can’t chang",
      isMe: false,
      numUnRead: 3,
      isDeleted: false),
  const DmCard(
      imageUrl: "assets/images/profile1.png",
      name: "Mohamed ali",
      jobTitle: "Marketer",
      isMe: false,
      numUnRead: null,
      isDeleted: false,
      sentPhoto: "assets/images/profile.png"),
  const DmCard(
      imageUrl: "assets/images/profile.png",
      name: "Ahmed Magdy",
      jobTitle: "Leader",
      messageText: "I have a problem with the app cause I can’t chang",
      isMe: false,
      numUnRead: 3,
      isDeleted: false),
  const DmCard(
      imageUrl: "assets/images/profile1.png",
      name: "Mohamed ali",
      jobTitle: "Marketer",
      isMe: false,
      numUnRead: null,
      isDeleted: false,
      sentPhoto: "assets/images/profile.png"),
  const DmCard(
      imageUrl: "assets/images/profile1.png",
      name: "Mohamed ali",
      jobTitle: "Marketer",
      isMe: false,
      numUnRead: null,
      isDeleted: false,
      sentPhoto: "assets/images/profile.png"),
];
*/

// meetings_lists
List<DayData> days = [
  DayData(
      isToday: true,
      dayNumber: DateTime.now().day,
      dayLetter: DateFormat.EEEE().format(DateTime.now()),
      meetingsData: [
        Meeting(
            meetingName: "Basic Education",
            startTime: "9:00 AM",
            endTime: "10:00 AM",
            isSoon: false),
        Meeting(
            meetingName: "Parent's Meeting",
            startTime: "11:00 AM",
            endTime: "12:00 PM",
            isSoon: false),
        Meeting(
            meetingName: "Meeting With Teachers",
            startTime: "01:00 PM",
            endTime: "02:00 AM",
            isSoon: true)
      ]),
  DayData(
      isToday: false,
      dayNumber: DateTime.now().day + 1,
      dayLetter: DateFormat.EEEE().format(DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day + 1)),
      meetingsData: [
        Meeting(
            meetingName: "Basic Education",
            startTime: "9:00 AM",
            endTime: "10:00 AM",
            isSoon: false),
        Meeting(
            meetingName: "Parent's Meeting",
            startTime: "11:00 AM",
            endTime: "12:00 PM",
            isSoon: false),
        Meeting(
            meetingName: "Meeting With Teachers",
            startTime: "01:00 PM",
            endTime: "02:00 AM",
            isSoon: false)
      ]),
  DayData(
      isToday: false,
      dayNumber: DateTime.now().day + 2,
      dayLetter: DateFormat.EEEE().format(DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day + 2)),
      meetingsData: [
        Meeting(
            meetingName: "Basic Education",
            startTime: "9:00 AM",
            endTime: "10:00 AM",
            isSoon: false),
        Meeting(
            meetingName: "Parent's Meeting",
            startTime: "11:00 AM",
            endTime: "12:00 PM",
            isSoon: false),
        Meeting(
            meetingName: "Meeting With Teachers",
            startTime: "1:00 PM",
            endTime: "2:00 AM",
            isSoon: false)
      ]),
  DayData(
      isToday: false,
      dayNumber: DateTime.now().day + 3,
      dayLetter: DateFormat.EEEE().format(DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day + 3)),
      meetingsData: [
        Meeting(
            meetingName: "Basic Education",
            startTime: "9:00 AM",
            endTime: "10:00 AM",
            isSoon: false),
        Meeting(
            meetingName: "Parent's Meeting",
            startTime: "11:00 AM",
            endTime: "12:00 PM",
            isSoon: false),
        Meeting(
            meetingName: "Meeting With Teachers",
            startTime: "1:00 PM",
            endTime: "2:00 AM",
            isSoon: false)
      ]),
  DayData(
      isToday: false,
      dayNumber: DateTime.now().day + 4,
      dayLetter: DateFormat.EEEE().format(DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day + 4)),
      meetingsData: [
        Meeting(
            meetingName: "Basic Education",
            startTime: "9:00 AM",
            endTime: "10:00 AM",
            isSoon: false),
        Meeting(
            meetingName: "Parent's Meeting",
            startTime: "11:00 AM",
            endTime: "12:00 PM",
            isSoon: false),
        Meeting(
            meetingName: "Meeting With Teachers",
            startTime: "1:00 PM",
            endTime: "2:00 AM",
            isSoon: false)
      ]),
  DayData(
      isToday: false,
      dayNumber: DateTime.now().day + 5,
      dayLetter: DateFormat.EEEE().format(DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day + 5)),
      meetingsData: [
        Meeting(
            meetingName: "Basic Education",
            startTime: "9:00 AM",
            endTime: "10:00 AM",
            isSoon: false),
        Meeting(
            meetingName: "Parent's Meeting",
            startTime: "11:00 AM",
            endTime: "12:00 PM",
            isSoon: false),
        Meeting(
            meetingName: "Meeting With Teachers",
            startTime: "1:00 PM",
            endTime: "2:00 AM",
            isSoon: false)
      ]),
  DayData(
      isToday: false,
      dayNumber: DateTime.now().day + 6,
      dayLetter: DateFormat.EEEE().format(DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day + 6)),
      meetingsData: [
        Meeting(
            meetingName: "Basic Education",
            startTime: "9:00 AM",
            endTime: "10:00 AM",
            isSoon: false),
        Meeting(
            meetingName: "Parent's Meeting",
            startTime: "11:00 AM",
            endTime: "12:00 PM",
            isSoon: false),
        Meeting(
            meetingName: "Meeting With Teachers",
            startTime: "01:00 PM",
            endTime: "02:00 AM",
            isSoon: false)
      ]),
];
List<String> filterElements = [
  'All',
  'Marketing',
  'Design',
  'Software',
  'HR',
];
List<String> teams = [
  "Marketing Team".tr,
  "Development Team".tr,
  "Media Team".tr,
  "Tech Team".tr
];

class AtendanceData {
  AtendanceData(
      {required this.date,
      required this.status,
      required this.oncomingTime,
      required this.leavingTime,
      required this.breakTime,
      required this.totalTime});

  final String date;

  final String status;

  final String oncomingTime;

  final String leavingTime;

  final String breakTime;
  final String totalTime;
}

List<AtendanceData> attData = [
  AtendanceData(
      date: "${'Feb'.tr} 25,2022",
      status: 'Attendance',
      oncomingTime: "9:00 AM",
      leavingTime: "12:00 PM",
      breakTime: "10:00 AM",
      totalTime: '2:30 ${'Hour'.tr}'),
  AtendanceData(
      date: "${'Feb'.tr} 25,2022",
      status: 'Absent',
      oncomingTime: '----',
      leavingTime: '----',
      breakTime: '----',
      totalTime: '----'),
  AtendanceData(
      date: "${'Feb'.tr} 25,2022",
      status: 'Late',
      oncomingTime: '9:05 ${'AM'.tr}',
      leavingTime: "12:00 PM",
      breakTime: "10:00 AM",
      totalTime: '2:30 ${'Hour'.tr}'),
  AtendanceData(
      date: "${'Feb'.tr} 25,2022",
      status: 'Attendance',
      oncomingTime: "9:00 AM",
      leavingTime: "12:00 PM",
      breakTime: "10:00 AM",
      totalTime: '2:30 ${'Hour'.tr}'),
  AtendanceData(
      date: "${'Feb'.tr} 25,2022",
      status: 'Absent',
      oncomingTime: '----',
      leavingTime: '----',
      breakTime: '----',
      totalTime: '----'),
  AtendanceData(
      date: "${'Feb'.tr} 25,2022",
      status: 'Absent',
      oncomingTime: '----',
      leavingTime: '----',
      breakTime: '----',
      totalTime: '----'),
  AtendanceData(
      date: "${'Feb'.tr} 25,2022",
      status: 'Absent',
      oncomingTime: '----',
      leavingTime: '----',
      breakTime: '----',
      totalTime: '----'),
  AtendanceData(
      date: "${'Feb'.tr} 25,2022",
      status: 'Attendance',
      oncomingTime: "9:00 AM",
      leavingTime: "12:00 PM",
      breakTime: "10:00 AM",
      totalTime: '2:30 ${'Hour'.tr}'),
  AtendanceData(
      date: "${'Feb'.tr} 25,2022",
      status: 'Attendance',
      oncomingTime: "9:00 AM",
      leavingTime: "12:00 PM",
      breakTime: "10:00 AM",
      totalTime: '2:30 ${'Hour'.tr}'),
  AtendanceData(
      date: "${'Feb'.tr} 25,2022",
      status: 'Absent',
      oncomingTime: '----',
      leavingTime: '----',
      breakTime: '----',
      totalTime: '----'),
];

class RequestsData {
  /// Creates the RequestsData class with required details.
  RequestsData({
    required this.date,
    required this.status,
    required this.type,
    required this.totalTime,
    required this.rejectedReason,
    // ignore: non_constant_identifier_names
    required this.Action,
  });

  final String date;

  final String status;

  final String type;

  final String rejectedReason;

  // ignore: non_constant_identifier_names
  final String Action;
  final String totalTime;
}

List<RequestsData> requestsDat = [
  RequestsData(
      date: "${'Feb'.tr} 25,2022",
      status: 'Approved',
      type: 'Sick Leave',
      totalTime: '3 ${'Days'.tr}',
      rejectedReason: '----',
      Action: 'Escalates'),
  RequestsData(
      date: "${'Feb'.tr} 25,2022",
      status: 'Rejected',
      type: 'Permission',
      totalTime: '3 ${'Hour'.tr}',
      rejectedReason: 'loarem ipsumloarem ipsumlpsum',
      Action: 'Escalates'),
  RequestsData(
      date: "${'Feb'.tr} 25,2022",
      status: 'Pending',
      type: 'Sick Leave',
      totalTime: '3 ${'Days'.tr}',
      rejectedReason: '----',
      Action: 'Escalates'),
  RequestsData(
      date: "${'Feb'.tr} 25,2022",
      status: 'Approved',
      type: 'Permission',
      totalTime: '3 ${'Hour'.tr}',
      rejectedReason: '----',
      Action: 'Escalates'),
  RequestsData(
      date: "${'Feb'.tr} 25,2022",
      status: 'Rejected',
      type: 'Permission',
      totalTime: '3 ${'Hour'.tr}',
      rejectedReason: 'loarem ipsumloarem ipsumlpsum',
      Action: 'Escalates'),
  RequestsData(
      date: "${'Feb'.tr} 25,2022",
      status: 'Rejected',
      type: 'Sick Leave',
      totalTime: '3 ${'Hour'.tr}',
      rejectedReason: 'loarem ipsumloarem ipsumlpsum',
      Action: 'Escalates'),
  RequestsData(
      date: "${'Feb'.tr} 25,2022",
      status: 'Approved',
      type: 'Permission',
      totalTime: '3 ${'Hour'.tr}',
      rejectedReason: '----',
      Action: 'Escalates'),
  RequestsData(
      date: "${'Feb'.tr} 25,2022",
      status: 'Approved',
      type: 'Permission',
      totalTime: '3 ${'Hour'.tr}',
      rejectedReason: '----',
      Action: 'Escalates'),
  RequestsData(
      date: "${'Feb'.tr} 25,2022",
      status: 'Approved',
      type: 'Permission',
      totalTime: '3 ${'Hour'.tr}',
      rejectedReason: '----',
      Action: 'Escalates'),
  RequestsData(
      date: "${'Feb'.tr} 25,2022",
      status: 'Rejected',
      type: 'Permission',
      totalTime: '3 ${'Hour'.tr}',
      rejectedReason: 'loarem ipsumloarem ipsumlpsum',
      Action: 'Escalates'),
];

class WorkDayData {
  /// Creates the Data class with required details.
  WorkDayData({
    required this.days,
    required this.checkIn,
    required this.checkOut,
  });

  final String days;

  final String checkIn;

  final String checkOut;
}

List<WorkDayData> workDayDat = [
  WorkDayData(days: "Sunday", checkIn: '9:00 AM', checkOut: '3:00 PM'),
  WorkDayData(days: "Monday", checkIn: '9:00 AM', checkOut: '3:00 PM'),
  WorkDayData(days: "Tuesday", checkIn: '9:00 AM', checkOut: '3:00 PM'),
  WorkDayData(days: "Wednesday", checkIn: '9:00 AM', checkOut: '3:00 PM'),
  WorkDayData(days: "Thursday", checkIn: '9:00 AM', checkOut: '3:00 PM'),
  WorkDayData(days: "Friday", checkIn: 'Weekend', checkOut: 'Weekend'),
  WorkDayData(days: "Saturday", checkIn: 'Weekend', checkOut: 'Weekend'),
];

List<EmployeesData> emploData = [
  EmployeesData(
      firstName: "Ahmed",
      lastName: "Mohamed",
      profession: 'Software Engineer',
      imageUrl: "assets/images/profile.png",
      dateMonth: "Feb",
      dateyear: "25,2022",
      status: 'Attendance',
      oncomingTime: '9:00 AM',
      leavingTime: '12:00 PM',
      totalTime: '2:30 ${'Hour'.tr}',
      phoneNumber: '011204005965',
      action: 'See More'),
  EmployeesData(
      firstName: "Ahmed",
      lastName: "Mohamed",
      profession: 'Flutter Developer',
      imageUrl: "assets/images/profile.png",
      dateMonth: "Feb",
      dateyear: "25,2022",
      status: 'Absent',
      oncomingTime: '----',
      leavingTime: '----',
      totalTime: '----',
      phoneNumber: '011204005965',
      action: 'See More'),
  EmployeesData(
      firstName: "Ahmed",
      lastName: "Mohamed",
      profession: 'BackEnd Developer',
      imageUrl: "assets/images/profile.png",
      dateMonth: "Feb",
      dateyear: "25,2022",
      status: 'Late',
      oncomingTime: '9:05 AM',
      leavingTime: '12:00 PM',
      phoneNumber: '011204005965',
      totalTime: '2:30 ${'Hour'.tr}',
      action: 'See More'),
  EmployeesData(
      firstName: "Ahmed",
      lastName: "Mohamed",
      profession: 'Project Manager',
      imageUrl: "assets/images/profile.png",
      dateMonth: "Feb",
      dateyear: "25,2022",
      status: 'Attendance',
      oncomingTime: '9:00 AM',
      phoneNumber: '011204005965',
      leavingTime: '12:00 PM',
      totalTime: '2:30 ${'Hour'.tr}',
      action: 'See More'),
  EmployeesData(
      firstName: "Ahmed",
      lastName: "Mohamed",
      profession: 'Software Engineer',
      imageUrl: "assets/images/profile.png",
      dateMonth: "Feb",
      dateyear: "25,2022",
      status: 'Absent',
      oncomingTime: '----',
      leavingTime: '----',
      totalTime: '----',
      phoneNumber: '011204005965',
      action: 'See More'),
  EmployeesData(
      firstName: "Ahmed",
      lastName: "Mohamed",
      profession: 'Software Engineer',
      imageUrl: "assets/images/profile.png",
      dateMonth: "Feb",
      dateyear: "25,2022",
      status: 'Absent',
      oncomingTime: '----',
      leavingTime: '----',
      phoneNumber: '011204005965',
      totalTime: '----',
      action: 'See More'),
  EmployeesData(
      firstName: "Ahmed",
      lastName: "Mohamed",
      profession: 'Software Engineer',
      imageUrl: "assets/images/profile.png",
      dateMonth: "Feb",
      dateyear: "25,2022",
      status: 'Attendance',
      oncomingTime: '9:00 AM',
      leavingTime: '12:00 PM',
      totalTime: '2:30 ${'Hour'.tr}',
      phoneNumber: '011204005965',
      action: 'See More'),
  EmployeesData(
      firstName: "Ahmed",
      lastName: "Mohamed",
      profession: 'Software Engineer',
      imageUrl: "assets/images/profile.png",
      dateMonth: "Feb",
      dateyear: "25,2022",
      status: 'Attendance',
      oncomingTime: '9:00 AM',
      leavingTime: '12:00 PM',
      totalTime: '2:30 ${'Hour'.tr}',
      phoneNumber: '011204005965',
      action: 'See More'),
  EmployeesData(
      firstName: "Ahmed",
      lastName: "Mohamed",
      profession: 'Software Engineer',
      imageUrl: "assets/images/profile.png",
      dateMonth: "Feb",
      dateyear: "25,2022",
      status: 'Attendance',
      oncomingTime: '9:00 AM',
      leavingTime: '12:00 PM',
      totalTime: '2:30 ${'Hour'.tr}',
      phoneNumber: '011204005965',
      action: 'See More'),
  EmployeesData(
      firstName: "Ahmed",
      lastName: "Mohamed",
      imageUrl: "assets/images/profile.png",
      dateMonth: "Feb",
      dateyear: "25,2022",
      status: 'Absent',
      profession: 'Software Engineer',
      oncomingTime: '----',
      leavingTime: '----',
      totalTime: '----',
      phoneNumber: '011204005965',
      action: 'See More'),
];

/// Custom business object class which contains properties to hold the detailed
/// information about the Data which will be rendered in datagrid.
class EmployeesData {
  /// Creates the Data class with required details.
  EmployeesData({
    required this.firstName,
    required this.lastName,
    required this.imageUrl,
    required this.dateMonth,
    required this.dateyear,
    required this.status,
    required this.oncomingTime,
    required this.leavingTime,
    required this.totalTime,
    required this.action,
    required this.profession,
    required this.phoneNumber,
  });
  final String firstName;
  final String lastName;
  final String imageUrl;
  final String dateMonth;
  final String dateyear;
  final String profession;
  final String status;
  final String phoneNumber;
  final String oncomingTime;

  final String leavingTime;

  final String action;
  final String totalTime;
}
