import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:pr3/pages/description.dart';

class Cart extends StatefulWidget {
  final VoidCallback readJsonH;
  const Cart({super.key, required this.readJsonH});

  @override
  State<Cart> createState() => _CartState(readJsonH: readJsonH);
}

class _CartState extends State<Cart> {
  final VoidCallback readJsonH;
  _CartState({required this.readJsonH});
  List<dynamic> groups_cart = [];

  //Функция чтения json файла
  Future<void> readJson() async {
    final file = File('lib/components/product.json');
    String contents = await file.readAsString();
    Map<String, dynamic> jsonFileContent = await jsonDecode(contents);
    setState(() {
      groups_cart = (jsonFileContent['groups'] as List).where((item) => item['quantity'] > 0).toList();
    });
  }

  //Функция удаления из корзины
  Future<void> _cartRemove(int index) async {
    final file = File('lib/components/product.json');
    String contents = await file.readAsString();
    Map<String, dynamic> jsonFileContent = await jsonDecode(contents);
    int c_index = (jsonFileContent['groups'] as List).indexWhere((item) => item["title"] == groups_cart[index]["title"]);
    jsonFileContent['groups'][c_index]["quantity"] = 0;
    await file.writeAsString(jsonEncode(jsonFileContent));
    setState(() {
      readJson();
      readJsonH();
    });
  }
  
  //Функция изменения количества товара в корзине
  Future<void> _cartAddRemove(int index, bool increase) async {
    final file = File('lib/components/product.json');
    String contents = await file.readAsString();
    Map<String, dynamic> jsonFileContent = await jsonDecode(contents);
    int c_index = (jsonFileContent['groups'] as List).indexWhere((item) => item["title"] == groups_cart[index]["title"]);
    if (increase) {
      jsonFileContent['groups'][c_index]['quantity']++;
    } else {
      jsonFileContent['groups'][c_index]['quantity']--;
    }
    await file.writeAsString(jsonEncode(jsonFileContent));
    setState(() {
      readJson();
      readJsonH();
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
                backgroundColor: Colors.white,
                title: const Center(child: Text("Корзина", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 35))),
              ),
      body: groups_cart.isEmpty ? const Center(child: Text("Корзина пуста", style: TextStyle(fontSize: 15)))
      : Stack(
        children: [
          ListView.builder(
            itemCount: groups_cart.length,
            itemBuilder: (BuildContext context, int index) {
              return Slidable(
                    startActionPane: ActionPane(
                      motion: const ScrollMotion(), 
                      children: [
                        SlidableAction(
                          icon: Icons.delete,
                          label: "Удалить",
                          onPressed: (context) {_cartRemove(index); setState(() {readJson();});},
                        ),
                      ],
                    ),
                    child: Card(
                      color: Colors.black,
                      child: ListTile(
                        leading: Image.network(groups_cart[index]["image_url"], width: 50, height: 50, fit: BoxFit.cover,),
                        title: Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(groups_cart[index]["title"], style: const TextStyle(color: Colors.white)),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            IconButton(
                              onPressed: () {_cartAddRemove(index, true);}, 
                              icon: const Icon(Icons.add, color: Colors.white)
                            ),
                            IconButton(
                              onPressed: () {_cartAddRemove(index, false);}, 
                              icon: const Icon(Icons.remove, color: Colors.white)
                            ),
                          ],
                        ),
                        subtitle: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text((groups_cart[index]["price"]*groups_cart[index]["quantity"]).toString()+"₽", style: const TextStyle(color: Colors.white)),
                            Text('Количество: '+groups_cart[index]["quantity"].toString(), style: const TextStyle(color: Colors.white)),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Description(group: groups_cart[index]),),
                          );
                        },
                      )
                    ),
              );
            }
          ),
          Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    color: Colors.black,
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Суммарная стоимость корзины: ${groups_cart.fold(0, (f, s) {
                      return (f + (int.parse(s['price'].toString()) * int.parse(s['quantity'].toString())));
                    })} ₽',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
        ],
      )
    );
  }
}