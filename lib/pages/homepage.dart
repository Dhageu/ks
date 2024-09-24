import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pr3/pages/description.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});
  @override
  HomepageState createState() => HomepageState();
}

class HomepageState extends State<Homepage> {

  List groups = [];

  Future<void> readJson() async {
    String response = await rootBundle.loadString('lib/components/product.json');
    final Map<String, dynamic> data = await json.decode(response);
    setState(() {
      groups = data["groups"];
    });
  }

  @override
  void initState() {
    super.initState();
    readJson();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text("Группы", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 35))
        ),
      ),
      body: ListView.builder(
        itemCount: groups.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              minVerticalPadding: 0,
              contentPadding: EdgeInsets.zero,
              tileColor: Colors.black,
              title: Center(
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                      child: Image.asset(groups[index]["image_url"], width: double.infinity, fit: BoxFit.fitHeight,)
                    ),
                    const SizedBox(height: 10,),
                    Text(groups[index]["title"], style: const TextStyle(fontSize: 25, color: Colors.white),),
                    const SizedBox(height: 10,),
                    //const Text("Нажмите для просмотра полного описания", style: TextStyle(decoration: TextDecoration.underline, color: Colors.yellow),),
                    const SizedBox(height: 10,),
                  ],
                ),
              ),  
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Description(group: groups[index]),),
                );
              },
            ),
          );
        },
      ),
    );
  }
}