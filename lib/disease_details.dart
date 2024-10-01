import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class DiseaseDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> item;

  DiseaseDetailsDialog({required this.item});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(item['disease']),
      content: SingleChildScrollView( // Allows scrolling
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Symptoms: ${item['symptoms']}'),
            Text('Age: ${item['age']}'),
            Text('Gender: ${item['gender']}'),
            SizedBox(height: 8),
            if (item['imageUrls'] != null && item['imageUrls'].isNotEmpty)
              Container( // Constrain the height of the carousel
                height: 200,
                child: CarouselSlider(
                  options: CarouselOptions(
                    height: 200,
                    enableInfiniteScroll: true,
                    viewportFraction: 0.8,
                  ),
                  items: item['imageUrls'].map<Widget>((url) {
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          image: NetworkImage(url),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: Text('Close'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
