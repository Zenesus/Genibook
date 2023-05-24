import 'package:flutter/material.dart';
import 'package:genipaws/api/handler.dart';
import 'package:genipaws/cache/objects/objects.dart';
import 'package:genipaws/routes/swipes.dart';
import 'package:genipaws/constants.dart';
import 'package:genipaws/screens/eastereggs/credits.dart';
import 'package:genipaws/screens/login.dart';
import 'package:genipaws/utils/base64_to_image.dart';
import 'package:genipaws/routes/swipe.dart';
import 'package:genipaws/utils/profile_utils.dart';
import 'package:genipaws/widgets/detailed/detailed_profile.dart';
import 'package:genipaws/widgets/navbar.dart';
import 'package:flutter/services.dart';

import '../models/student_class.dart';

class ProfilePage extends StatefulWidget {
  final Student student;

  const ProfilePage({super.key, required this.student});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Map<String, Map<String, double>> gpaHis;
  List<Widget> gpaHistoryList = [];

  @override
  void initState() {
    super.initState();

    gpaHis = {};

    ApiHandler.getGPAhistory(true).then((value) {
      setState(() {
        gpaHis = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      gpaHistoryList = generateGPAHistories(gpaHis, context);
    });
    return GestureDetector(
        onPanUpdate: (details) {
          swipeHandler(details, Constants.profilePageNavNumber, context);
        },
        child: Scaffold(
            appBar: AppBar(
              title: InkWell(
                onTap: () {
                  Navigator.of(context)
                      .push(SlideToRightPageRoute(child: const CreditsPage()));
                },
                child: const Text('Profile'),
              ),
              elevation: 2,
              shadowColor: Theme.of(context).shadowColor,
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                    onPressed: () async {
                      await StoreObjects.logout();
                      // ignore: use_build_context_synchronously
                      Navigator.of(context).push(
                          SlideToRightPageRoute(child: const LoginPage()));
                    },
                    icon: const Icon(Icons.logout))
              ],
            ),
            bottomNavigationBar:
                const Navbar(selectedIndex: Constants.profilePageNavNumber),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                        flex: 4,
                        child: Card(
                            child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Center(
                                child: CircleAvatar(
                                  backgroundImage: Constants.debugMode
                                      ? NetworkImage(widget.student.imageUrl)
                                      : imageFromBase64String(
                                              widget.student.image64)
                                          .image,
                                  radius: 50.0,
                                ),
                              ),
                              Text(
                                widget.student.name,
                                style: const TextStyle(
                                  fontSize: 27.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ))),
                    Expanded(
                        flex: 3,
                        child: Center(
                            child: GestureDetector(
                                onLongPress: () {
                                  HapticFeedback.lightImpact();
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return gimmeDetailedProfileView(
                                          widget.student);
                                    },
                                  );
                                },
                                child: Card(
                                    child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: SingleChildScrollView(
                                            child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children:
                                                    generateUnDetailedProfileInfo(
                                                        widget.student,
                                                        context)))))))),
                    Expanded(
                        flex: 5,
                        child: Card(
                            child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: SizedBox(
                                    height: 100,
                                    child: SingleChildScrollView(
                                        child: Column(
                                      children: gpaHistoryList,
                                    )))))),
                  ],
                ),
              ),
            )));
  }
}
