import 'package:flutter/material.dart';

Color statusColor(String? status) {
  switch (status) {
    case 'Pending':
      return Colors.orange;
    case 'Completed':
      return Colors.green;
    case 'Doctor_Accepted':
      return Colors.blue;
    default:
      return Colors.grey;
  }
}

String statusText(dynamic status) {
  switch (status) {
    case 0:
    case '0':
      return 'Pending';
    case 1:
    case '1':
      return 'Admin_Rejected';
    case 2:
    case '2':
      return 'Admin_Accepted';
    case 3:
    case '3':
      return 'Doctor_Accepted';
    case 4:
    case '4':
      return 'Doctor_Rejected';
    default:
      return status?.toString() ?? '';
  }
} 