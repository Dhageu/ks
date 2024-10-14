import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pr3/pages/description.dart';
import 'package:pr3/pages/homepage.dart';

class Favourite extends StatefulWidget {
  final VoidCallback readJsonH;
  const Favourite({super.key, required this.readJsonH});

  @override
  State<Favourite> createState() => _FavouriteState(readJsonH: readJsonH);
}

class _FavouriteState extends State<Favourite> {
  final VoidCallback readJsonH;
  _FavouriteState({required this.readJsonH});
  List favourites = [];
  List tt = [];

  Future<void> readJson () async {
    final file = File('lib/components/product.json');
    String contents = await file.readAsString();
    Map<String, dynamic> jsonFileContent = await jsonDecode(contents);
    setState(() {
      favourites = (jsonFileContent['groups'] as List).where((item) => item['favourite'] == "true").toList();
    });

  }

  void _checkStatus(int index) async {
    final file = File('lib/components/product.json');
    String status = "";
    String contents = await file.readAsString();
    Map<String, dynamic> jsonFileContent = await jsonDecode(contents);
    tt = jsonFileContent['groups'];
    int f_index = tt.indexWhere((item) => item['title'] == favourites[index]['title']);
    status = "false";
    jsonFileContent['groups'][f_index]["favourite"] = status;
    await file.writeAsString(jsonEncode(jsonFileContent));
    setState(() {
      readJson();
      readJsonH();  
    });
  }

  @override
  void initState () {
    super.initState();
    readJson();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text("Любимые", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 35))),
      ),
      body: favourites.isEmpty ? const Center(child: Text("Нет любимых групп"))
      : ListView.builder(
          itemCount: favourites.length,
          itemBuilder:(context, index) {
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
                            child: FadeInImage.assetNetwork(placeholder: 'lib/components/images/placeholder.png', image: favourites[index]["image_url"], imageErrorBuilder: (context, error, stackTrace) {return Image.asset('lib/components/images/placeholder.png');}, width: double.infinity, fit: BoxFit.fitHeight,)
                          ),
                          const SizedBox(height: 10,),
                          Text(favourites[index]["title"], style: const TextStyle(fontSize: 25, color: Colors.white),),
                          const SizedBox(height: 10,),
                          IconButton(
                            icon: Icon(Icons.favorite, color: favourites[index]["favourite"] == "true" ? Colors.red : Colors.white), 
                            onPressed: () {
                              _checkStatus(index);
                            },
                          ),
                          const SizedBox(height: 10,),
                        ],
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Description(group: favourites[index]),),
                      );
                    },
                  ),
                );
          },
      ),
    );
  }
}