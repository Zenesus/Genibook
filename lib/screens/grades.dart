import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:genibook/constants.dart';
import 'package:genibook/screens/settings/grades_settings.dart';
import 'package:genibook/utils/grades_utils.dart';
import 'package:genibook/widgets/navbar.dart';
import '../utils/swipe.dart';
import 'assignments.dart';
import '../models/student_class.dart';
import 'package:genibook/screens/settings/grades_settings.dart';

class GradesPage extends StatefulWidget {
  final Student student;

  const GradesPage({super.key, required this.student});

  @override
  // ignore: library_private_types_in_public_api
  _GradesPageState createState() => _GradesPageState();
}

class _GradesPageState extends State<GradesPage> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onPanUpdate: (details) {
          swipeHandler(details, Constants.gradePageNavNumber, context);
        },
        child: Scaffold(
          bottomNavigationBar:
              const Navbar(selectedIndex: Constants.gradePageNavNumber),
          appBar: AppBar(
            title: const Text('Grades'),
            elevation: 2,
            shadowColor: Theme.of(context).shadowColor,
            automaticallyImplyLeading: false,
            actions: [
              SizedBox(
                  height: 50,
                  width: 50,
                  child: IconButton(
                      onPressed: (() async {
                        // ApiHandler.getNewStudent(false);
                        showGradesSettingsView(context);
                      }),
                      icon: const Icon(Icons.settings))),
            ],
          ),
          body: SafeArea(
            child: ListView.builder(
              itemCount: widget.student.grades.length,
              itemBuilder: (BuildContext context, int index) {
                if (kDebugMode) {
                  if (Constants.debugModePrintEVERYTHING) {
                    print(
                        "[DEBUG: Grades page build, Item builder]: ${widget.student.grades.toJson()}");
                  }
                  print(
                      "[DEBUG: Grades page build, Item builder]: $index , ${widget.student.grades.keys.elementAt(index)}");
                }
                String courseName = widget.student.grades.keys.elementAt(index);
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AssignmentPage(
                          assignmentsForAClass:
                              widget.student.assignments[courseName],
                        ),
                      ),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.all(16.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            courseName,
                            style: const TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          Text(
                            'Teacher: ${widget.student.grades.getSubjectTeacherName(courseName)}',
                            style: const TextStyle(fontSize: 18.0),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            'Email: ${widget.student.grades.getSubjectTeacherEmail(courseName)}',
                            style: const TextStyle(fontSize: 18.0),
                          ),
                          const SizedBox(height: 16.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Grade:',
                                style: TextStyle(fontSize: 18.0),
                              ),
                              Text(
                                widget.student.grades
                                    .getSubjectGrade(courseName)
                                    .toString(),
                                style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                    color: getColorFromGrade(widget
                                        .student.grades
                                        .getSubjectGrade(courseName))),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ));
  }
}
