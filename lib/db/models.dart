class Action {
  int? id; // Nullable to handle auto-increment by the database
  String name;
  double payPerDay;

  Action({this.id, required this.name, required this.payPerDay}); // Making 'id' optional

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'name': name,
      'payPerDay': payPerDay,
    };

    if (id != null) {
      map['id'] = id; // Include 'id' in the map if it's not null
    }
    return map;
  }

  static Action fromMap(Map<String, dynamic> map) {
    return Action(
      id: map['id'],
      name: map['name'],
      payPerDay: map['payPerDay'],
    );
  }
}



class AbsentDate {
  int actionId;
  String date;

  AbsentDate({required this.actionId, required this.date});

  Map<String, dynamic> toMap() {
    return {
      'actionId': actionId,
      'date': date,
    };
  }

  static AbsentDate fromMap(Map<String, dynamic> map) {
    return AbsentDate(
      actionId: map['actionId'],
      date: map['date'],
    );
  }
}
