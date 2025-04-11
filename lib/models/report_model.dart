class Report {
  String conductionAbnormality;
  String heartCondition;
  int heartRate;
  String hypertrophy;
  double qrsWidth;
  String rhythm;

  Report({
    required this.conductionAbnormality,
    required this.heartCondition,
    required this.heartRate,
    required this.hypertrophy,
    required this.qrsWidth,
    required this.rhythm,
  });

  // Convert JSON to Patient object
  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      conductionAbnormality: json["Conduction Abnormality"] ?? "",
      heartCondition: json["Heart Condition"] ?? "",
      heartRate: json["Heart Rate (bpm)"] ?? 0,
      hypertrophy: json["Hypertrophy"] ?? "",
      qrsWidth: (json["QRS Width (s)"] ?? 0.0).toDouble(),
      rhythm: json["Rhythm"] ?? "",
    );
  }

  // Convert Patient object to JSON
  Map<String, dynamic> toJson() {
    return {
      "Conduction Abnormality": conductionAbnormality,
      "Heart Condition": heartCondition,
      "Heart Rate (bpm)": heartRate,
      "Hypertrophy": hypertrophy,
      "QRS Width (s)": qrsWidth,
      "Rhythm": rhythm,
    };
  }
}
