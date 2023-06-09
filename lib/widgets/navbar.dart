import 'package:flutter/material.dart';
import 'package:genibook/constants.dart';
import 'package:genibook/routes/navigator.dart';

class Navbar extends StatefulWidget {
  final bool disabled;
  final int selectedIndex;
  // ignore: use_key_in_widget_constructors
  const Navbar({Key? key, required this.selectedIndex, required this.disabled});

  @override
  State<StatefulWidget> createState() => NavBarState();
}

class NavBarState extends State<Navbar> {
  ApiNavigator nav = const ApiNavigator();
  late int _selectedIndex;
  @override
  void initState() {
    // readBday().then((value) {
    //   setState(() {
    //     _isbday = value;
    //   });
    // });
    super.initState();
    setState(() {
      _selectedIndex = widget.selectedIndex;
    });
  }

  void _onItemTapped(int index) async {
    if (widget.disabled) {
      return;
    }
    int selectedIndex = _selectedIndex;
    setState(() {
      _selectedIndex = index;
    });

    bool left = false;
    if (index == Constants.gradePageNavNumber - 1 &&
        selectedIndex == Constants.gradePageNavNumber) {
      left = true;
    } else if (index == Constants.schedulePageNavNumber - 1 &&
        selectedIndex == Constants.schedulePageNavNumber) {
      left = true;
    }
    nav.useNumbersToDetermine(index, context, left);
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.text_increase),
          label: 'Grades',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.schedule),
          label: 'Schedule',
        ),
      ],
      currentIndex: _selectedIndex,
      // backgroundColor: _isbday ? Colors.amber[700] : null,
      // selectedItemColor: _isbday ? Colors.white : primaryColorColor,
      onTap: _onItemTapped,
    );
  }
}
