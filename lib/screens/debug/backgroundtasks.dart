import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:background_fetch/background_fetch.dart';

// [Android-only] This "Headless Task" is run when the Android app is terminated with `enableHeadless: true`
// Be sure to annotate your callback function to avoid issues in release mode on Flutter >= 3.3.0
@pragma('vm:entry-point')
void backgroundFetchHeadlessTask(HeadlessTask task) async {
  String taskId = task.taskId;
  bool isTimeout = task.timeout;
  if (isTimeout) {
    // This task has exceeded its allowed running-time.
    // You must stop what you're doing and immediately .finish(taskId)
    if (kDebugMode) {
      print("[BackgroundFetch] Headless task timed-out: $taskId");
    }
    BackgroundFetch.finish(taskId);
    return;
  }
  if (kDebugMode) {
    print('[BackgroundFetch] Headless event received.');
  }
  // Do your work here...
  BackgroundFetch.finish(taskId);
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _enabled = true;
  int _status = 0;
  final List<DateTime> _events = [];

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // Configure BackgroundFetch.
    int status = await BackgroundFetch.configure(
        BackgroundFetchConfig(
            minimumFetchInterval: 15,
            stopOnTerminate: false,
            enableHeadless: true,
            requiresBatteryNotLow: true,
            requiresCharging: false,
            requiresStorageNotLow: true,
            requiresDeviceIdle: false,
            requiredNetworkType: NetworkType.ANY), (String taskId) async {
      // <-- Event handler
      // This is the fetch-event callback.
      if (kDebugMode) {
        print("[BackgroundFetch] Event received $taskId");
      }
      setState(() {
        _events.insert(0, DateTime.now());
      });

      switch (taskId) {
        case 'com.transistorsoft.test':
          if (kDebugMode) {
            print("Received custom task");
          }
          break;
        default:
          if (kDebugMode) {
            print("Default fetch task");
          }
      }
      // IMPORTANT:  You must signal completion of your task or the OS can punish your app
      // for taking too long in the background.
      BackgroundFetch.finish(taskId);
    }, (String taskId) async {
      // <-- Task timeout handler.
      // This task has exceeded its allowed running-time.  You must stop what you're doing and immediately .finish(taskId)
      if (kDebugMode) {
        print("[BackgroundFetch] TASK TIMEOUT taskId: $taskId");
      }
      BackgroundFetch.finish(taskId);
    });
    if (kDebugMode) {
      print('[BackgroundFetch] configure success: $status');
    }
    setState(() {
      _status = status;
    });

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }

  void _onClickEnable(enabled) {
    setState(() {
      _enabled = enabled;
    });
    if (enabled) {
      BackgroundFetch.start().then((int status) {
        if (kDebugMode) {
          print('[BackgroundFetch] start success: $status');
        }
      }).catchError((e) {
        if (kDebugMode) {
          print('[BackgroundFetch] start FAILURE: $e');
        }
      });
    } else {
      BackgroundFetch.stop().then((int status) {
        if (kDebugMode) {
          print('[BackgroundFetch] stop success: $status');
        }
      });
    }
  }

  void _onClickStatus() async {
    int status = await BackgroundFetch.status;
    if (kDebugMode) {
      print('[BackgroundFetch] status: $status');
    }
    setState(() {
      _status = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('BackgroundFetch Example',
              style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.amberAccent,
          actions: <Widget>[
            Switch(value: _enabled, onChanged: _onClickEnable),
          ],
          systemOverlayStyle: SystemUiOverlayStyle.dark),
      body: Container(
        color: Colors.black,
        child: ListView.builder(
            itemCount: _events.length,
            itemBuilder: (BuildContext context, int index) {
              DateTime timestamp = _events[index];
              return InputDecorator(
                  decoration: const InputDecoration(
                      contentPadding:
                          EdgeInsets.only(left: 10.0, top: 10.0, bottom: 0.0),
                      labelStyle:
                          TextStyle(color: Colors.amberAccent, fontSize: 20.0),
                      labelText: "[background fetch event]"),
                  child: Text(timestamp.toString(),
                      style: const TextStyle(
                          color: Colors.white, fontSize: 16.0)));
            }),
      ),
      bottomNavigationBar: BottomAppBar(
          child: Row(children: <Widget>[
        ElevatedButton(onPressed: _onClickStatus, child: const Text('Status')),
        Container(
            margin: const EdgeInsets.only(left: 20.0), child: Text("$_status"))
      ])),
    );
  }
}
