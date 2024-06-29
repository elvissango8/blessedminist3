import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../Models/Donation.dart';

class ManageDonationsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: IconButton(onPressed: (){
          Get.back();
        },icon: Icon(Icons.arrow_back_rounded,color: Colors.white,),),
        backgroundColor: Colors.black,
        title: Text('Manage Donations',style: TextStyle(color: Colors.white),),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('donations').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No donations yet.'));
          }

          final donations = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Donation(
              id: doc.id,
              donatedBy: data['donatedBy'],
              amount: data['amount'].toDouble(),
              date: (data['date'] as Timestamp).toDate(),
            );
          }).toList();

          double totalAmount = donations.fold(0, (prev, donation) => prev + donation.amount);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: donations.length,
                  itemBuilder: (context, index) {
                    final donation = donations[index];
                    return _buildListItem(context, donation);
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left:16.0,right:16,bottom: 25),
                    child: Text(
                      'Total: \$${totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 22,color: Colors.blue, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              if (_isAdmin()) _buildAdminButtons(context),
            ],
          );
        },
      ),
      floatingActionButton: _isAdmin()
          ? FloatingActionButton(
        backgroundColor: Colors.greenAccent,
        onPressed: () {
          _showAddDonationDialog(context);
        },
        child: Icon(Icons.add),
      )
          : null,
    );
  }

  Widget _buildListItem(BuildContext context, Donation donation) {
    return Card(
      elevation: 8,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: ListTile(
        title: Text(
          '${donation.donatedBy} - \$${donation.amount.toStringAsFixed(2)}',
          style: TextStyle(color: Colors.lightBlue,fontSize: 18),
        ),
        subtitle: Text(
          'Date Donated: ${DateFormat('EEE,dd/MM/yyy').format(donation.date)}',
          style: TextStyle(color: Colors.black),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit,color: Colors.black,),
              onPressed: () {
                _showEditDonationDialog(context, donation);
              },
            ),
            IconButton(
              icon: Icon(Icons.delete,color: Colors.red,),
              onPressed: () {
                _showDeleteDonationDialog(context, donation);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [

      ],
    );
  }

  bool _isAdmin() {
    // Implement logic to check if the user is an admin
    return true; // For demonstration purpose, assuming user is admin
  }

  void _showAddDonationDialog(BuildContext context) {
    TextEditingController donatedByController = TextEditingController();
    TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Donation'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: donatedByController,
                decoration: InputDecoration(labelText: 'Donated By'),
              ),
              TextField(
                controller: amountController,
                decoration: InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                double amount = double.tryParse(amountController.text) ?? 0.0;
                if (donatedByController.text.isNotEmpty && amount > 0) {
                  _addDonation(donatedByController.text, amount);
                  Navigator.of(context).pop();
                } else {
                  // Show error message
                  Get.snackbar('Error', 'Please enter valid details');
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _addDonation(String donatedBy, double amount) {
    FirebaseFirestore.instance.collection('donations').add({
      'donatedBy': donatedBy,
      'amount': amount,
      'date': Timestamp.now(),
    }).then((value) {
      // Donation added successfully
      print('Donation added successfully');
    }).catchError((error) {
      // Error adding donation
      print('Error adding donation: $error');
      Get.snackbar('Error', 'Failed to add donation. Please try again later.');
    });
  }

  void _showEditDonationDialog(BuildContext context, Donation donation) {
    TextEditingController donatedByController = TextEditingController(text: donation.donatedBy);
    TextEditingController amountController = TextEditingController(text: donation.amount.toString());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Donation'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: donatedByController,
                decoration: InputDecoration(labelText: 'Donated By'),
              ),
              TextField(
                controller: amountController,
                decoration: InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                double amount = double.tryParse(amountController.text) ?? 0.0;
                if (donatedByController.text.isNotEmpty && amount > 0) {
                  _updateDonation(donation.id, donatedByController.text, amount);
                  Navigator.of(context).pop();
                } else {
                  // Show error message
                  Get.snackbar('Error', 'Please enter valid details');
                }
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _updateDonation(String donationId, String donatedBy, double amount) {
    FirebaseFirestore.instance.collection('donations').doc(donationId).update({
      'donatedBy': donatedBy,
      'amount': amount,
    }).then((value) {
      // Donation updated successfully
      print('Donation updated successfully');
    });
  }

  void _showDeleteDonationDialog(BuildContext context, Donation donation) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Donation'),
          content: Text('Are you sure you want to delete this donation?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _deleteDonation(donation.id);
                Navigator.of(context).pop();
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _deleteDonation(String donationId) {
    FirebaseFirestore.instance.collection('donations').doc(donationId).delete().then((value) {
      // Donation deleted successfully
      print('Donation deleted successfully');
    }).catchError((error) {
      // Error deleting donation
      print('Error deleting donation: $error');
      Get.snackbar('Error', 'Failed to delete donation. Please try again later.');
    });
  }




}