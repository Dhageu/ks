import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

  @override
  void initState() {
    super.initState();
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
              const DecoratedBox(
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide()),
                ),
                child: Padding(
                  padding: EdgeInsets.all(0.0),
                  child: Text("Имя пользователя"),
                )
              ),
              const SizedBox(height: 20,),
              const DecoratedBox(
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide()),
                ),
                child: Padding(
                  padding: EdgeInsets.all(0.0),
                  child: Text("Дата регистрации"),
                )
              ),
            ],
          ),
        ),
      )
    );
  }
}