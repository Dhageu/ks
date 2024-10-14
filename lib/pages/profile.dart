import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pr3/pages/description.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  List<dynamic> favourite = [];

  Future<void> readJson() async {
    String response = await rootBundle.loadString('lib/components/favourite.json');
    Map<String, dynamic> data = await jsonDecode(response);
    setState(() {
      favourite = data["favourites"];
    });
  }

  @override
  void initState() {
    super.initState();
    readJson();
    debugPrint(favourite.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text("Профиль", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 35))),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(border: Border.all()),
                child: Image.asset('lib/components/images/profile.png', width: 200, height: 200,),
              ),
              const SizedBox(height: 20,),
              const DecoratedBox(
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide()),
                ),
                child: Padding(
                  padding: EdgeInsets.all(0.0),
                  child: Text("Имя пользователя"),
                )
              ),
              const SizedBox(height: 20,),
              const DecoratedBox(
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide()),
                ),
                child: Padding(
                  padding: EdgeInsets.all(0.0),
                  child: Text("Дата регистрации"),
                )
              ),
            ],
          ),
        ),
      )
      /*favourite.isEmpty ? const Text("Любимых групп нет!") :
      ListView.builder(
        itemCount: favourite.length,
        itemBuilder: (context, index) {
           return Column(
             children: [
               const Text("Любимые группы", style: TextStyle(fontSize: 20)),
               Padding(
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
                          child: FadeInImage.assetNetwork(placeholder: 'lib/components/images/placeholder.png', image: favourite[index]["image_url"], imageErrorBuilder: (context, error, stackTrace) {return Image.asset('lib/components/images/placeholder.png');}, width: double.infinity, fit: BoxFit.fitHeight,)
                        ),
                        const SizedBox(height: 10,),
                        Text(favourite[index]["title"], style: const TextStyle(fontSize: 25, color: Colors.white),),
                        const SizedBox(height: 10,),
                      ],
                    ),
                  ),
                  /*onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Description(group: favourite[index]),),
                    );
                  },*/
                ),
               ),
             ],
           );
        }
      )*/
    );
  }
}