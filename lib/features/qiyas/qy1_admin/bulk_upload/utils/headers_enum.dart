enum HeadersEnum {
  scope,
  orders,
  evidence,
  appRequirements,
  goals,
  criterionName,
  criterionNumber,
  description,
  topicName,
  topicNumber,
  visionName;

  static List<HeadersEnum> get shownHeaders {
    return HeadersEnum.values.reversed.toList();
  }
}
