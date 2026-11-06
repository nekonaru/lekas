# Release shrinker (R8) rules for Lekas.
#
# The app does not use WorkManager directly, but a transitive Android
# dependency pulls it in and androidx.startup initializes it before the
# first frame. Room creates WorkDatabase through reflection on a generated
# Impl class, which R8 strips by name: without these keeps the app dies in
# WorkManagerInitializer before anything renders (crash seen on real
# devices with release APKs, while debug builds never touch R8).

# Room instantiates generated database implementations reflectively.
-keep class * extends androidx.room.RoomDatabase {
    <init>();
}
-keep class androidx.work.impl.WorkDatabase { *; }
-keep class androidx.work.impl.WorkDatabase_Impl { *; }

# Workers referenced only through configuration or reflection.
-keep class * extends androidx.work.ListenableWorker { *; }
-keep class * extends androidx.work.CoroutineWorker { *; }

# WorkManager keeps its own default rules too; these only add the
# database and worker guarantees the release crash pointed at.
