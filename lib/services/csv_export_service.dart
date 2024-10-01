import 'dart:io';
import 'package:csv/csv.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CSVExportService {
  static Future<void> exportToCSV(String path) async {
    final CollectionReference _diseasesRef = FirebaseFirestore.instance.collection('diseases');
    final querySnapshot = await _diseasesRef.get();
    final List<List<dynamic>> rows = [];

    rows.add(['Disease', 'Symptoms', 'Age', 'Gender', 'Image URLs']);

    for (var doc in querySnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      rows.add([
        data['disease'],
        data['symptoms'],
        data['age'],
        data['gender'],
        data['imageUrls'].join(';')
      ]);
    }

    String csvData = const ListToCsvConverter().convert(rows);
    final file = File("$path/disease_data.csv");
    await file.writeAsString(csvData);

    print("CSV exported successfully: $path");
  }
}
