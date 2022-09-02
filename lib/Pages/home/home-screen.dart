import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:sure_keep/All-Constants/all_constants.dart';
import 'package:sure_keep/Pages/home/home-content/ListAllContactsPhone.dart';
import 'package:sure_keep/Provider/auth-provider.dart';

import '../../Chat/person-who-chatted-you.dart';
import '../../Models/user-model.dart';

class Home extends StatefulWidget {
  final UserModel userData;

  const Home({required this.userData, Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  PageController? _pageController;
  late AnimationController animationController;
  late List<Widget> _pages;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    _pageController = PageController(initialPage: _selectedIndex);
    animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));

    _pages = <Widget>[
      ListAllContactPhone(userData: widget.userData),
      // const Icon(
      //   Icons.message_outlined,
      //   size: 150,
      // ),
      const Icon(
        Icons.search,
        size: 150,
      ),
      const Icon(
        Icons.contact_phone_outlined,
        size: 150,
      ),
    ];
    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80.0),
        child: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: AppBar(
            title: Column(
              children: [
                Text(
                  _selectedIndex == 1 ? "Search" :  _selectedIndex == 2 ? "Chat" :"People",
                ),
                Text(widget.userData.firstName.toString(),style: TextStyle(fontSize: 12),),
              ],
            ),
            automaticallyImplyLeading: false,
            centerTitle: true,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(12.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  widget.userData.imageUrl.toString(),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: () {
                    AuthProvider.logout(context);
                  },
                  child: Icon(Icons.logout),
                ),
              ),
            ],
          ),
        ),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (newpage) {
          setState(() {
            this._selectedIndex = newpage;
          });
        },
        children: [
          ListAllContactPhone(userData: widget.userData),
          Icon(Icons.search),
          const PersonWhoChattedYou(),
          //ListAllContactPhone(),

          // IndexedStack(
          //   index: _selectedIndex,
          //   children: _pages,
          // ),
        ],
      ),

      // bottomNavigationBar: SizeTransition(
      // sizeFactor: animationController,
      // axisAlignment: -1.0,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        //New
        backgroundColor: AppColors.logoColor,
        // iconSize: 40,
        mouseCursor: SystemMouseCursors.grab,

        selectedFontSize: 12,
        selectedIconTheme: const IconThemeData(color: Colors.white, size: 40),
        selectedItemColor: Colors.white,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),

        //hide label text
        //showSelectedLabels: false,
        //showUnselectedLabels: false,

        unselectedIconTheme: const IconThemeData(
          color: Colors.grey,
        ),

        onTap: (index) {
          _pageController?.animateToPage(index,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeIn);
        },
        //onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.home),
          //   label: 'Home',
          // ),
          BottomNavigationBarItem(
            icon: Icon(Icons.contact_phone_outlined),
            label: 'Contact',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Chat',
          ),
        ],
      ),
    );
  }
}
