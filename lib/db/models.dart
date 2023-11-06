class Action {
  int? id;
  String name;
  double payPerMonth;

  Action({this.id, required this.name, required this.payPerMonth});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'payPerMonth': payPerMonth,
    };
  }
}

class AbsentDate {
  int? id;
  int actionId;
  String date;

  AbsentDate({this.id, required this.actionId, required this.date});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'actionId': actionId,
      'date': date,
    };
  }
}
