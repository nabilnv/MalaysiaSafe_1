import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CommunityReportScreen extends StatefulWidget {
  @override
  _CommunityReportScreenState createState() => _CommunityReportScreenState();
}

class _CommunityReportScreenState extends State<CommunityReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _typeController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  XFile? _image; // Variable to store the selected image

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = pickedFile;
        _imageController.text = _image!.path;
      });
    }
  }

  Future<void> _chooseImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = pickedFile;
        _imageController.text = _image!.path;
      });
    }
  }

  void _submitReport() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        await _firestore.collection('community_reports').add({
          'type': _typeController.text,
          'location': _locationController.text,
          'description': _descriptionController.text,
          'image': _imageController.text,
          'createdAt': FieldValue.serverTimestamp(),
          'user': 'User Name',
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Report submitted successfully!'),
        ));

        _typeController.clear();
        _locationController.clear();
        _descriptionController.clear();
        _imageController.clear();
        setState(() {
          _image = null;
        });
      } catch (e) {
        print('Error submitting report: $e');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error submitting report.'),
        ));
      }
    }
  }

  Future<List<Map<String, dynamic>>> _fetchReports() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('community_reports').get();
      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print('Error fetching reports: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Community Reports'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _typeController,
                    decoration: InputDecoration(labelText: 'Type of Issue'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the type of issue';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _locationController,
                    decoration: InputDecoration(labelText: 'Location'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the location';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(labelText: 'Description'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                  ),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: _pickImage,
                        child: Text('Capture Image'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow, // Set background color to yellow
                        ),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _chooseImage,
                        child: Text('Select from Gallery'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow, // Set background color to yellow
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _submitReport,
                    child: Text('Submit Report'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow, // Set background color to yellow
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchReports(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error fetching reports.'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No reports available.'));
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final report = snapshot.data![index];
                      return ListTile(
                        title: Text(report['type'] ?? 'No Type'),
                        subtitle: Text(report['description'] ?? 'No Description'),
                        trailing: Text(report['location'] ?? 'No Location'),
                        onTap: () {
                          // Handle tap if you want to show more details
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
