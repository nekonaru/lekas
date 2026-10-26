package com.lekas.lekas;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Handler;
import android.os.Looper;

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
 */
public class BootReceiver extends BroadcastReceiver {
    private static final String CHANNEL = "lekas/boot";
    private static final long TIMEOUT_MS = 30_000L;

    @Override
    public void onReceive(Context context, Intent intent) {
        if (context == null || intent == null || intent.getAction() == null) {
            return;
        }
        String action = intent.getAction();
        boolean isBoot = Intent.ACTION_BOOT_COMPLETED.equals(action)
                || Intent.ACTION_MY_PACKAGE_REPLACED.equals(action)
                || "android.intent.action.QUICKBOOT_POWERON".equals(action)
                || "com.htc.intent.action.QUICKBOOT_POWERON".equals(action);
        if (!isBoot) {
            return;
        }

        Context appContext = context.getApplicationContext();
        FlutterLoader loader = FlutterInjector.instance().flutterLoader();
        loader.startInitialization(appContext);
        loader.ensureInitializationComplete(appContext, null);

        // Keeps the process alive until the background engine reports back.
        final PendingResult pendingResult = goAsync();
        final FlutterEngine engine = new FlutterEngine(appContext);
        LekasPlatformChannel.register(appContext, engine.getDartExecutor().getBinaryMessenger());

        final Handler handler = new Handler(Looper.getMainLooper());
        final boolean[] finished = new boolean[]{false};
        final Runnable timeout = () -> {
            if (!finished[0]) {
                finished[0] = true;
                engine.destroy();
                pendingResult.finish();
            }
        };

        MethodChannel channel =
                new MethodChannel(engine.getDartExecutor().getBinaryMessenger(), CHANNEL);
        channel.setMethodCallHandler((call, result) -> {
            if ("done".equals(call.method)) {
                result.success(null);
                if (!finished[0]) {
                    finished[0] = true;
                    handler.removeCallbacks(timeout);
                    engine.destroy();
                    pendingResult.finish();
                }
            } else {
                result.notImplemented();
            }
        });

        handler.postDelayed(timeout, TIMEOUT_MS);
        engine.getDartExecutor().executeDartEntrypoint(
                new DartExecutor.DartEntrypoint(loader.findAppBundlePath(), "reminderBoot"));
    }
}
