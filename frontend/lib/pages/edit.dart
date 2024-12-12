import 'package:flutter/material.dart';
import 'package:pr3/models/api_service.dart';
import 'package:pr3/models/group_model.dart';

class EditGroup extends StatefulWidget {
  /*final Group group;
  final String title;
  final String description;
  final String image_url;
  final String favoutite;
  final int quantity;
  final int price;*/
  final VoidCallback readGroup;
  final int index;
  const EditGroup({super.key, required this.readGroup, required this.index});

  @override
  State<EditGroup> createState() => _EditGroupState(readGroup: readGroup, index: index);
}

class _EditGroupState extends State<EditGroup> {
  final int index;
  _EditGroupState({required this.readGroup, required this.index});
  final VoidCallback readGroup;
  late Group group;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  void readJson() async {
    group = await ApiService().getGroupByID(index);
  }

  @override
  void initState() {
    super.initState();
    readJson();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Изменение группы"),
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
                Map<String, dynamic> changedGroup = {
                  "ID": group.id,
                  "Title": _titleController.text == '' ? group.title : _titleController.text,
                  "Description": _descriptionController.text == '' ? group.description : _descriptionController.text,
                  "ImageURL": _imageUrlController.text == '' ? group.image_url : _imageUrlController.text,
                  "Favourite": group.favourite,
                  "Price": _priceController.text == '' ? group.price : int.parse(_priceController.text),
                  "Quantity": group.id
                };
                if (changedGroup.isNotEmpty) {
                  Navigator.pop(context, changedGroup);
                }
              }, 
              child: const Text("Сохранить изменения", style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}