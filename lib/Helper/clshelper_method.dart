//return a formatted data as a String
import 'package:cloud_firestore/cloud_firestore.dart';

String formatDate({required Timestamp timestamp}) {
  // Timestamp is the object we retrieve from the firebase
  // so to display it, lets convert it into String

  // get DateTime
  DateTime dateTime = timestamp.toDate();

  // get year
  String year = dateTime.year.toString();

  // get month
  String month = dateTime.month.toString();

  // get day
  String day = dateTime.day.toString();

  // formatted date
  String formattedData = '$day/$month/$year';

  return formattedData;
}
