import 'package:flutter/material.dart';
import 'package:pr3/models/api_service.dart';
import 'dart:developer' as developer;

import 'package:pr3/models/group_model.dart';
import 'package:pr3/pages/edit.dart';

class Description extends StatefulWidget {
  const Description({super.key, required this.index, required this.readJson});
  final int index;
  final VoidCallback readJson;
  @override
  DescriptionState createState() => DescriptionState(index: index, readJson: readJson);
}

class DescriptionState extends State<Description> {
  DescriptionState({required this.index, required this.readJson});
  final int index;
  final VoidCallback readJson;
  String description = '';
  String favoutie = '';
  int quantity = 0;
  String image_url = '';
  int price = 0;
  late Future<Group> group;

  void editGroup(Map<String, dynamic> result) async {
    await ApiService().updateGroup(index, result);
    setState(() {
      readGroup();
    });
  } 

  void readGroup() async {
    group = ApiService().getGroupByID(index);
  }

  void _navigateToEditGroupScreen(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditGroup(index: index, readGroup: readGroup)),
    );

    if (result != null && result.isNotEmpty) {
      editGroup(result);
      readGroup();
    }
  }

  @override
  void initState() {
    super.initState();
    readGroup();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder(
        future: group,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final group = snapshot.data!;
          return Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              iconTheme: const IconThemeData(color: Colors.white),
              backgroundColor: Colors.black,
              title: Text(group.title, style: const TextStyle(color: Colors.white)),
              actions: <Widget>[
                IconButton(
                  onPressed: () {
                    _navigateToEditGroupScreen(context);
                    setState(() {
                      
                    });
                  }, 
                  icon: const Icon(Icons.edit)
                ),
              ],
              leading: IconButton(
                onPressed: () {
                  readJson();
                  Navigator.pop(context);
                }, 
                icon: const Icon(Icons.arrow_back),
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  FadeInImage.assetNetwork(placeholder: 'lib/components/images/placeholder.png', image: group.image_url.toString(), imageErrorBuilder: (context, error, stackTrace) {return Image.asset('lib/components/images/placeholder.png');}, width: double.infinity, fit: BoxFit.fitHeight,),
                  const SizedBox(height: 30,),
                  Text(group.description, style: const TextStyle(color: Colors.white)),
                ],
              ),
            )
          );
        }
      )
    );
  }
}