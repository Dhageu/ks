import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pr3/pages/add_group.dart';
import 'package:pr3/pages/cart.dart';
import 'package:pr3/pages/description.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pr3/models/group_model.dart';
import 'package:pr3/models/api_service.dart';
import 'package:pr3/pages/favourite.dart';
import 'package:pr3/pages/profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class Homepage extends StatefulWidget {
  const Homepage({super.key});
  @override
  HomepageState createState() => HomepageState();
}

class HomepageState extends State<Homepage> {
  final user = Supabase.instance.client.auth.currentUser;
  late Future<List<Group>> groups;
  final TextEditingController _searchController = TextEditingController();
  List<Group> allGroups = [];
  List<Group> filteredGroups = [];
  dynamic last_id = 0;
  List notes = []; 
  int _selectedIndex = 0;
  Color iconColor = Colors.white;
  int sort = 0;
  String query = '';

  static const List<Widget> _widgetOptions = <Widget>[
    Homepage(),
    Profile(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  //Функция добавления в корзину
  void _addCart(int index) async {
    final item = await ApiService().getGroupByID(index);
    Map<String, dynamic> updatedCart = {};
    if (item.quantity == 0) {
      updatedCart = {
        "Title": item.title,
        "Description": item.description,
        "Favourite": item.favourite,
        "ImageURL": item.image_url,
        "Price": item.price,
        "Quantity": 1,
      };
      await ApiService().updateGroup(index, updatedCart);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: item.quantity == 0 ? Text(item.title+" добавлен в корзину")
        : Text(item.title+" уже в корзине")
      ),
    );
    setState(() {
      readJson();
    });
  }

  //Функия перехода на страницу добавления группы
  void _navigateToAddGroupScreen(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddGroup(last_id: last_id)),
    );

    if (result != null && result.isNotEmpty) {
      createGroup(result);
    }
  }

  //Функция удаления группы по id
  void removeGroup(int index) async {
    await ApiService().deleteGroupByID(index);
    setState(() {
      readJson();
    });
  }

  //Функция создания группы
  void createGroup(Map<String, dynamic> result) async {
    await ApiService().addGroup(result);
    setState(() {
      readJson();
    });
  }

  //Функция изменения статуса избранного
  void _checkStatus(int index) async {
    final group = await ApiService().getGroupByID(index);
    String status = "";
    if (group.favourite == "false") {
      status = "true";
    } else {
      status = "false";
    }
    Map<String, dynamic> updatedStatus = {
      "Title": group.title,
      "Description": group.description,
      "Favourite": status,
      "ImageURL": group.image_url,
      "Price": group.price,
      "Quantity": group.quantity,
    };
    await ApiService().updateGroup(index, updatedStatus);
    setState(() {
      readJson();
    });
  }

  //Функция чтения данных
  void readJson() async {
    groups = ApiService().getGroups();
    List<Group> g = await groups;
    setState(() {
      allGroups = g;
      filteredGroups = g;
    });
  }

  void filterGroups() async {
    List<Group> filtered = [];
    if (query.isNotEmpty) {
      filtered = allGroups.where((group) => group.title.toLowerCase().startsWith(query.toLowerCase())).toList();
    } else {
      filtered = allGroups;
    }
    setState(() {
      filteredGroups = filtered;
    });
  }

  void sortGroups(List<Group> group) {
    switch (sort) {
      case 0:
        group.sort((a, b) => a.id.compareTo(b.id));
        return;
      case 1:
        group.sort((a, b) => a.title.compareTo(b.title));
        return;
      case 2:
        group.sort((a, b) => b.title.compareTo(a.title));
        return;
      case 3:
        group.sort((a, b) => a.price.compareTo(b.price));
        return;
      case 4:
        group.sort((a, b) => b.price.compareTo(a.price));
        return;
      default:
        group.sort((a, b) => a.id.compareTo(b.id));
        return;
    }
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      sort = 0;
    });
    _searchController.addListener(filterGroups);
    readJson();
  }


  @override
  Widget build(BuildContext context) {
    
    //Виджет отображения групп на главной странице
    Widget _buildGroupList() {
      return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              title: Center(child: Text("Группы", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 35))),
              actions: <Widget>[
                IconButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Cart(readJsonH: readJson,)),
                    );
                    setState(() {
                      
                    });
                    if (result != null) {
                      setState(() {
                        readJson();
                      });
                    }
                  }, 
                  icon: const Icon(Icons.shopping_cart)
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(100), 
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: DropdownButton<int>(
                        value: sort,
                        icon: const Icon(Icons.sort),
                        onChanged: (int? newValue) {
                          setState(() {
                            sort = newValue!;
                          });
                        },
                        items: const [
                          DropdownMenuItem(value: 0, child: Text('Без сортировки')),
                          DropdownMenuItem(value: 1, child: Text('С конца алфавита')),
                          DropdownMenuItem(value: 2, child: Text('С начала алфавита')),
                          DropdownMenuItem(value: 3, child: Text('По возрастанию цены')),
                          DropdownMenuItem(value: 4, child: Text('По убыванию цены')),
                        ],
                      ),
                    ),
                    TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            labelText: 'Поиск',
                            hintText: 'Введите название группы',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                            ),
                          ),
                          onChanged: (q) {
                            setState(() {
                              query = q;
                            });
                            filterGroups();
                          },
                    ),
                  ],
                ),
              ),
            ),
            body: FutureBuilder(
                  key: ValueKey(groups),
                  future: groups, 
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text("Нет групп, добавьте новую."));
                    }
                    List<Group> temp_groups = snapshot.data!;
                    last_id = temp_groups.length;
                    List<Group> groups = _searchController.text.isEmpty ? temp_groups : temp_groups.where((group) {
                      return group.title.toLowerCase().startsWith(_searchController.text.toLowerCase());
                    }).toList();
                    sortGroups(groups);
                    // groups.sort((a, b) => b.title.compareTo(a.title));
                    return ListView.builder(
                      key: const PageStorageKey<String>('groupList'),
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
                                    child: FadeInImage.assetNetwork(placeholder: 'lib/components/images/placeholder.png', image: groups[index].image_url, imageErrorBuilder: (context, error, stackTrace) {return Image.asset('lib/components/images/placeholder.png');}, width: double.infinity, fit: BoxFit.fitHeight,)
                                  ),
                                  const SizedBox(height: 10,),
                                  Text(groups[index].title, style: const TextStyle(fontSize: 25, color: Colors.white),),
                                  const SizedBox(height: 10,),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.favorite, color: groups[index].favourite == "true" ? Colors.red : Colors.white), 
                                        onPressed: () {
                                          _checkStatus(groups[index].id);
                                        },
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          _addCart(groups[index].id);
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
                                                    removeGroup(groups[index].id);
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
                                  Text(groups[index].price.toString()+"₽", style: const TextStyle(color: Colors.white),),
                                  const SizedBox(height: 10,),
                                ],
                              ),
                            ),
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => Description(index: groups[index].id, readJson: readJson,),),
                              );
                              setState(() {
                                
                              });
                              if (result != null) {
                                setState(() {
                                  readJson();
                                });
                              }
                            },
                          ),
                        );
                      },
                    );
                  }
                ),
                floatingActionButton: FloatingActionButton(
                  onPressed: () => _navigateToAddGroupScreen(context),
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.add, color: Colors.black),
                ),
      );
    }
    @override
    void dispose() {
      _searchController.dispose();
      super.dispose();
    }
    
    Widget _getCurrentPage() {
      switch (_selectedIndex) {
        case 0:
          return _buildGroupList();
        case 1:
          return Favourite(readJsonH: readJson);
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