import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pr3/pages/add_group.dart';
import 'package:pr3/pages/cart.dart';
import 'package:pr3/pages/description.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pr3/pages/favourite.dart';
import 'package:pr3/pages/profile.dart';


class Homepage extends StatefulWidget {
  const Homepage({super.key});
  @override
  HomepageState createState() => HomepageState();
}

class HomepageState extends State<Homepage> {
  List groups = [];
  List notes = []; 
  int _selectedIndex = 0;
  Color iconColor = Colors.white;
  static const List<Widget> _widgetOptions = <Widget>[
    Homepage(),
    Profile(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  //Функция чтения json файла
  Future<void> readJson() async {
    final file = File('lib/components/product.json');
    String contents = await file.readAsString();
    Map<String, dynamic> jsonFileContent = await jsonDecode(contents);
    setState(() {
      groups = jsonFileContent["groups"];
    });
  }

  //Функция добавления новой группы в json файл
  Future<void> addNewData(Map<String, dynamic> result) async {
    final file = File('lib/components/product.json');
    String contents = await file.readAsString();
    Map<String, dynamic> jsonFileContent = await jsonDecode(contents);
    groups.add(result); 
    jsonFileContent['groups'] = groups;
    await file.writeAsString(jsonEncode(jsonFileContent));
    setState(() {
      
    });
  }

  //Функция добавления в любимые
  Future<void> addFavourite(Map<String, dynamic> group) async {
    List<dynamic> favourite = [];
    final file = File('lib/components/favourite.json');
    String contents = await file.readAsString();
    Map<String, dynamic> jsonFileContent = await jsonDecode(contents);
    favourite = jsonFileContent['favourites'];
    favourite.add(group);
    jsonFileContent['favourites'] = favourite;
    await file.writeAsString(jsonEncode(jsonFileContent));
    setState(() {
      
    });
  }

  //Функция добавления в корзину
  Future<void> _addCart(int index) async {
    final file = File('lib/components/product.json');
    String contents = await file.readAsString();
    Map<String, dynamic> jsonFileContent = await jsonDecode(contents);
    int c_index = (jsonFileContent['groups'] as List).indexWhere((item) => item["title"] == groups[index]["title"]);
    int quantity = groups[index]['quantity'];
    if (quantity == 0) {
      jsonFileContent['groups'][c_index]["quantity"] = 1;
    }
    await file.writeAsString(jsonEncode(jsonFileContent));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: quantity == 0 ? Text(groups[index]["title"]+" добавлен в корзину")
        : Text(groups[index]["title"]+" уже в корзине")
      ),
    );
    setState(() {
      readJson();
    });
  }

  //Функция удаления группы из json файла
  Future<void> removeGroup(int index) async {
    final file = File('lib/components/product.json');
    String contents = await file.readAsString();
    Map<String, dynamic> jsonFileContent = await jsonDecode(contents);
    groups.removeAt(index);
    jsonFileContent['groups'] = groups;
    setState(() async {
      await file.writeAsString(jsonEncode(jsonFileContent));
    });
  }

  //Функция смены цвета иконки избранного
  void _checkStatus(int index) async {
    final file = File('lib/components/product.json');
    String status = "";
    String contents = await file.readAsString();
    Map<String, dynamic> jsonFileContent = await jsonDecode(contents);
    if (groups[index]["favourite"] == "false") {
      status = "true";
    } else {
      status = "false";
    }
    groups[index]["favourite"] = status;
    jsonFileContent['groups'] = groups;
    await file.writeAsString(jsonEncode(jsonFileContent));
    setState(() {
      
    });
  }


  //Функия перехода на страницу добавления группы
  void _navigateToAddGroupScreen(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddGroup()),
    );

    if (result != null && result.isNotEmpty) {
      addNewData(result);
    }
  }

  @override
  void initState() {
    super.initState();
    readJson();
  }


  @override
  Widget build(BuildContext context) {
    
    //Виджет отображения групп на главной странице
    Widget _buildGroupList() {
      return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              title: const Center(child: Text("Группы", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 35))),
              actions: <Widget>[
                IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Cart(readJsonH: readJson,)),
                    );
                    setState(() {
                      readJson();
                    });
                  }, 
                  icon: const Icon(Icons.shopping_cart)
                ),
              ],
            ),
            body: groups.isEmpty
              ? const Center(child: Text("Нет групп, добавьте новую."))
              : ListView.builder(
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
                            child: FadeInImage.assetNetwork(placeholder: 'lib/components/images/placeholder.png', image: groups[index]["image_url"], imageErrorBuilder: (context, error, stackTrace) {return Image.asset('lib/components/images/placeholder.png');}, width: double.infinity, fit: BoxFit.fitHeight,)
                          ),
                          const SizedBox(height: 10,),
                          Text(groups[index]["title"], style: const TextStyle(fontSize: 25, color: Colors.white),),
                          const SizedBox(height: 10,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: Icon(Icons.favorite, color: groups[index]["favourite"] == "true" ? Colors.red : Colors.white), 
                                onPressed: () {
                                  _checkStatus(index);
                                },
                              ),
                              IconButton(
                                onPressed: () {
                                   _addCart(index);
                                }, 
                                icon: const Icon(Icons.add_shopping_cart, color: Colors.white)
                              ),
                              IconButton(onPressed: () {
                                showDialog(
                                  context: context, 
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text("Внимание!"),
                                      content: const Text("Вы уверены что хотите удалить данную группу?"),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            removeGroup(index);
                                            Navigator.pop(context);
                                          }, 
                                          child: const Text("Да", style: TextStyle(color: Colors.black),)),
                                        TextButton(onPressed: Navigator.of(context).pop, child: const Text("Нет", style: TextStyle(color: Colors.black),))
                                      ]
                                    );
                                  }
                                );
                              },
                              icon: const Icon(Icons.delete, color: Colors.white,),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10,),
                          Text(groups[index]["price"].toString()+"₽", style: const TextStyle(color: Colors.white),),
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
            floatingActionButton: FloatingActionButton(
              onPressed: () => _navigateToAddGroupScreen(context),
              backgroundColor: Colors.white,
              child: const Icon(Icons.add, color: Colors.black),
            ),
          );
    }
    
    Widget _getCurrentPage() {
      switch (_selectedIndex) {
        case 0:
          return _buildGroupList();
        case 1:
          return Favourite(readJsonH: readJson,);
        case 2:
          return const Profile();
        default: 
          return _buildGroupList();
      }
    }
    
    return Scaffold(
      body: _getCurrentPage(),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Главная",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: "Любимые",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: "Профиль",
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}