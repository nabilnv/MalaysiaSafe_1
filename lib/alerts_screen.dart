import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AlertsScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> _fetchSafetyAlerts() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('disaster_alerts').get();
      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      print('Error fetching alerts: $e'); // Log the error for debugging
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Safety Alerts'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchSafetyAlerts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error fetching alerts.'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No safety alerts available.'));
          } else {
            return ListView(
              children: snapshot.data!.map((alert) {
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  padding: EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.yellow, // Set box color to yellow
                    borderRadius: BorderRadius.circular(8.0), // Rounded corners
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4.0,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alert['Name'] ?? 'Unknown Location', // Display Name
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${alert['alertMessage'] ?? 'No Alert Message'}',
                        style: TextStyle(fontSize: 14.0),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Location: (${alert['latitude']}, ${alert['longitude']})',
                        style: TextStyle(fontSize: 14.0),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Radius: ${alert['radius']} km',
                        style: TextStyle(fontSize: 14.0),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          }
        },
      ),
    );
  }
}
