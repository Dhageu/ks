import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter7/models/cart.dart';
import 'package:flutter7/models/service.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Корзина', style: TextStyle(fontFamily: 'Montserrat'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: cart.items.isEmpty
            ? const Center(child: Text('Корзина пуста', style: TextStyle(fontFamily: 'Montserrat'),
        ),
        )
            : Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: cart.items.length,
                itemBuilder: (context, index) {
                  return CartItem(cart.items[index]);
                },
              ),
            ),
            const Spacer(),
            Text(
              'Сумма: ${cart.totalPrice} ₽',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: Text('Перейти к оформлению заказа', style: TextStyle(fontFamily: 'Montserrat'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CartItem extends StatelessWidget {
  final Service service;

  const CartItem(this.service, {super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, // Белый фон
        borderRadius: BorderRadius.circular(8), // Закругленные углы
        border: Border.all(
          color: Colors.grey, // Серая окантовка
          width: 1, // Толщина окантовки
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(service.title, style: const TextStyle(fontFamily: 'Montserrat', fontSize: 18)), // Название услуги
                Text('Цена: ${service.price}', style: const TextStyle(fontFamily: 'Montserrat'),), // Цена услуги
                Text('Пациент: ${service.quantity}', style: const TextStyle(fontFamily: 'Montserrat'),), // Количество
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: () {
                  cart.removeItem(service);
                },
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  cart.addItem(service); // Добавляем 1 к количеству
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}