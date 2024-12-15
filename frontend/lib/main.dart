import 'package:flutter/material.dart';
import 'package:pr3/pages/authpage.dart';
import 'package:pr3/pages/homepage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'dart:io';

void main() async {
  await Supabase.initialize(
    url: 'https://zjapfdjwdduyjhukieof.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpqYXBmZGp3ZGR1eWpodWtpZW9mIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzQwOTcyNjQsImV4cCI6MjA0OTY3MzI2NH0.9Ol_wcE058sV1OzIV5M6qwIvJL7GcclZDsdsWMxIkuY'
  );
  runApp(MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override 
  MainAppState createState() => MainAppState();
}

class MainAppState extends State<MainApp> {
  final user = Supabase.instance.client.auth.currentUser;
  bool error = false;
  
  void getUserID() async {
    final admin = SupabaseClient('https://zjapfdjwdduyjhukieof.supabase.co', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpqYXBmZGp3ZGR1eWpodWtpZW9mIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTczNDA5NzI2NCwiZXhwIjoyMDQ5NjczMjY0fQ.iPnTJoR_8sPupnW1ayeOtDan543CCpw35tOp9_T3xOo');
    try {
      if (user == null) {
        throw AuthException('Пользователь не найден');
      } else{
        final response = await admin.auth.admin.getUserById(user!.id);
      }
    } on AuthException catch (e) {
      debugPrint(e.statusCode);
      setState(() {
        error = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getUserID();
  }
  @override
  Widget build(BuildContext context) {
    if (error != true) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Homepage(),
      );
    } else {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Authpage(),
      );
    }
  }
}