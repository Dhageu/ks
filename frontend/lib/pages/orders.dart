import 'package:flutter/material.dart';
import 'package:pr3/models/group_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Orders extends StatefulWidget {
  const Orders({super.key});

  @override
  State<Orders> createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  late Future<List<List<Group>>> orders;
  late Future<List<Group>> savedItems;
  late List<Group> g;
  
  //Функция чтения json файла
  Future<List<List<Group>>> readFromSB() async {

    final user = Supabase.instance.client.auth.currentUser!;
    try {
      final response = await Supabase.instance.client.from('users').select('orders').eq('user_id', user.id.toString());
      List<dynamic> data = response[0]['orders'];
      List<List<Group>> g_temp = data.map((orderGroup) {
        return (orderGroup as List<dynamic>).map((json) => Group.fromJson(json)).toList();
      }).toList();
      return g_temp;
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
    
  }

  void saveData() {
    orders = readFromSB();
  }

  int getSum(List<List<Group>> orderList) {
    return orderList.fold(0, (f, s) {
      int groupTotal = s.fold(0, (f, s) => f + (s.price*s.quantity));
      return f + groupTotal;
    });
  }
  
  @override
  void initState() {
    super.initState();
    setState(() {
      
    });
    saveData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
                backgroundColor: Colors.white,
                title: const Center(child: Text("Заказы", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 35))),
                 leading: IconButton(
                  onPressed: () {
                    setState(() {
                      Navigator.pop(context);
                    });
                  }, 
                  icon: const Icon(Icons.arrow_back),
                ),
              ),
      body: FutureBuilder<List<List<Group>>>(
        future: orders,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Заказов нет."));
          }
          List<List<Group>> orders = snapshot.data!;
          return Stack(children: [
            ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final orderItems = orders[index];
                 return Card(
                   child: Column(
                     children: [
                      Text('Заказ ${index+1}', style: TextStyle(fontSize: 20)),
                      Column(
                        children: orderItems.map((group) {
                          return ListTile(
                            title: Text(group.title),
                            subtitle: Text('Цена: ${group.price*group.quantity} ₽'),
                            leading: FadeInImage.assetNetwork(placeholder: 'lib/components/images/placeholder.png', image: group.image_url.toString(), imageErrorBuilder: (context, error, stackTrace) {return Image.asset('lib/components/images/placeholder.png');}, width: 100, fit: BoxFit.cover,),
                            trailing: Text('Количество: ${group.quantity}'),
                          );
                        }).toList(),
                      ),
                     ],
                   ),
                 );
              },
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
                  'Суммарная стоимость заказов: ${getSum(orders)} ₽',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],);
        }
      )
    );
  }
}