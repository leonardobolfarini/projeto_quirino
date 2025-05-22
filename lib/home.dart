import 'package:flutter/material.dart';
import 'components/profile.dart';
import 'components/rewards.dart';
import 'components/task.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePage createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  int _currentIndexPage = 0;

  void _onChangePage(int index) {
    setState(() {
      _currentIndexPage = index;
    });
  }

  static final List<Widget> _pages = <Widget>[
    Profile(),
    TaskScreen(),
    RewardScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Taskompensas',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Icon(Icons.local_fire_department_rounded, color: Colors.white),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndexPage,
        onTap: _onChangePage,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
          BottomNavigationBarItem(
            icon: Icon(Icons.task_alt_rounded),
            label: 'Tarefas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_giftcard_outlined),
            label: 'Recompensas',
          ),
        ],
      ),
      body: _pages[_currentIndexPage],
    );
  }
}
