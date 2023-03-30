import 'package:flutter/material.dart';
import 'dart:io';
import 'pages/grades.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:window_size/window_size.dart';

void main() async {
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();

  if (UniversalPlatform.isWindows ||
      UniversalPlatform.isLinux ||
      UniversalPlatform.isMacOS) {
    setWindowMinSize(const Size(300, 650));
    setWindowMaxSize(Size.infinite);
  } else {
    // phone!
  }

  runApp(const Genibook());
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class Genibook extends StatelessWidget {
  const Genibook({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grades',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue),
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark(
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: GradesPage(grades: grades, assignments: assignments),
    );
  }
}

Map<String, List<Map<String, dynamic>>> assignments = {
  "Math": [
    {
      "course_name": "Math",
      "mp": "3",
      "dayname": "Monday",
      "full_dayname": "Monday, December 20, 2021",
      "date": "12/20/2021",
      "full_date": "12/20/2021",
      "teacher": "Mr. Smith",
      "category": "Homework",
      "assignment": "Page 40-41, problems 1-10",
      "description": "Complete the assigned problems in your workbook.",
      "grade_percent": "90",
      "grade_num": "9/10",
      "comment": "Great job! Just missed one question.",
      "prev": "N/A",
      "docs": "N/A"
    }
  ],
  "Science": [
    {
      "course_name": "Science",
      "mp": "3",
      "dayname": "Tuesday",
      "full_dayname": "Tuesday, December 21, 2021",
      "date": "12/21/2021",
      "full_date": "12/21/2021",
      "teacher": "Ms. Johnson",
      "category": "Lab Report",
      "assignment": "Experiment 4: Chemical Reactions",
      "description":
          "Write a lab report summarizing the results of the experiment.",
      "grade_percent": "95",
      "grade_num": "19/20",
      "comment": "Excellent work! You just missed a few minor details.",
      "prev": "N/A",
      "docs": "N/A"
    },
    {
      "course_name": "Science",
      "mp": "3",
      "dayname": "Tuesday",
      "full_dayname": "Tuesday, December 21, 2021",
      "date": "12/21/2021",
      "full_date": "12/21/2021",
      "teacher": "Ms. Johnson",
      "category": "Lab Report",
      "assignment": "Experiment 4: Chemical Reactions",
      "description":
          "Write a lab report summarizing the results of the experiment.",
      "grade_percent": "95",
      "grade_num": "19/20",
      "comment": "Excellent work! You just missed a few minor details.",
      "prev": "N/A",
      "docs": "N/A"
    }
  ],
  "English": [
    {
      "course_name": "English",
      "mp": "3",
      "dayname": "Wednesday",
      "full_dayname": "Wednesday, December 22, 2021",
      "date": "12/22/2021",
      "full_date": "12/22/2021",
      "teacher": "Ms. Lee",
      "category": "Essay",
      "assignment": "Persuasive Essay",
      "description": "Write a persuasive essay on the topic given in class.",
      "grade_percent": "85",
      "grade_num": "17/20",
      "comment": "Good job! There were a few errors in grammar and spelling.",
      "prev": "N/A",
      "docs": "N/A"
    }
  ]
};
Map<String, Map<String, dynamic>> grades = {
  'Math': {
    'grade': 85.0,
    'teacher_name': 'John Smith',
    'teacher_email': 'john.smith@example.com'
  },
  'English': {
    'grade': 92.0,
    'teacher_name': 'Jane Doe',
    'teacher_email': 'jane.doe@example.com'
  },
  'Science': {
    'grade': 78.0,
    'teacher_name': 'Bob Johnson',
    'teacher_email': 'bob.johnson@example.com'
  },
};
