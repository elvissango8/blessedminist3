import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'CreateUserScreen.dart';
import 'EditUserScreen.dart';

class ManageUsersScreen extends StatefulWidget {
  @override
  _ManageUsersScreenState createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _deleteUser(String userId) async {
    await _firestore.collection('users').doc(userId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Manage Users',style: TextStyle(color: Colors.white),),
        leading: IconButton(
          icon: Icon(Icons.arrow_back,color: Colors.white,),
          onPressed: () {
            Get.back();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add,color: Colors.greenAccent,),
            onPressed: () {
              Get.to(CreateUserScreen());
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!.docs;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                tileColor: Colors.white,
                title: Text('${user['firstName']} ${user['lastName']}',style: TextStyle(color: Colors.green,fontSize: 18)),
                subtitle: Text(user['email'],style: TextStyle(color: Colors.black)),
                onTap: () {
                  Get.to(EditUserScreen(userId: user.id));
                },
                trailing: IconButton(
                  icon: Icon(Icons.delete,color:Colors.lightBlue),
                  onPressed: () async {

                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
