// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
// import 'package:csv/csv.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: const FirebaseOptions(
//       apiKey: "AIzaSyCNYdp7MBRk_zfzJM6GiwV-0JjZ_ajgL9k",
//       appId: "1:77778519104:android:25afa5fda63ce10cdb8ba5",
//       messagingSenderId: "77778519104",
//       projectId: "datacollection-a5185",
//     ),
//   );
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: Text('Disease Data Collection'),
//         ),
//         body: UploadScreen(),
//       ),
//     );
//   }
// }

// class UploadScreen extends StatefulWidget {
//   @override
//   _UploadScreenState createState() => _UploadScreenState();
// }

// class _UploadScreenState extends State<UploadScreen> {
//   final TextEditingController _diseaseController = TextEditingController();
//   final TextEditingController _symptomsController = TextEditingController();
//   final TextEditingController _ageController = TextEditingController();
//   String? _gender;
//   List<File?> _images = [];
//   List<Map<String, dynamic>> _fetchedData = [];

//   final ImagePicker _picker = ImagePicker();
//   final CollectionReference _diseasesRef = FirebaseFirestore.instance.collection('diseases');

//   Future<void> _uploadData() async {
//     if (_images.isEmpty || _diseaseController.text.isEmpty || _symptomsController.text.isEmpty || _ageController.text.isEmpty || _gender == null) {
//       print("Please fill all fields and select at least one image.");
//       return;
//     }

//     try {
//       String folderName = _diseaseController.text.replaceAll(" ", "_");
//       List<String> imageUrls = [];

//       for (var image in _images) {
//         String fileName = DateTime.now().toString();
//         Reference ref = FirebaseStorage.instance.ref().child('diseases/$folderName/$fileName');
//         await ref.putFile(image!);
//         String imageUrl = await ref.getDownloadURL();
//         imageUrls.add(imageUrl);
//       }

//       await _diseasesRef.add({
//         'disease': _diseaseController.text,
//         'symptoms': _symptomsController.text,
//         'age': _ageController.text,
//         'gender': _gender,
//         'imageUrls': imageUrls,
//       });

//       print("Data uploaded successfully!");
//       _fetchData();
//     } catch (e) {
//       print("Failed to upload data: $e");
//     }
//   }

//   Future<void> _pickImages() async {
//     final pickedFiles = await _picker.pickMultiImage();
//     if (pickedFiles != null) {
//       setState(() {
//         _images.addAll(pickedFiles.map((pickedFile) => File(pickedFile.path)).toList());
//       });
//     }
//   }

//   Future<void> _captureImage() async {
//     final pickedFile = await _picker.pickImage(source: ImageSource.camera);
//     if (pickedFile != null) {
//       setState(() {
//         _images.add(File(pickedFile.path));
//       });
//     }
//   }

//   Future<void> _fetchData() async {
//     try {
//       final querySnapshot = await _diseasesRef.get();
//       final data = querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
//       setState(() {
//         _fetchedData = data;
//       });
//       print("Fetched data: $_fetchedData");
//     } catch (e) {
//       print("Failed to fetch data: $e");
//     }
//   }

//   Future<void> _exportDataToCSV() async {
//     var status = await Permission.storage.request();
//     if (!status.isGranted) {
//       print("Storage permission is not granted.");
//       return;
//     }

//     try {
//       final querySnapshot = await _diseasesRef.get();
//       final List<List<dynamic>> rows = [];

//       rows.add(['Disease', 'Symptoms', 'Age', 'Gender', 'Image URLs']);

//       for (var doc in querySnapshot.docs) {
//         final data = doc.data() as Map<String, dynamic>;
//         rows.add([
//           data['disease'],
//           data['symptoms'],
//           data['age'],
//           data['gender'],
//           data['imageUrls'].join(';')
//         ]);
//       }

//       String csvData = const ListToCsvConverter().convert(rows);
//       final directory = await getExternalStorageDirectory();
//       final path = "${directory!.path}/disease_data.csv";
//       final file = File(path);

