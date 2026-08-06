class CardProgressIndicator {
  CardProgressIndicator({
    this.progressPercentage,
    this.colors,
  });

  CardProgressIndicator.fromJson(dynamic json) {
    progressPercentage = json['Progress_Percentage'] != null
        ? json['Progress_Percentage'].cast<String>()
        : [];
    colors = json['Colors'] != null ? json['Colors'].cast<String>() : [];
  }

  List<String>? progressPercentage;
  List<String>? colors;

  CardProgressIndicator copyWith({
    List<String>? progressPercentage,
    List<String>? colors,
  }) =>
      CardProgressIndicator(
        progressPercentage: progressPercentage ?? this.progressPercentage,
        colors: colors ?? this.colors,
      );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Progress_Percentage'] = progressPercentage;
    map['Colors'] = colors;
    return map;
  }
}
