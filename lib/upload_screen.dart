import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'services/firebase_service.dart';  // Firebase service for upload and fetch
import 'services/csv_export_service.dart';  // CSV export service
import 'disease_details.dart';  // Disease details widget
import 'package:path_provider/path_provider.dart'; // Path provider for CSV export

class UploadScreen extends StatefulWidget {
  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final TextEditingController _diseaseController = TextEditingController();
  final TextEditingController _symptomsController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  String? _gender;
  List<File?> _images = [];
  List<Map<String, dynamic>> _fetchedData = [];

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImages() async {
    final pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        _images.addAll(pickedFiles.map((pickedFile) => File(pickedFile.path)).toList());
      });
    }
  }

  Future<void> _captureImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _images.add(File(pickedFile.path));
      });
    }
  }

  Future<void> _uploadData() async {
    if (_images.isEmpty || _diseaseController.text.isEmpty || _symptomsController.text.isEmpty || _ageController.text.isEmpty || _gender == null) {
      print("Please fill all fields and select at least one image.");
      return;
    }

    // Call Firebase service to upload data
    await FirebaseService.uploadDiseaseData(
      diseaseName: _diseaseController.text,
      symptoms: _symptomsController.text,
      age: _ageController.text,
      gender: _gender!,
      images: _images,
    );
    _fetchData();
  }

  Future<void> _fetchData() async {
    // Call Firebase service to fetch data
    var fetchedData = await FirebaseService.fetchDiseaseData();
    setState(() {
      _fetchedData = fetchedData;
    });
  }

  Future<void> _exportDataToCSV() async {
    var status = await Permission.storage.request();
    if (!status.isGranted) {
      print("Storage permission is not granted.");
      return;
    }

    final directory = await getExternalStorageDirectory();
    if (directory != null) {
      await CSVExportService.exportToCSV(directory.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _diseaseController,
            decoration: InputDecoration(labelText: 'Disease Name'),
          ),
          TextField(
            controller: _symptomsController,
            decoration: InputDecoration(labelText: 'Symptoms'),
          ),
          TextField(
            controller: _ageController,
            decoration: InputDecoration(labelText: 'Patient Age'),
            keyboardType: TextInputType.number,
          ),
          DropdownButton<String>(
            hint: Text('Select Gender'),
            value: _gender,
            onChanged: (String? newValue) {
              setState(() {
                _gender = newValue;
              });
            },
            items: <String>['Male', 'Female', 'Other'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: _pickImages,
                child: Text('Pick Images'),
              ),
              ElevatedButton(
                onPressed: _captureImage,
                child: Text('Capture Image'),
              ),
            ],
          ),
          SizedBox(height: 16),
          _images.isNotEmpty
              ? Wrap(
                  spacing: 8,
                  children: _images.map((image) {
                    return Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: FileImage(image!),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    );
                  }).toList(),
                )
              : Container(),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _uploadData,
            child: Text('Upload Data'),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchData,
            child: Text('Fetch Data'),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _exportDataToCSV,
            child: Text('Export Data to CSV'),
          ),
          SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _fetchedData.length,
              itemBuilder: (context, index) {
                final item = _fetchedData[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(item['disease']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Symptoms: ${item['symptoms']}'),
                        Text('Age: ${item['age']}'),
                        Text('Gender: ${item['gender']}'),
                      ],
                    ),
                    leading: item['imageUrls'] != null && item['imageUrls'].isNotEmpty
                        ? Image.network(item['imageUrls'][0], width: 50, height: 50, fit: BoxFit.cover)
                        : null,
                    onTap: () => _showDiseaseDetails(item),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showDiseaseDetails(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DiseaseDetailsDialog(item: item);
      },
    );
  }
}
