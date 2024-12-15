import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:pr3/models/api_service.dart';
import 'package:pr3/models/group_model.dart';
import 'package:pr3/pages/description.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Cart extends StatefulWidget {
  final VoidCallback readJsonH;
  const Cart({super.key, required this.readJsonH});

  @override
  State<Cart> createState() => _CartState(readJsonH: readJsonH);
}

class _CartState extends State<Cart> {
  final user = Supabase.instance.client.auth.currentUser!;
  late Future<List<Group>> cartItems;
  final VoidCallback readJsonH;
  _CartState({required this.readJsonH});
  //Функция чтения json файла
  void readJson() async {
    cartItems = ApiService().getCartItems(user.id.toString());
    readJsonH();
  }

  //Функция удаления из корзины
  Future<void> _cartRemove(Group item) async {
    await ApiService().deleteCartByID(item.id, user.id.toString());
    setState(() {
      readJson();
    });
  }
  
  //Функция изменения количества товара в корзине
  Future<void> _cartAddRemove(Group item, bool increase) async {
    Map<String, dynamic> updatedCart = {};
    if (increase) {
      updatedCart = {
        "ID": item.id,
        "Quantity": item.quantity+1,
      };
    } else {
      updatedCart = {
        "ID": item.id,
        "Quantity": item.quantity-1,
      };
    }
    await ApiService().updateQuantity(user.id.toString(), updatedCart);
    setState(() {
      readJson();
    });
  }

  void saveOrdersToDB(List<Group> g) async {
    final user = Supabase.instance.client.auth.currentUser!;
    Map<String, dynamic> updatedCart = {};
    debugPrint(user.id);
    List<Map<String, dynamic>> g_json = g.map((group) => group.toJson()).toList();
    try {
      final response = await Supabase.instance.client.rpc('add_to_jsonb_array', params: {'u_id': user.id.toString(), 'new_element': g_json});
      debugPrint('Успешно отправилось в Supabase');
      for (var item in g) {
        updatedCart = {
          "Title": item.title,
          "Description": item.description,
          "Favourite": item.favourite,
          "ImageURL": item.image_url,
          "Price": item.price,
          "Quantity": 0,
        };
        await ApiService().updateGroup(item.id, updatedCart);
        await ApiService().deleteCartByID(item.id, user.id.toString());
      }
      setState(() {
        readJson(); 
      });
    } catch (e) {
      debugPrint('Ошибка при отправке данных $e');
    }
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
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 1,
                                  ),
                                  color: Colors.white,
                                ),
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  'Суммарная стоимость корзины: ${cartItems.fold(0, (f, s) {
                                    return (f + (int.parse(s.price.toString()) * int.parse(s.quantity.toString())));
                                  })} ₽',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10,),
                            TextButton(
                              onPressed: () {saveOrdersToDB(cartItems);},
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 50), 
                              ),
                              child: const Text(
                                'Оформить заказ',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20,),
                      ],
                    ),
                  ],
                );
        }
      )
    );
  }
}