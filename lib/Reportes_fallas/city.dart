class MyItem {
  int id;
  String name;

  MyItem({required this.id, required this.name});

  factory MyItem.fromJson(Map<String, dynamic> json) {
    return MyItem(
      id: json['id'],
      name: json['name2'],
    );
  }
}