//       await file.writeAsString(csvData);

//       print("CSV exported successfully: $path");
//     } catch (e) {
//       print("Failed to export CSV: $e");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         children: [
//           TextField(
//             controller: _diseaseController,
//             decoration: InputDecoration(labelText: 'Disease Name'),
//           ),
//           TextField(
//             controller: _symptomsController,
//             decoration: InputDecoration(labelText: 'Symptoms'),
//           ),
//           TextField(
//             controller: _ageController,
//             decoration: InputDecoration(labelText: 'Patient Age'),
//             keyboardType: TextInputType.number,
//           ),
//           DropdownButton<String>(
//             hint: Text('Select Gender'),
//             value: _gender,
//             onChanged: (String? newValue) {
//               setState(() {
//                 _gender = newValue;
//               });
//             },
//             items: <String>['Male', 'Female', 'Other']
//                 .map<DropdownMenuItem<String>>((String value) {
//               return DropdownMenuItem<String>(
//                 value: value,
//                 child: Text(value),
//               );
//             }).toList(),
//           ),
//           SizedBox(height: 16),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               ElevatedButton(
//                 onPressed: _pickImages,
//                 child: Text('Pick Images'),
//               ),
//               ElevatedButton(
//                 onPressed: _captureImage,
//                 child: Text('Capture Image'),
//               ),
//             ],
//           ),
//           SizedBox(height: 16),
//           _images.isNotEmpty
//               ? Wrap(
//                   spacing: 8,
//                   children: _images.map((image) {
//                     return Container(
//                       width: 100,
//                       height: 100,
//                       decoration: BoxDecoration(
//                         image: DecorationImage(
//                           image: FileImage(image!),
//                           fit: BoxFit.cover,
//                         ),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     );
//                   }).toList(),
//                 )
//               : Container(),
//           SizedBox(height: 16),
//           ElevatedButton(
//             onPressed: _uploadData,
//             child: Text('Upload Data'),
//           ),
//           SizedBox(height: 16),
//           ElevatedButton(
//             onPressed: _fetchData,
//             child: Text('Fetch Data'),
//           ),
//           SizedBox(height: 16),
//           ElevatedButton(
//             onPressed: _exportDataToCSV,
//             child: Text('Export Data to CSV'),
//           ),
//           SizedBox(height: 16),
//           Expanded(
//             child: ListView.builder(
//               itemCount: _fetchedData.length,
//               itemBuilder: (context, index) {
//                 final item = _fetchedData[index];
//                 return Card(
//                   margin: EdgeInsets.symmetric(vertical: 8),
//                   child: ListTile(
//                     title: Text(item['disease']),
//                     subtitle: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text('Symptoms: ${item['symptoms']}'),
//                         Text('Age: ${item['age']}'),
//                         Text('Gender: ${item['gender']}'),
//                       ],
//                     ),
//                     leading: item['imageUrls'] != null && item['imageUrls'].isNotEmpty
//                         ? Image.network(item['imageUrls'][0], width: 50, height: 50, fit: BoxFit.cover)
//                         : null,
//                     onTap: () => _showDiseaseDetails(item),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showDiseaseDetails(Map<String, dynamic> item) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text(item['disease']),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text('Symptoms: ${item['symptoms']}'),
//               Text('Age: ${item['age']}'),
//               Text('Gender: ${item['gender']}'),
//               SizedBox(height: 8),
//               if (item['imageUrls'] != null)
//                 Column(
//                   children: item['imageUrls'].map<Widget>((url) {
//                     return Image.network(url);
//                   }).toList(),
//                 ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               child: Text('Close'),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'upload_screen.dart';  // Import the UploadScreen widget

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCNYdp7MBRk_zfzJM6GiwV-0JjZ_ajgL9k",
      appId: "1:77778519104:android:25afa5fda63ce10cdb8ba5",
      messagingSenderId: "77778519104",
      projectId: "datacollection-a5185",
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Disease Data Collection'),
        ),
        body: UploadScreen(),  // Display the UploadScreen
      ),
    );
  }
}

