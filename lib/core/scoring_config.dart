class ScoringConfig {
  static const double uWeight = 0.5;
  static const double pLow = 0;
  static const double pMed = 10;
  static const double pHigh = 25;
  static const double bFactor = 0.6;
  static const double tFactor = 20;
  static const int effectiveHoursPerDay = 10;
  static const int sleepStartHour = 23;
  static const int sleepEndHour = 6;
  static const bool prioritizeDeadline = true; // true=deadline, false=grade
}