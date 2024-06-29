import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ManageEventsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: IconButton(onPressed: () {  Get.back();}, icon: Icon(Icons.arrow_back_rounded,color: Colors.white,),),
        backgroundColor: Colors.black,
        title: Text('Manage Events',style: TextStyle(color: Colors.white),),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('events').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No events yet.'));
          }

          final events = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Event(
              id: doc.id,
              eventName: data['eventName'],
              eventDate: (data['eventDate'] as Timestamp).toDate(),

            );
          }).toList();

          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return _buildEventItem(context, event);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.greenAccent,
        onPressed: () {
          _showAddEventDialog(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildEventItem(BuildContext context, Event event) {


    return Card(
      color: Colors.white,
      child: ListTile(
        title: Text(event.eventName, style: TextStyle(color: Colors.lightBlue,fontSize: 20)),
        subtitle: Text('Date: ${DateFormat('yyyy-MM-dd').format(event.eventDate)}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [

            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                _showEditEventDialog(context, event);
              },
            ),
            IconButton(
              icon: Icon(Icons.delete,color: Colors.red,),
              onPressed: () {
                _deleteEvent(event.id);
              },
            ),
          ],
        ),
      ),
    );
  }
  void _deleteEvent(String eventId) {
    FirebaseFirestore.instance.collection('events').doc(eventId).delete().then((value) {
      // Event deleted successfully
      print('Event deleted successfully');
    }).catchError((error) {
      // Error deleting event
      print('Error deleting event: $error');
      Get.snackbar('Error', 'Failed to delete event. Please try again later.');
    });
  }


  void _showAddEventDialog(BuildContext context) {
    TextEditingController eventNameController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Add Event'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: eventNameController,
                    decoration: InputDecoration(labelText: 'Event Name'),
                  ),
                  SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null && pickedDate != selectedDate) {
                        setState(() {
                          selectedDate = pickedDate;
                        });
                      }
                    },
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today),
                        SizedBox(width: 8),
                        Text(
                          'Event Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}',
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                      );
                      if (pickedTime != null && pickedTime != selectedTime) {
                        setState(() {
                          selectedTime = pickedTime;
                        });
                      }
                    },
                    child: Row(
                      children: [
                        Icon(Icons.access_time),
                        SizedBox(width: 8),
                        Text(
                          'Event Time: ${selectedTime.format(context)}',
                        ),
                      ],
                    ),
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
                    if (eventNameController.text.isNotEmpty) {
                      _addEvent(eventNameController.text, selectedDate, selectedTime);
                      Navigator.of(context).pop();
                    } else {
                      // Show error message
                      Get.snackbar('Error', 'Please enter event name');
                    }
                  },
                  child: Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _addEvent(String eventName, DateTime eventDate, TimeOfDay eventTime) {
    final DateTime dateTime = DateTime(eventDate.year, eventDate.month, eventDate.day, eventTime.hour, eventTime.minute);
    FirebaseFirestore.instance.collection('events').add({
      'eventName': eventName,
      'eventDate': dateTime,
      // Add the creator's name here
    }).then((value) {
      // Event added successfully
      print('Event added successfully');
    }).catchError((error) {
      // Error adding event
      print('Error adding event: $error');
      Get.snackbar('Error', 'Failed to add event. Please try again later.');
    });
  }

  void _showEditEventDialog(BuildContext context, Event event) {
    // Implement edit event dialog
  }
}

class Event {
  final String id;
  final String eventName;
  final DateTime eventDate;


  Event({
    required this.id,
    required this.eventName,
    required this.eventDate,

  });
}
