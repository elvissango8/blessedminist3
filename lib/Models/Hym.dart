class Hym {
  final String title;
  final String lyrics;
  final String id;

  Hym({required this.id,required this.title, required this.lyrics});

  factory Hym.fromJson(Map<String, dynamic> json) {
    return Hym(
      id:json['id'],
      title: json['title'],
      lyrics: json['text'],

    );
  }
}