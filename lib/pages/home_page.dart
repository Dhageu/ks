import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter7/models/cart.dart';
import 'package:flutter7/models/service.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Каталог услуг',
          style: TextStyle(
            fontSize: 24, // Увеличиваем размер шрифта
            fontWeight: FontWeight.w500,
            fontFamily: 'Montserrat',
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          ServiceCard(
            title: 'Клинический анализ крови с лейкоцитарной формулой',
            price: '690 ₽',
            duration: '1 день',
          ),
          ServiceCard(
            title: 'ПЦР-тест на определение РНК коронавируса',
            price: '1800 ₽',
            duration: '2 дня',
          ),
          ServiceCard(
            title: 'Глюкозотолерантный тест с определением глюкозы и С-пептида в венозной крови натощак и через 2 часа после углеводной нагрузки',
            price: '1 400 ₽',
            duration: '1 день',
          ),
          ServiceCard(
            title: 'Электрофорез гемоглобина',
            price: '4 265 ₽',
            duration: '7 дней',
          ),
          ServiceCard(
            title: 'Респираторная панель Immulite (20 респираторных аллергенов)',
            price: '8 650 ₽',
            duration: '5 дней',
          ),
          ServiceCard(
            title: 'Антитела к ВИЧ 1 и 2 и антиген ВИЧ 1 и 2 ',
            price: '620 ₽',
            duration: '1 день',
          ),
          ServiceCard(
            title: 'Антитела класса IgM к Respiratory syncyt. vir.',
            price: '1 150 ₽',
            duration: '5 дней',
          ),
        ],
      ),
    );
  }
}

class ServiceCard extends StatelessWidget {
  final String title;
  final String price;
  final String duration;

  const ServiceCard({super.key, 
    required this.title,
    required this.price,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, // Белый фон
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade300, // Более светлая серая окантовка
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4), // Слегка увеличенная тень для глубины
          ),
        ],
      ),
      child: Row(

        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    title,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Montserrat',
                    ),
                ),
                const SizedBox(height: 4),
                Text(duration,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontFamily: 'Montserrat',
                  ),
                ),
                Text(
                    price,
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: 'Montserrat',
                    )
                ), // Цена услуги
              ],
            ),
          ),

          ElevatedButton(
            onPressed: () {
              final cart = Provider.of<Cart>(context, listen: false);
              final service = Service(title: title, price: price, duration: duration);
              cart.addItem(service);
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12), // Увеличиваем вертикальный отступ
              child: Text(
                  'Добавить',
                  style: TextStyle(fontFamily: 'Montserrat'),
              ),
            ),

          ),
        ],
      ),
    );
  }
}