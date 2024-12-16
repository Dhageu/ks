import 'package:flutter/material.dart';
import 'package:pr3/pages/authpage.dart';
import 'package:pr3/pages/orders.dart';
import 'package:pr3/pages/pick_receiver.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final user = Supabase.instance.client.auth.currentUser!;
  String username = '';
  dynamic email = '';
  dynamic createdAt = '';

  Future<void> signOut() async {
    try {
      await Supabase.instance.client.auth.signOut();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Authpage()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка выхода $e')),
      );
    }
  }

  Future<void> fetchData() async {
    final response = await Supabase.instance.client.from('users').select().eq('user_id', user.id.toString());
    if (response.isNotEmpty) {
      final List<dynamic> data = response;
      for (var r in data) {
        username = r['name'];
      }
    }
    email = user.email;
    createdAt = user.createdAt.toString().replaceAll('T', ' ').split('.').first;
    setState(() {
      
    });
  }

  @override
  void initState() {
    super.initState();
    fetchData();
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
              DecoratedBox(
                decoration: const BoxDecoration(
                ),
                child: Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: Text('Имя пользователя: $username'),
                )
              ),
              const SizedBox(height: 20,),
              DecoratedBox(
                decoration: const BoxDecoration(
                ),
                child: Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: Text('Почта: $email'),
                )
              ),
              const SizedBox(height: 20,),
              DecoratedBox(
                decoration: const BoxDecoration(
                ),
                child: Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: Text('Дата и время создания: $createdAt'),
                )
              ),
              const SizedBox(height: 50,),
              ElevatedButton(onPressed: () {signOut();}, child: const Text('Выход', style: TextStyle(color: Colors.black),)),
              const SizedBox(height: 10,),
              ElevatedButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Orders(),),
                  );
                }, 
                child: const Text('Мои заказы', style: TextStyle(color: Colors.black),)
              ),
              const SizedBox(height: 10,),
              ElevatedButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PickReceiver(),),
                  );
                }, 
                child: const Text('Чат', style: TextStyle(color: Colors.black),)
              ),
              const SizedBox(height: 20,)
            ],
          ),
        ),
      )
    );
  }
}