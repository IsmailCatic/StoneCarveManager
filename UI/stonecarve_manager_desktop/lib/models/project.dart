class Project {
  int? id;
  String? name;
  String? description;
  DateTime? startDate;
  DateTime? endDate;
  String? status;
  String? clientName;
  double? budget;
  int? stoneId;

  Project({
    this.id,
    this.name,
    this.description,
    this.startDate,
    this.endDate,
    this.status,
    this.clientName,
    this.budget,
    this.stoneId,
  });

  Project.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    startDate = json['startDate'] != null
        ? DateTime.parse(json['startDate'])
        : null;
    endDate = json['endDate'] != null ? DateTime.parse(json['endDate']) : null;
    status = json['status'];
    clientName = json['clientName'];
    budget = json['budget']?.toDouble();
    stoneId = json['stoneId'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'status': status,
      'clientName': clientName,
      'budget': budget,
      'stoneId': stoneId,
    };
  }
}
