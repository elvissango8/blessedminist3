import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mev/Models/Hym.dart';
import 'package:get/get.dart';


class HymsScreen extends StatefulWidget {
  @override
  _HymsScreenState createState() => _HymsScreenState();
}






class _HymsScreenState extends State<HymsScreen> {
  List<Hym> hymns = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _loadHymns();
  }

  Future<void> _loadHymns() async {
    try {
      String jsonString = await rootBundle.loadString('assets/hyms.json');
      List<dynamic> jsonList = json.decode(jsonString);
      print(jsonString);
      setState(() {
        hymns = jsonList.map((json) => Hym.fromJson(json)).toList();
        isLoading = false;
        print(hymns);
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Hymns',style:TextStyle(fontFamily: 'Poppins',color: Colors.white,
        )),
      ),
      body: isLoading
          ? Center(
        child: CircularProgressIndicator(),
      )

          : ListView.builder(
        itemCount: hymns.length,
        itemBuilder: (context, index) {
          return ListTile(

            leading:Text(hymns[index].id,style: TextStyle(fontSize: 17,color:Colors.white),),
            title: Text(hymns[index].title,style:TextStyle(fontFamily: 'Poppins',color: Colors.white)),
            trailing: Icon(Icons.music_note_sharp,color: Colors.lightBlue,),
            onTap: () {
              Get.to(() => HymnDetailScreen(
                hymns: hymns,
                initialIndex: index,
              ));
            },
          );
        },
      ),
    );
  }
}

class HymnDetailScreen extends StatefulWidget {
  final List<Hym> hymns;
  final int initialIndex;

  HymnDetailScreen({required this.hymns, required this.initialIndex});

  @override
  _HymnDetailScreenState createState() => _HymnDetailScreenState();
}

class _HymnDetailScreenState extends State<HymnDetailScreen> {
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
  }

  void goToPreviousHymn() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
      });
    }
  }

  void goToNextHymn() {
    if (currentIndex < widget.hymns.length - 1) {
      setState(() {
        currentIndex++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hymn = widget.hymns[currentIndex];
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: IconButton(onPressed: (){
          Get.back();
        },
        icon: Icon(Icons.arrow_back,color:Colors.white),),
        backgroundColor: Colors.black,
        title: Text(hymn.title,style:TextStyle(color:Colors.white,fontSize: 18)),
      ),
      body: Container(
        padding:EdgeInsets.symmetric(horizontal: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  hymn.lyrics,
                  style: TextStyle(fontSize: 16.0,color:Colors.white),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  width: 100,
                  decoration: BoxDecoration(
                      color: Colors.lightBlue,
                      borderRadius: BorderRadius.circular(12)
                  ),
                  child: IconButton(

                    icon: Icon(Icons.arrow_back,color: Colors.white,),
                    onPressed: goToPreviousHymn,
                  ),
                ),

                Container(
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.lightBlue,
                    borderRadius: BorderRadius.circular(12)
                  ),
                  child: IconButton(
                    icon: Icon(Icons.arrow_forward,color:Colors.white),
                    onPressed: goToNextHymn,
                  ) ,
                )

              ],
            ),
          ],
        ),
      ),
    );
  }
}