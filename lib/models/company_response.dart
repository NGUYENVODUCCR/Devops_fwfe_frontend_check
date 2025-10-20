class CompanyResponse {
  final int id;
  final String name;
  final String descriptionCompany;
  final String type;
  final String address;
  final bool isPublic;
  final int createdById;
  final String createdByUsername;

  CompanyResponse({
    required this.id,
    required this.name,
    required this.descriptionCompany,
    required this.type,
    required this.address,
    required this.isPublic,
    required this.createdById,
    required this.createdByUsername,
  });

  factory CompanyResponse.fromJson(Map<String, dynamic> json) {
    return CompanyResponse(
      id: json['id'],
      name: json['name'],
      descriptionCompany: json['descriptionCompany'],
      type: json['type'],
      address: json['address'],
      isPublic: json['isPublic'],
      createdById: json['createdById'],
      createdByUsername: json['createdByUsername'],
    );
  }
}
