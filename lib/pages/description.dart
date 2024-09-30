import 'package:flutter/material.dart';
import 'dart:developer' as developer;

class Description extends StatelessWidget {
  const Description({super.key, required this.group});
  final Map<String, dynamic> group;
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
        title: Text(group["title"], style: const TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            FadeInImage.assetNetwork(placeholder: 'lib/components/images/placeholder.png', image: group["image_url"].toString(), imageErrorBuilder: (context, error, stackTrace) {return Image.asset('lib/components/images/placeholder.png');}, width: double.infinity, fit: BoxFit.fitHeight,),
            const SizedBox(height: 30,),
            Text(group["description"], style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}