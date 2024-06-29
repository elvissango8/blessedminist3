import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mev/Screens/AboutScreen.dart';
import 'package:mev/Screens/DailyVerseScreen.dart';
import 'package:mev/Screens/HymsScreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:mev/Screens/LoginScreen.dart';

import 'Screens/ManageScreen.dart';



void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  runApp(const MyApp());

}













class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Daily Bible Verses',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
       /* textTheme: TextTheme(
          bodyText1: TextStyle(fontFamily: 'Poppins'),
          bodyText2: TextStyle(fontFamily: 'Poppins'),
          he
            flutterfire configure --project=mevapppadline1: TextStyle(fontFamily: 'Poppins'),
          headline2: TextStyle(fontFamily: 'Poppins'),
          headline3: TextStyle(fontFamily: 'Poppins'),
          headline4: TextStyle(fontFamily: 'Poppins'),
          headline5: TextStyle(fontFamily: 'Poppins'),
          headline6: TextStyle(fontFamily: 'Poppins'),
        ),*/
      ),
      home:  CheckAuthScreen(),
    );
  }
}

class CheckAuthScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          return HomeScreen();
        } else {
          return LoginScreen();
        }
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
 HomeScreen();




  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _children = [
    DailyVerseScreen(),
    HymsScreen(),
    ManageScreen(),
    AboutScreen(),
  ];

  void onTabTapped(int index) {
    if(index ==3){
      Get.to(AboutScreen());
    }
   else if(index ==2){
      Get.to(ManageScreen());
    }
    setState(() {
      if(index!=3&&index!=2) {
        _currentIndex = index;
      }




    });
  }




  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Get.offAll(LoginScreen());
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,

        backgroundColor: Colors.black,

        title: Text('Blessed Daily Verses & Hyms App',style: TextStyle(color: Colors.white,fontSize: 18),),

        actions: [
          PopupMenuButton<String>(
            color: Colors.white,

            onSelected: (value) {
              if (value == 'logout') {
                _logout();
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'logout',
                  child: Text('Logout'),
                ),
              ];
            },
          ),
        ],
      ),

      body: Container(
          color: Colors.black,
          child: _children[_currentIndex]),
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.lightBlue,
        unselectedItemColor: Colors.white,
        selectedLabelStyle: TextStyle(fontSize: 16),
        unselectedLabelStyle: TextStyle(fontSize: 15),

        selectedFontSize: 14,
        unselectedFontSize: 12,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books,size: 40,),
            label: 'Daily verse',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.queue_music_outlined,size: 40),
            label: 'Hyms',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings,size: 40),
            label: 'Manage',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info,size: 40),
            label: 'About',
          ),
        ],
      ),





    );
  }
}





class DailyVerseScreen extends StatefulWidget {
  @override
  State<DailyVerseScreen> createState() => _DailyVerseScreenState();
}

class _DailyVerseScreenState extends State<DailyVerseScreen> {
  String _verse = "";
  String _reference = "";
  String _imageUrl = "";

  @override
  void initState() {
    super.initState();
    fetchVerseAndImage();
  }


  Future<void> fetchVerseAndImage() async {
    try {
      final dio = Dio();

      // final verseResponse = await dio.get('https://bolls.life/get-random-verse/YLT/');
      final verseResponse = await dio.get('https://beta.ourmanna.com/api/v1/get/?format=json');
      //  final imageResponse = await dio.get('https://loremflickr.com/500/800/sunset.jpg');

      final verseData = verseResponse.data;
      print(verseResponse.data);

      print(verseData);
      setState(() {
        _verse = verseData['verse']['details']['text'];
        print(verseData);
        _reference = verseData['verse']['details']['reference'];
        // _imageUrl = imageData['urls']['regular'];
      });
    //  await showDailyVerseNotification(_verse);
    } catch (e) {
      setState(() {
        //_verse = "Error fetching verse.";
        //  _imageUrl = "Error fetching image.";
      });
    }
  }




  @override
  Widget build(BuildContext context) {
    return Center(
      child: _verse.isNotEmpty
          ? Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            'https://loremflickr.com/500/800/sunset',
            fit: BoxFit.cover,
          ),
          Container(
            color: Colors.black.withOpacity(0.5),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    _verse,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  Text(
                    _reference,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      )
          : Center(
        child: CircularProgressIndicator(
          color: Colors.lightBlue,
        ),
      ),
    );
  }
}



