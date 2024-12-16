import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  // Переменные для цветов текста, которые можно изменять
  final Color phoneColor;
  final Color emailColor;
  final Color linkColor;

  const ProfilePage({super.key, 
    this.phoneColor = Colors.black38,       // по умолчанию чёрный
    this.emailColor = Colors.black38,       // по умолчанию чёрный
    this.linkColor = Colors.grey,         // по умолчанию синий
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль', style: TextStyle(fontFamily: 'Montserrat')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Эдуард',
              style: TextStyle(
                fontSize: 24,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w500, // Medium вес
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '+7 900 800-55-33',
              style: TextStyle(
                fontFamily: 'Montserrat',
                color: phoneColor, // цвет для номера телефона
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'email@gmail.com',
              style: TextStyle(
                fontFamily: 'Montserrat',
                color: emailColor, // цвет для почты
              ),
            ),
            const SizedBox(height: 32),
            ProfileOption(
              iconPath: 'assets/icons/Order.png',
              title: 'Мои заказы',
            ),
            ProfileOption(
              iconPath: 'assets/icons/Cards.png',
              title: 'Медицинские карты',
            ),
            ProfileOption(
              iconPath: 'assets/icons/Adress.png',
              title: 'Мои адреса',
            ),
            ProfileOption(
              iconPath: 'assets/icons/Settings.png',
              title: 'Настройки',
            ),
            const Spacer(),
            // Настройка цвета ссылок
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Center(
                child: Column(
                  children: [
                    Text(
                      'Ответы на вопросы',
                      style: TextStyle(fontFamily: 'Montserrat', color: linkColor),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Center(
                child: Column(
                  children: [
                    Text(
                      'Политика конфиденциальности',
                      style: TextStyle(fontFamily: 'Montserrat', color: linkColor),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Center(
                child: Column(
                  children: [
                    Text(
                      'Пользовательское соглашение',
                      style: TextStyle(fontFamily: 'Montserrat', color: linkColor),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Center(
                child: TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Выход',
                    style: TextStyle(color: Colors.red, fontFamily: 'Montserrat'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileOption extends StatelessWidget {
  final String iconPath;
  final String title;

  const ProfileOption({super.key, 
    required this.iconPath,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Image.asset(
        iconPath,
        width: 24,
        height: 24,
      ),
      title: Text(
        title,
        style: const TextStyle(fontFamily: 'Montserrat'),
      ),
      onTap: () {
        // Добавьте здесь действие при нажатии
      },
    );
  }
}
