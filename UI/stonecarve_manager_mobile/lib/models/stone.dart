class Stone {
  int? id;
  String? name;
  String? type;
  String? origin;
  String? color;
  double? hardness;
  double? density;
  String? description;
  double? pricePerUnit;
  int? availableQuantity;
  String? unit;

  Stone({
    this.id,
    this.name,
    this.type,
    this.origin,
    this.color,
    this.hardness,
    this.density,
    this.description,
    this.pricePerUnit,
    this.availableQuantity,
    this.unit,
  });

  Stone.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    type = json['type'];
    origin = json['origin'];
    color = json['color'];
    hardness = json['hardness']?.toDouble();
    density = json['density']?.toDouble();
    description = json['description'];
    pricePerUnit = json['pricePerUnit']?.toDouble();
    availableQuantity = json['availableQuantity'];
    unit = json['unit'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'origin': origin,
      'color': color,
      'hardness': hardness,
      'density': density,
      'description': description,
      'pricePerUnit': pricePerUnit,
      'availableQuantity': availableQuantity,
      'unit': unit,
    };
  }
}
