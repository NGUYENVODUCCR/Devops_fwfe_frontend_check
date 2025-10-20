class Report {
  final int id;
  final String reason;
  final String reportedAt;
  final bool resolved;
  final int reporterId;
  final String reporterUsername;
  final int reportedId;
  final String reportedUsername;

  Report({
    required this.id,
    required this.reason,
    required this.reportedAt,
    required this.resolved,
    required this.reporterId,
    required this.reporterUsername,
    required this.reportedId,
    required this.reportedUsername,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'],
      reason: json['reason'],
      reportedAt: json['reportedAt'],
      resolved: json['resolved'],
      reporterId: json['reporterId'],
      reporterUsername: json['reporterUsername'],
      reportedId: json['reportedId'],
      reportedUsername: json['reportedUsername'],
    );
  }
}
