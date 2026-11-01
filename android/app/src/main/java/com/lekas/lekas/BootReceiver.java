package com.lekas.lekas;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Handler;
import android.os.Looper;
import android.os.SystemClock;
import android.util.Log;

import io.flutter.FlutterInjector;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.dart.DartExecutor;
import io.flutter.embedding.engine.loader.FlutterLoader;
import io.flutter.plugin.common.MethodChannel;

/**
 * Re-schedules every active reminder after a reboot or an app update by
 * starting a short lived background Flutter engine running the
 * {@code reminderBoot} entry point. The engine reports back on the
 * {@code lekas/boot} channel and is destroyed either way.
 *
 * <p>Every path is guarded: this receiver runs right after an install (the
 * {@code MY_PACKAGE_REPLACED} broadcast, in the app's own process), and any
 * exception escaping {@link #onReceive} kills that process, which looks
 * exactly like the app force closing the moment it is opened. A failed
 * reminder reschedule must cost one log line, not the whole app.
 */
public class BootReceiver extends BroadcastReceiver {
    private static final String TAG = "LekasBoot";
    private static final String CHANNEL = "lekas/boot";
    private static final long TIMEOUT_MS = 30_000L;

    // Two broadcasts can arrive back to back (an update while booting),
    // and starting two background engines at once wastes the battery.
    private static final long DEBOUNCE_MS = 10_000L;
    private static volatile long lastRunAt = 0L;

    @Override
    public void onReceive(Context context, Intent intent) {
        if (context == null || intent == null || intent.getAction() == null) {
            return;
        }
        String action = intent.getAction();
        boolean isBoot = Intent.ACTION_BOOT_COMPLETED.equals(action)
                || Intent.ACTION_MY_PACKAGE_REPLACED.equals(action);
        if (!isBoot) {
            return;
        }

        long now = SystemClock.elapsedRealtime();
        if (now - lastRunAt < DEBOUNCE_MS) {
            return;
        }
        lastRunAt = now;

        Context appContext = context.getApplicationContext();
        try {
            FlutterLoader loader = FlutterInjector.instance().flutterLoader();
            loader.startInitialization(appContext);
            loader.ensureInitializationComplete(appContext, null);

            // Keeps the process alive until the background engine reports back.
            PendingResult pendingResult = goAsync();
            startReminderEngine(appContext, loader, pendingResult);
        } catch (Throwable error) {
            // Throwable on purpose: a snapshot or native library that fails
            // to load after an update surfaces as an Error, not an Exception.
            // startReminderEngine owns the pending result and does not throw,
            // so this branch only runs before goAsync or if it failed, and
            // there is no pending result to finish.
            Log.e(TAG, "Could not reschedule reminders after " + action, error);
        }
    }

    /**
     * Builds the background engine, runs the {@code reminderBoot} entry point
     * and owns {@code pendingResult}: every exit path either lets the channel
     * callbacks finish the broadcast or finishes it here, exactly once. The
     * timeout is posted last, so a failure before it can never leave a timer
     * behind that would finish the broadcast a second time.
     */
    private static void startReminderEngine(Context appContext, FlutterLoader loader,
            PendingResult pendingResult) {
        FlutterEngine engine = null;
        try {
            engine = new FlutterEngine(appContext);
            final FlutterEngine running = engine;
            LekasPlatformChannel.register(appContext,
                    running.getDartExecutor().getBinaryMessenger());

            final Handler handler = new Handler(Looper.getMainLooper());
            final boolean[] finished = new boolean[]{false};
            final Runnable timeout = () -> {
                if (!finished[0]) {
                    finished[0] = true;
                    running.destroy();
                    pendingResult.finish();
                }
            };

            MethodChannel channel =
                    new MethodChannel(running.getDartExecutor().getBinaryMessenger(), CHANNEL);
            channel.setMethodCallHandler((call, result) -> {
                if ("done".equals(call.method)) {
                    result.success(null);
                    if (!finished[0]) {
                        finished[0] = true;
                        handler.removeCallbacks(timeout);
                        running.destroy();
                        pendingResult.finish();
                    }
                } else {
                    result.notImplemented();
                }
            });

            running.getDartExecutor().executeDartEntrypoint(
                    new DartExecutor.DartEntrypoint(loader.findAppBundlePath(), "reminderBoot"));
            handler.postDelayed(timeout, TIMEOUT_MS);
        } catch (Throwable error) {
            Log.e(TAG, "Background reminder engine failed to start", error);
            if (engine != null) {
                engine.destroy();
            }
            pendingResult.finish();
        }
    }
}
