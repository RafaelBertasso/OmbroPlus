class PatientSummary {
  final String patientId;
  final String patientName;
  final String protocolId;
  final String protocolName;
  final double progressPercentage;
  final double weeklyAdherenceScore;
  final String status;

  PatientSummary({
    required this.patientId,
    required this.patientName,
    required this.protocolId,
    required this.protocolName,
    required this.progressPercentage,
    required this.weeklyAdherenceScore,
    required this.status,
  });
}
