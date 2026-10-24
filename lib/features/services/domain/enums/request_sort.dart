/// Module: services / domain / enums
///
///*************************** FILE INFO ****************************///
/// File Name: request_sort.dart
/// Purpose: How a list of service requests is sorted (requests, approvals).
/// Author: Amr Mesbah
/// Created at: 18/10/2026
library;

/// Sort order of a request list; every option sorts newest / longest first.
enum RequestSort { dateRequested, duration, lastUpdate }
