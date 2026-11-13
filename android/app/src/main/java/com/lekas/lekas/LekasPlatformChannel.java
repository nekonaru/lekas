package com.lekas.lekas;

import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Build;
import android.provider.Settings;

import java.util.TimeZone;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

/**
 * Small platform channel for things that need no plugin: the device time zone
 * id (used to schedule reminders), the system screens for notification and
 * battery settings (used by the reminder check screen) and the https-only web
 * link for the update checker.
 */
public final class LekasPlatformChannel implements MethodChannel.MethodCallHandler {
    public static final String NAME = "lekas/platform";

    private final Context context;
    private final MethodChannel channel;

    private LekasPlatformChannel(Context context, MethodChannel channel) {
        this.context = context;
        this.channel = channel;
    }

    public static void register(Context context, BinaryMessenger messenger) {
        MethodChannel channel = new MethodChannel(messenger, NAME);
        channel.setMethodCallHandler(new LekasPlatformChannel(context.getApplicationContext(), channel));
    }

    @Override
    public void onMethodCall(MethodCall call, MethodChannel.Result result) {
        String method = call.method;
        if ("getID".equals(method)) {
            result.success(TimeZone.getDefault().getID());
        } else if ("openNotificationSettings".equals(method)) {
            openNotificationSettings();
            result.success(null);
        } else if ("openBatterySettings".equals(method)) {
            openBatterySettings();
            result.success(null);
        } else if ("openUrl".equals(method)) {
            Object arguments = call.arguments;
            openUrl(arguments instanceof String ? (String) arguments : "");
            result.success(null);
        } else {
            result.notImplemented();
        }
    }

    private void openNotificationSettings() {
        Intent intent;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            intent = new Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS)
                    .putExtra(Settings.EXTRA_APP_PACKAGE, context.getPackageName());
        } else {
            intent = new Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
                    Uri.parse("package:" + context.getPackageName()));
        }
        startSafely(intent);
    }

    private void openBatterySettings() {
        // The battery saver list needs no permission to open.
        startSafely(new Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS));
    }

    private void openUrl(String url) {
        // Update links open in the browser; https only, so a crafted string
        // cannot pivot into another scheme.
        Uri uri;
        try {
            uri = Uri.parse(url);
        } catch (Exception ignored) {
            return;
        }
        String scheme = uri.getScheme();
        if (scheme == null || !scheme.equalsIgnoreCase("https")) return;
        startSafely(new Intent(Intent.ACTION_VIEW, uri));
    }

    private void startSafely(Intent intent) {
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        try {
            context.startActivity(intent);
        } catch (Exception ignored) {
            // Some vendors remove these screens; the caller shows a guide instead.
        }
    }
}
