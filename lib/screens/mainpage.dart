import 'package:cargo_driver/brand_colors.dart';
import 'package:cargo_driver/helpers/pushnotificationservice.dart';
import 'package:cargo_driver/tabs/earningstab.dart';
import 'package:cargo_driver/tabs/hometab.dart';
import 'package:cargo_driver/tabs/profile.dart';
import 'package:cargo_driver/tabs/ratingstab.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  static const String id = 'mainpage';
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with SingleTickerProviderStateMixin{
  late TabController _tabController;

  int selectedIndex = 0;

  void onItemClicked(int index){

    setState(() {
      selectedIndex = index;
      _tabController.index = selectedIndex;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

  }

  @override
  void dispose() {
    // TODO: implement dispose
    _tabController.dispose();
    super.dispose();

  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: TabBarView(
        physics: const NeverScrollableScrollPhysics(),
        controller: _tabController,
        children: const <Widget>[
          HomeTab(),
          EarningsTab(),
          RatingsTab(),
          ProfileTab()
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items:const <BottomNavigationBarItem> [
            BottomNavigationBarItem(icon: Icon(Icons.home),
            title: Text("Home")
            ),
          BottomNavigationBarItem(icon: Icon(Icons.credit_card),
              title: Text("Earnings")
          ),
          BottomNavigationBarItem(icon: Icon(Icons.star),
              title: Text("Ratings")
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person),
              title: Text("Account")
          ),
        ],
        unselectedItemColor: BrandColors.colorIcon,
        selectedItemColor: BrandColors.colorOrange,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontSize: 12),
        type: BottomNavigationBarType.fixed,
        onTap: onItemClicked,
        currentIndex: selectedIndex,
      ),

    );
  }
}
