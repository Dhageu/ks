import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:pr3/models/api_service.dart';
import 'package:pr3/models/group_model.dart';
import 'package:pr3/pages/description.dart';

class Cart extends StatefulWidget {
  final VoidCallback readJsonH;
  const Cart({super.key, required this.readJsonH});

  @override
  State<Cart> createState() => _CartState(readJsonH: readJsonH);
}

class _CartState extends State<Cart> {
  late Future<List<Group>> cartItems;
  final VoidCallback readJsonH;
  _CartState({required this.readJsonH});
  //Функция чтения json файла
  void readJson() async {
    cartItems = ApiService().getCartItems();
    readJsonH();
  }

  //Функция удаления из корзины
  Future<void> _cartRemove(Group item) async {
    Map<String, dynamic> updatedCart = {
      "Title": item.title,
      "Description": item.description,
      "Favourite": item.favourite,
      "ImageURL": item.image_url,
      "Price": item.price,
      "Quantity": 0,
    };
    await ApiService().updateGroup(item.id, updatedCart);
    setState(() {
      readJson();
    });
  }
  
  //Функция изменения количества товара в корзине
  Future<void> _cartAddRemove(Group item, bool increase) async {
    Map<String, dynamic> updatedCart = {};
    if (increase) {
      updatedCart = {
        "Title": item.title,
        "Description": item.description,
        "Favourite": item.favourite,
        "ImageURL": item.image_url,
        "Price": item.price,
        "Quantity": item.quantity+1,
      };
    } else {
      updatedCart = {
        "Title": item.title,
        "Description": item.description,
        "Favourite": item.favourite,
        "ImageURL": item.image_url,
        "Price": item.price,
        "Quantity": item.quantity-1,
      };
    }
    await ApiService().updateGroup(item.id, updatedCart);
    setState(() {
      readJson();
    });
  }
  
  @override
  void initState() {
    super.initState();
    setState(() {
      
    });
    readJson();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
                backgroundColor: Colors.white,
                title: const Center(child: Text("Корзина", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 35))),
                 leading: IconButton(
                  onPressed: () {
                    readJsonH();
                    setState(() {
                      readJsonH();
                    });
                    Navigator.pop(context);
                    readJsonH();
                  }, 
                  icon: const Icon(Icons.arrow_back),
                ),
              ),
      body: FutureBuilder(
        future: cartItems,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Корзина пуста."));
          }
          final cartItems = snapshot.data!;
          return Stack(
                  children: [
                    ListView.builder(
                      itemCount: cartItems.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Slidable(
                              startActionPane: ActionPane(
                                motion: const ScrollMotion(), 
                                children: [
                                  SlidableAction(
                                    icon: Icons.delete,
                                    label: "Удалить",
                                    onPressed: (context) {_cartRemove(cartItems[index]); setState(() {readJson();});},
                                  ),
                                ],
                              ),
                              child: Card(
                                color: Colors.black,
                                child: ListTile(
                                  leading: ClipRRect(
                                    child: FadeInImage.assetNetwork(placeholder: 'lib/components/images/placeholder.png', image: cartItems[index].image_url, imageErrorBuilder: (context, error, stackTrace) {return Image.asset('lib/components/images/placeholder.png');}, width: 50, height: 50, fit: BoxFit.cover,)
                                  ),
                                  title: Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: Text(cartItems[index].title, style: const TextStyle(color: Colors.white)),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      IconButton(
                                        onPressed: () {_cartAddRemove(cartItems[index], true);}, 
                                        icon: const Icon(Icons.add, color: Colors.white)
                                      ),
                                      IconButton(
                                        onPressed: () {_cartAddRemove(cartItems[index], false);}, 
                                        icon: const Icon(Icons.remove, color: Colors.white)
                                      ),
                                    ],
                                  ),
                                  subtitle: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text((cartItems[index].price*cartItems[index].quantity).toString()+"₽", style: const TextStyle(color: Colors.white)),
                                      Text('Количество: '+cartItems[index].quantity.toString(), style: const TextStyle(color: Colors.white)),
                                    ],
                                  ),
                                  onTap: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => Description(index: cartItems[index].id, readJson: readJson,),),
                                    );
                                    setState(() {
                                      
                                    });
                                    if (result != null) {
                                      setState(() {
                                        readJson();
                                      });
                                    }
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
                              'Суммарная стоимость корзины: ${cartItems.fold(0, (f, s) {
                                return (f + (int.parse(s.price.toString()) * int.parse(s.quantity.toString())));
                              })} ₽',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                  ],
                );
        }
      )
    );
  }
}