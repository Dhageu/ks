import 'package:flutter/material.dart';

class AddGroup extends StatefulWidget {
  const AddGroup({super.key});

  @override
  State<AddGroup> createState() => _AddGroupState();
}

class _AddGroupState extends State<AddGroup> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();

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
            const SizedBox(height: 20,),
            ElevatedButton(
              onPressed: () {
                Map<String, dynamic> newGroup = {
                  "title": _titleController.text,
                  "description": _descriptionController.text,
                  "image_url": _imageUrlController.text
                };
                if (newGroup.isNotEmpty) {
                  Navigator.pop(context, newGroup);
                }
              }, 
              child: const Text("Save", style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}