import 'package:flutter/foundation.dart';
import 'package:genibook/api/rawdata.dart';
import 'package:genibook/cache/objects/config.dart';
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
    } else if (getCached) {
      return eddie;
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

  static Future<ScheduleAssignmentsList> getNewSchedule(bool getCached) async {
    /// it will either be the one [in cache] or [scheduleAssignments] variable in rawdata.dart
    ScheduleAssignmentsList cachedSchedule = await StoreObjects.readSchedule();
    if (getCached && cachedSchedule != scheduleAssignments) {
      return cachedSchedule;
    }
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

  static Future<List<dynamic>> getMPs(bool getCached) async {
    List<dynamic> cachedMps = await ConfigCache.readMPs();
    List<dynamic> apiMps = <dynamic>[];
    Secret secret = await StoreObjects.readSecret();

    if (getCached) {
      return cachedMps;
    }

    final response =
        await http.post(getCorrectUri("/apiv1/mps/", secret.toJson()));
    if (response.statusCode == 200) {
      List<dynamic> mps = json.decode(response.body);
      apiMps = mps;
    } else {
      if (kDebugMode) {
        print("[DEBUG getMPs]: failed to get mps data");
      }
    }

    if (apiMps.isEmpty) {
      if (kDebugMode) {
        print("[DEBUG getMPs] mps is empty");
      }
      return cachedMps;
    } else {
      if (apiMps == cachedMps) {
        return cachedMps;
      } else {
        ConfigCache.storeMPs(apiMps);
        return apiMps;
      }
    }
  }

  static Future<Map<String, Map<String, double>>> getGPAhistory(
      bool getCached) async {
    Map<String, Map<String, double>> cachedHis =
        await ConfigCache.readGPAhistory();

    if (getCached) {
      return cachedHis;
    }

    Map<String, Map<String, double>> ret = {};
    Secret secret = await StoreObjects.readSecret();

    Map<String, String> map = secret.toJson();
    map["mp"] = "FG";

    final response = await http.post(getCorrectUri("/apiv1/gpas_his/", map));
    if (response.statusCode == 200) {
      Map<String, Map<String, double>> resp = json.decode(response.body);
      ret = resp;
    } else {
      if (kDebugMode) {
        print("[DEBUG getGPAhistory]: failed to get gpa history data");
      }
    }

    if (ret.isEmpty) {
      if (kDebugMode) {
        print("[DEBUG getGPAhistory] gpa history data is empty");
      }
      return cachedHis;
    } else {
      ConfigCache.storeGPAHistory(ret);
      return ret;
    }
  }
}
