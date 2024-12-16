import 'package:flutter/material.dart';
import 'package:pr3/models/group_model.dart';
import 'package:pr3/pages/chat.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PickReceiver extends StatefulWidget {
  const PickReceiver({super.key});

  @override
  State<PickReceiver> createState() => _PickReceiverState();
}

class _PickReceiverState extends State<PickReceiver> {
  late SupabaseStreamBuilder chat;
  late Future<List<Group>> savedItems;
  final user = Supabase.instance.client.auth.currentUser!;
  late Future<List<dynamic>> receivers;
  late List<Group> g;

  //Функция чтения json файла
  Future<List<dynamic>> readFromSB() async {
    try {
      final res = await Supabase.instance.client.from('users').select('user_id, name').neq('user_id', user.id.toString());
      return res;
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }
  
  @override
  void initState() {
    super.initState();
    receivers = readFromSB();
    setState(() {
      
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Center(child: Text("Выбор чата", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 35))),
          leading: IconButton(
          onPressed: () {
            setState(() {
              Navigator.pop(context);
            });
          }, 
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: FutureBuilder(
        future: receivers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Text("Пользователей нет.");
          }
          final receiver = snapshot.data as List<dynamic>;
          final uniqueReceivers = receiver.fold<List<dynamic>>([], (acc, item) {
            if (!acc.any((e) => e['user_id'] == item['user_id'])) {
              acc.add(item);
            }
            return acc;
          });
          return ListView.builder(
            itemCount: uniqueReceivers.length,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  const SizedBox(height: 10,),
                  ElevatedButton(
                    onPressed: () async {
                      String username = uniqueReceivers[index]['name'].toString();
                      String receiver_id = uniqueReceivers[index]['user_id'].toString();
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Chat(receiver_username: username, receiver_id: receiver_id,),),
                      );
                    }, 
                    child: Text(uniqueReceivers[index]['name'], style: const TextStyle(color: Colors.black)),
                  ),
                ],
              );
            }
          );
        }
      ),
    );
  }
}