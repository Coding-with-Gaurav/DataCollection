import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  static final CollectionReference _diseasesRef = FirebaseFirestore.instance.collection('diseases');

  static Future<void> uploadDiseaseData({
    required String diseaseName,
    required String symptoms,
    required String age,
    required String gender,
    required List<File?> images,
  }) async {
    String folderName = diseaseName.replaceAll(" ", "_");
    List<String> imageUrls = [];

    for (var image in images) {
      String fileName = DateTime.now().toString();
      Reference ref = FirebaseStorage.instance.ref().child('diseases/$folderName/$fileName');
      await ref.putFile(image!);
      String imageUrl = await ref.getDownloadURL();
      imageUrls.add(imageUrl);
    }

    await _diseasesRef.add({
      'disease': diseaseName,
      'symptoms': symptoms,
      'age': age,
      'gender': gender,
      'imageUrls': imageUrls,
    });
  }

  static Future<List<Map<String, dynamic>>> fetchDiseaseData() async {
    final querySnapshot = await _diseasesRef.get();
    return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }
}
