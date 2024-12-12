import 'package:flutter/material.dart';

class AddGroup extends StatefulWidget {
  final last_id;
  const AddGroup({super.key, required this.last_id});

  @override
  State<AddGroup> createState() => _AddGroupState(last_id: last_id);
}

class _AddGroupState extends State<AddGroup> {
  _AddGroupState({required this.last_id});
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final last_id;

  void readJson() {
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Добавление группы"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Введите название группы', labelStyle: TextStyle(color: Colors.black),),
              maxLines: 5,
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Введите описание группы', labelStyle: TextStyle(color: Colors.black),),
              maxLines: 5,
            ),
            TextField(
              controller: _imageUrlController,
              decoration: const InputDecoration(labelText: 'Введите ссылку на изображение', labelStyle: TextStyle(color: Colors.black),),
              maxLines: 5,
            ),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Введите цену товара', labelStyle: TextStyle(color: Colors.black),),
              maxLines: 5,
            ),
            const SizedBox(height: 20,),
            ElevatedButton(
              onPressed: () {
                Map<String, dynamic> newGroup = {
                  "ID": last_id+1,
                  "Title": _titleController.text,
                  "Description": _descriptionController.text,
                  "ImageURL": _imageUrlController.text,
                  "Favourite": "false",
                  "Price": int.parse(_priceController.text),
                  "Quantity": 0
                };
                if (newGroup.isNotEmpty) {
                  Navigator.pop(context, newGroup);
                }
              }, 
              child: const Text("Сохранить", style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}