import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class EditUserScreen extends StatefulWidget {
  final String userId;

  EditUserScreen({required this.userId});

  @override
  _EditUserScreenState createState() => _EditUserScreenState();
}



class _EditUserScreenState extends State<EditUserScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  String _selectedBranch = 'Bulawayo';
  String _selectedUserType = 'User';


  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    _fetchUserData();
  }



  Future<void> _fetchUserData() async {
    DocumentSnapshot userDoc = await _firestore.collection('users').doc(widget.userId).get();
    setState(() {
      _firstNameController = TextEditingController(text: userDoc['firstName']);
      _lastNameController = TextEditingController(text: userDoc['lastName']);
      _emailController = TextEditingController(text: userDoc['email']);
      _selectedBranch = userDoc['branch'];
      _selectedUserType = userDoc['userType'];
    });
  }

  Future<void> _updateUser() async {
    await _firestore.collection('users').doc(widget.userId).update({
      'firstName': _firstNameController.text,
      'lastName': _lastNameController.text,
      'branch': _selectedBranch,
      'userType': _selectedUserType,
      'email': _emailController.text,
    });
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit User'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _firstNameController,
                decoration: InputDecoration(labelText: 'First Name'),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _lastNameController,
                decoration: InputDecoration(labelText: 'Last Name'),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedBranch,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedBranch = newValue!;
                  });
                },
                items: <String>['Bulawayo', 'Harare']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: InputDecoration(labelText: 'Branch'),
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedUserType,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedUserType = newValue!;
                  });
                },
                items: <String>['User', 'Admin']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: InputDecoration(labelText: 'User Type'),
              ),
              SizedBox(height: 20),
              SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(

                    backgroundColor: Colors.lightBlue
                  ),
                  onPressed: _updateUser,
                  child: Text('Update User',style: TextStyle(color: Colors.white,fontSize:20,fontWeight: FontWeight.bold),),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
