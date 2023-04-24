import 'package:flutter/foundation.dart';
import 'package:genibook/api/rawdata.dart';
import 'package:genibook/cache/objects/objects.dart';
import 'package:genibook/api/utils.dart';
import 'package:genibook/models/schedule_class.dart';
import 'package:genibook/models/secret.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:core';

import 'package:genibook/models/student_class.dart';

class ApiHandler {
  ApiHandler._();

  static Future<Map<String, dynamic>> loadData(
      String ending, Map<String, String> data) async {
    final response = await http.post(getCorrectUri(ending, data));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      if (kDebugMode) {
        print("[DEBUG loadData]: failed to get data");
      }
      return {};
    }
  }

  static Future<bool> login(Secret secret) async {
    final response =
        await http.post(getCorrectUri("/apiv1/login/", secret.toJson()));
    if (response.statusCode == 200) {
      return true;
    } else {
      if (kDebugMode) {
        print(response.statusCode);
        print("[DEBUG login]: failed to login");
      }
      return false;
    }
  }

  static Future<Student> getNewStudent(bool getCached) async {
    if (kDebugMode) {
      print("[DEBUG: getNewStudent()]: calling getNewStudent()");
    }

    /// currentStudent is either [eddie] or the [Student] in the cache
    Student currentStudent = await StoreObjects.readStudent();

    if (currentStudent != eddie && getCached) {
      return currentStudent;
    }
    // secrets are stored before calling this function.
    Secret secret = await StoreObjects.readSecret();
    Map<String, dynamic> json =
        await loadData("/apiv1/student/", secret.toJson());
    if (json.isEmpty) {
      if (kDebugMode) {
        print("[DEBUG: getNewStudent()] json is empty");
      }
      return currentStudent;
    } else {
      if (kDebugMode) {
        print("[DEBUG]: getNewStudent() json is NOT empty");
      }
      Student apiStudent = Student.fromJson(json);
      if (apiStudent == currentStudent) {
        return currentStudent;
      } else {
        StoreObjects.storeStudent(apiStudent);
        return apiStudent;
      }
    }
  }

  static Future<ScheduleAssignmentsList> getNewSchedule() async {
    /// it will either be the one [in cache] or [scheduleAssignments] variable in rawdata.dart
    ScheduleAssignmentsList cachedSchedule = await StoreObjects.readSchedule();
    Secret secret = await StoreObjects.readSecret();
    Map<String, dynamic> json =
        await loadData("/apiv1/schedule/", secret.toJson());

    if (json.isEmpty) {
      if (kDebugMode) {
        print("[DEBUG getNewSchedule] json is empty");
      }
      return cachedSchedule;
    } else {
      ScheduleAssignmentsList apiSchedule =
          ScheduleAssignmentsList.fromJson(json);
      if (apiSchedule == cachedSchedule) {
        return cachedSchedule;
      } else {
        StoreObjects.storeSchedule(apiSchedule);
        return apiSchedule;
      }
    }
  }

  static Future<List<String>> getMPs() async {
    List<String> cachedMps = await StoreObjects.readMPs();
    List<String> apiMps = [];
    Secret secret = await StoreObjects.readSecret();

    final response =
        await http.post(getCorrectUri("/apiv1/mps/", secret.toJson()));
    if (response.statusCode == 200) {
      apiMps = json.decode(response.body);
    } else {
      if (kDebugMode) {
        print("[DEBUG getMPs]: failed to get mps data");
      }
    }

    if (apiMps.isEmpty) {
      if (kDebugMode) {
        print("[DEBUG getNewSchedule] mps is empty");
      }
      return cachedMps;
    } else {
      if (apiMps == cachedMps) {
        return cachedMps;
      } else {
        StoreObjects.storeMPs(apiMps);
        return apiMps;
      }
    }
  }
}
