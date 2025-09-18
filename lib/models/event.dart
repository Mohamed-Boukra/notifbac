class Event {
  final int? id;
  final String title;
  final String date;
  final int listId;
  final bool isCustom;

  Event({
    this.id,
    required this.title,
    required this.date,
    required this.listId,
    this.isCustom = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': date,
      'listId': listId,
      'isCustom': isCustom,
    };
  }

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      title: json['title'],
      date: json['date'],
      listId: json['listId'],
      isCustom: json['isCustom'] ?? false,
    );
  }

  Event copyWith({
    int? id,
    String? title,
    String? date,
    int? listId,
    bool? isCustom,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      listId: listId ?? this.listId,
      isCustom: isCustom ?? this.isCustom,
    );
  }
}
