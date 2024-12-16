import 'package:flutter/material.dart';
import 'package:pr3/models/api_service.dart';
import 'package:pr3/models/group_model.dart';
import 'package:pr3/pages/cart.dart';
import 'package:pr3/pages/description.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Favourite extends StatefulWidget {
  final VoidCallback readJsonH;
  const Favourite({super.key, required this.readJsonH});

  @override
  State<Favourite> createState() => _FavouriteState(readJsonH: readJsonH);
}

class _FavouriteState extends State<Favourite> {
  final user = Supabase.instance.client.auth.currentUser!;
  final VoidCallback readJsonH;
  _FavouriteState({required this.readJsonH});
  late Future<List<Group>> favourites;
  List<Group> f = [];
  List tt = [];

  void readJson() async {
    favourites = ApiService().getFavourites(user.id.toString());
    f = await favourites;
    setState(() {

    });
    readJsonH();
  }

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

  void _checkStatus(int index) async {
    if (f.isNotEmpty && f.map((favourite) => favourite.id).toSet().contains(index)) {
      await ApiService().deleteFavByID(index, user.id.toString());
      setState(() {
        readJson();
      });
    } else {
      await ApiService().addFav(index, user.id.toString());
      setState(() {
        readJson();
      });
    }
  }

  @override
  void initState () {
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
              title: const Center(child: Text("Группы", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 35))),
              actions: <Widget>[
                IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Cart(readJsonH: readJson,)),
                    );
                    setState(() {
                    });
                  }, 
                  icon: const Icon(Icons.shopping_cart)
                ),
              ],
            ),
            body: FutureBuilder(
                  future: favourites, 
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text("Нет любимых, добавьте новые."));
                    }
                    final favourites = snapshot.data!;
                    return ListView.builder(
                      key: const PageStorageKey<String>('FavouritesList'),
                      itemCount: favourites.length,
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
                                    child: FadeInImage.assetNetwork(placeholder: 'lib/components/images/placeholder.png', image: favourites[index].image_url, imageErrorBuilder: (context, error, stackTrace) {return Image.asset('lib/components/images/placeholder.png');}, width: double.infinity, fit: BoxFit.fitHeight,)
                                  ),
                                  const SizedBox(height: 10,),
                                  Text(favourites[index].title, style: const TextStyle(fontSize: 25, color: Colors.white),),
                                  const SizedBox(height: 10,),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.favorite, color: Colors.red), 
                                        onPressed: () {
                                          setState(() {
                                            _checkStatus(favourites[index].id);
                                          });
                                        },
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          _addCart(favourites[index].id);
                                        }, 
                                        icon: const Icon(Icons.add_shopping_cart, color: Colors.white)
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10,),
                                  Text(favourites[index].price.toString()+"₽", style: const TextStyle(color: Colors.white),),
                                  const SizedBox(height: 10,),
                                ],
                              ),
                            ),
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => Description(index: favourites[index].id, readJson: readJson,),),
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
      );
  }
}