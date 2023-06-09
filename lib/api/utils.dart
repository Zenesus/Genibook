import 'package:genibook/api/handler.dart';
import 'package:genibook/constants.dart';
import 'package:genibook/models/student_class.dart';

Uri getCorrectUri(String ending, Map<String, String> map) {
  Uri url;
  if (Constants.url.startsWith("127")) {
    url = Uri(
      host: Constants.url,
      path: ending,
      scheme: "http",
      queryParameters: map,
    );
    // url = Uri.http(Constants.url, ending, );
  } else {
    //url is https
    url = Uri(
      host: Constants.url,
      path: ending,
      scheme: "https",
      queryParameters: map,
    );
  }

  return url;
}

Future<Student> refreshAllData(bool backgroundTask) async {
  Student stud = await ApiHandler.getNewStudent(false, backgroundTask);
  await ApiHandler.getNewSchedule(false);
  await ApiHandler.getMPs(false);
  await ApiHandler.getGPAhistory(false);
  await ApiHandler.getGpa(false);
  return stud;
}

Future<Student> refreshMPStudentSchedule() async {
  Student stud = await ApiHandler.getNewStudent(false, false);
  await ApiHandler.getNewSchedule(false);
  await ApiHandler.getMPs(false);
  await ApiHandler.getGpa(false);
  return stud;
}

Future<void> refreshGPAHistory() async {
  await ApiHandler.getGPAhistory(false);
}
