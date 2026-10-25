import 'dart:math';
import '../core/scoring_config.dart';

/// Menghitung skor urgensi tugas untuk pengurutan dalam bagian layar Hari Ini.
/// Skor dihitung saat ditampilkan, tidak disimpan di database.
///
/// Rumus dasar:
///   Skor = (U x uw) + P + (B x bw) + (T x tFactor)
///
///   U = 100 x e^(-jam_tersisa / 48)        (maks 100)
///   P = rendah 0 | sedang 10 | tinggi 25
///   B = bobot_persen x 0.6                  (maks sekitar 30)
///   T = estimasi_jam / jam_efektif_tersisa  (dibatasi 0 sampai 2)
///
/// Penyesuaian dari fitur tambahan:
/// - Jadwal kuliah diisi: jam kuliah dikurangkan dari jam efektif
/// - Subtugas ada: estimasi sisa waktu untuk T dikurangi sesuai persentase selesai
/// - Target pribadi ada: komponen U dihitung dari target selesai, bukan deadline resmi
/// - Bobot komponen diisi: komponen B memakai bobot efektif
/// - Tugas menunggu tugas lain: tidak ikut diurutkan (bagian Menunggu)

double urgencyScore({
  required DateTime now,
  DateTime? deadline,
  DateTime? targetAt,
  required int priority, // 0 low 1 med 2 high
  double? weightPercent,
  int? estimateMinutes,
  int? remainingEstimateMinutes,
  int? effectiveHoursAvailable, // jam efektif tersisa (dari jadwal kuliah, dll.)
  double? subtaskProgress, // 0.0 sampai 1.0
  bool useTargetForUrgency = false,
  double? effectiveWeightPercent, // bobot efektif dari 5.18
}) {
  // Tugas tanpa deadline dan tanpa target: skor 0
  if (deadline == null && targetAt == null) return 0;

  // Tentukan waktu referensi untuk komponen U (deadline atau target)
  final referenceTime = useTargetForUrgency && targetAt != null ? targetAt : deadline;
  if (referenceTime == null) return 0;

  final hoursLeft = referenceTime.difference(now).inMinutes / 60.0;
  if (hoursLeft <= 0) return 0; // terlambat dipakai bagian Terlambat terpisah

  final u = 100 * exp(-hoursLeft / 48);

  final p = priority == 0
      ? ScoringConfig.pLow
      : priority == 1
          ? ScoringConfig.pMed
          : ScoringConfig.pHigh;

  // Komponen B: bobot efektif bila tersedia, bobot manual bila tidak
  final b = (effectiveWeightPercent ?? weightPercent ?? 0) * ScoringConfig.bFactor;

  double t = 0;
  if (estimateMinutes != null && estimateMinutes > 0) {
    // Jika ada subtugas, kurangi estimasi sisa waktu sesuai progres
    final effectiveEstimate = estimateMinutes;
    final remaining = remainingEstimateMinutes ?? effectiveEstimate;
    final remainingAfterProgress = subtaskProgress != null
        ? remaining * (1 - subtaskProgress.clamp(0.0, 1.0))
        : remaining.toDouble();

    final remainingHours = remainingAfterProgress / 60.0;
    final effectiveLeft = (effectiveHoursAvailable ?? max(hoursLeft, 1.0)) *
        ScoringConfig.effectiveHoursPerDay / 24.0;
    final ratio = effectiveLeft <= 0 ? 2.0 : remainingHours / effectiveLeft;
    t = ratio.clamp(0.0, 2.0);
  }

  final uw = ScoringConfig.prioritizeDeadline ? 0.5 : 0.3;
  final bw = ScoringConfig.prioritizeDeadline ? 0.6 : 0.8;
  return (u * uw) + p + (b * bw) + (t * ScoringConfig.tFactor);
}

/// Kembalikan bagian layar tempat tugas seharusnya tampil berdasarkan status dan kondisi.
enum TaskSection { today, overdue, doing, upcoming, thisWeek, waiting, someday, inbox }

TaskSection classifySection({
  required DateTime now,
  DateTime? deadline,
  DateTime? targetAt,
  required String status,
  bool isOverdue = false,
  bool isWaiting = false,
  bool isPinned = false,
}) {
  if (status == 'doing') return TaskSection.doing;
  if (isPinned) return TaskSection.today; // pin muncul di bagian atas
  if (isOverdue) return TaskSection.overdue;
  if (deadline == null && targetAt == null) return TaskSection.someday;
  if (isWaiting) return TaskSection.waiting;

  final reference = targetAt ?? deadline;
  if (reference == null) return TaskSection.someday;

  final daysLeft = reference.difference(now).inDays;
  if (daysLeft <= 1) return TaskSection.today;
  if (daysLeft <= 7) return TaskSection.thisWeek;
  return TaskSection.upcoming;
}
