class Group {
  final int id;
  final String title;
  final String description;
  final String image_url;
  final String favourite;
  final int price;
  final int quantity;

  Group({
    required this.id,
    required this.title,
    required this.description,
    required this.image_url,
    required this.favourite,
    required this.price,
    required this.quantity,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['ID'] as int,
      title: json['Title'],
      description: json['Description'],
      image_url: json['ImageURL'],
      favourite: json['Favourite'],
      price: json['Price'] as int,
      quantity: json['Quantity'] as int,
    );
  }
}