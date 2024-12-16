import 'package:flutter/material.dart';
import 'package:pr3/pages/homepage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Authpage extends StatefulWidget {
  const Authpage({super.key});

  @override
  State<Authpage> createState() => _AuthpageState();
}

class _AuthpageState extends State<Authpage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();

  void saveUser() {

  }

  Future<void> signUp(String email, String password, BuildContext context) async {
    try {
      final RegExp emailRegex = RegExp(
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
      );
      if (!emailRegex.hasMatch(email) && email != '') {
        throw const AuthException('Invalid mail address');
      }
      final response = await Supabase.instance.client.auth.signUp(email: email, password: password);
      if (response.user?.id != null) {
        final user_id = response.user?.id;
        showDialog(
          context: context, 
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Введите имя пользователя'),
              content: TextField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Имя пользователя'),
              ),
              actions: [
                Row(
                  children: [
                    ElevatedButton( 
                      onPressed: () async {
                        try {
                          await Supabase.instance.client.from('users').insert({'name': _usernameController.text, 'user_id': user_id});
                        } catch (e) {
                          debugPrint('Ошибка в установке имени $e');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Ошибка в установке имени $e')),
                          );
                        }
                        if (_usernameController.text != '') {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Homepage()));
                        }
                      },
                      child: const Text('Закончить регистрацию')),
                    ElevatedButton( 
                      onPressed: () async {
                        try {
                          final admin = SupabaseClient('https://zjapfdjwdduyjhukieof.supabase.co', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpqYXBmZGp3ZGR1eWpodWtpZW9mIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTczNDA5NzI2NCwiZXhwIjoyMDQ5NjczMjY0fQ.iPnTJoR_8sPupnW1ayeOtDan543CCpw35tOp9_T3xOo');
                          await admin.auth.admin.deleteUser(user_id!);
                          await Supabase.instance.client.auth.signOut();
                          Navigator.pop(context);
                          //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Authpage()));
                        } catch (e) {
                          debugPrint('Ошибка в удалении пользователя $e');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Ошибка в удалении пользователя')),
                          );
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Отмена')),
                  ],
                ),
              ],
            );
          }
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('id не найдено')),
        );
      }
    } on AuthException catch (e) {
      dynamic error;
      switch (e.message) {
        case 'User already registered':
          error = 'пользователь уже существует';
          break;
        case 'Signup requires a valid password':
          error = 'неправильный пароль или почта';
          break;
        case 'Anonymous sign-ins are disabled':
          error = 'поле email не должно быть пустым';
          break;
        case 'Invalid mail address':
          error = 'неверный вид email';
          break;
        default:
          error = e;
          break;
      }
      debugPrint('Ошибка регистрации $error $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка регистрации: $error')),
      );
    }
  }

  // Функция для входа
  Future<void> signIn(String email, String password) async {
    try {
      final RegExp emailRegex = RegExp(
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
      );
      if (!emailRegex.hasMatch(email) && email != '') {
        throw const AuthException('Invalid mail address');
      }
      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Homepage()));
    } on AuthException catch (e) {
      dynamic error;
      switch (e.message) {
        case 'Invalid login credentials':
          error = 'неправильный пароль или почта';
          break;
        case 'missing email or phone':
          error = 'поле почты не должно быть пустым';
          break;
        case 'Anonymous sign-ins are disabled':
          error = 'поле email не должно быть пустым';
          break;
        case 'Invalid mail address':
          error = 'неверный вид email';
          break;
        default:
          error = e;
          break;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка входа: $error')),
      );
    }
  }

  // Функция для выхода из системы
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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Авторизация')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Пароль'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final email = _emailController.text;
                final password = _passwordController.text;
                await signIn(email, password); // Вход в систему
              },
              child: const Text('Войти'),
            ),
            const SizedBox(height: 20,),
            ElevatedButton(
              onPressed: () async {
                final email = _emailController.text;
                final password = _passwordController.text;
                await signUp(email, password, context); // Регистрация
              },
              child: const Text('Зарегистрироваться'),
            ),
          ],
        ),
      ),
    );
  }
}