import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'ManageDonationsScreen.dart';
import 'ManageEventsScreen.dart';
import 'ManageUsersScreen.dart';


class ManageScreen extends StatefulWidget {
  @override
  _ManageScreenState createState() => _ManageScreenState();
}

class _ManageScreenState extends State<ManageScreen> {
  bool isAdmin = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkUserRole();
  }

  Future<void> _checkUserRole() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      setState(() {
        isAdmin = userDoc['userType'] == 'Admin';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white12,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Management Center',style: TextStyle(color: Colors.white),),
        leading: IconButton(
          icon: Icon(Icons.arrow_back,color: Colors.white,),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
            child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
            children: [
              if (isAdmin)
                _buildCard(
                  icon: Icons.person,
                  text: 'Manage Users',
                  color: Colors.greenAccent,
                  onTap: () {
                    Get.to(ManageUsersScreen());
                  },
                ),
              if (isAdmin) SizedBox(height: 20),
              _buildCard(
                icon: Icons.event,
                text: 'Manage Events',
                color: Colors.lightBlueAccent,
                onTap: () {
                  Get.to(ManageEventsScreen());
                },
              ),
              SizedBox(height: 20),
              _buildCard(
                icon: Icons.monetization_on,
                text: 'Manage Donations',
                color: Colors.amberAccent,
                onTap: () {
                  Get.to(ManageDonationsScreen());
                },
              ),
            ],
        ),
      ),
          ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      color: color,
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(20),
          height: 150,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50, color: Colors.white),
              SizedBox(height: 10),
              Text(
                text,
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
