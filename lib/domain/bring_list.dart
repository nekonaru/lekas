/// The bring list of tomorrow's classes, design section 5.32: the evening
/// wrap-up mentions what to pack, but only for courses that actually have a
/// class tomorrow and only when their list has anything on it.
library;

/// How many item titles the notification shows before it stops naming them.
const int kBringLineMaxItems = 5;

/// Picks the titles for the "Besok bawa: ..." line from the per course
/// lists in the order the courses come in, keeping at most [maxItems]
/// titles. Anything left over is reported as [hidden] so the caller can
/// say how many more there are instead of silently dropping them.
({List<String> shown, int hidden}) bringLinePlan(
  List<List<String>> itemLists, {
  int maxItems = kBringLineMaxItems,
}) {
  final shown = <String>[];
  var hidden = 0;
  for (final items in itemLists) {
    for (final item in items) {
      if (shown.length < maxItems) {
        shown.add(item);
      } else {
        hidden++;
      }
    }
  }
  return (shown: shown, hidden: hidden);
}
