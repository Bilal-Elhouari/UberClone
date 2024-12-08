import 'package:driver_app/pages/earning_page.dart';
import 'package:driver_app/pages/home_page.dart';
import 'package:driver_app/pages/profile_page.dart';
import 'package:driver_app/pages/trips_page.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with SingleTickerProviderStateMixin
{
  TabController? controller;
  int indexSelected = 0;

onBarItemClicked(int  i)
{
  setState(() {
    indexSelected= i;
    controller!.index = indexSelected;
  });
}

@override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      body: TabBarView(
        physics: const NeverScrollableScrollPhysics(),
        controller: controller,
        children: const [
          HomePage(),
          EarningPage(),
          TripsPage(),
          ProfilePage(),
        ],

      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const
        [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home"
          ),

          BottomNavigationBarItem(
              icon: Icon(Icons.credit_card),
              label: "Earning"
          ),

          BottomNavigationBarItem(
              icon: Icon(Icons.account_tree_rounded),
              label: "Trips"
          ),

          BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: "Profile"
          ),
        ],
        currentIndex: indexSelected,
        //backgroundColor: Colors.grey,
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.blue,
        showSelectedLabels: true,
        selectedLabelStyle: const TextStyle(fontSize: 12),
        type: BottomNavigationBarType.fixed,
        onTap: onBarItemClicked,

      ),
    ) ;
  }
}