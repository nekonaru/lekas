package com.lekas.lekas;

import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import android.os.Build;
import android.provider.DocumentsContract;

import androidx.annotation.NonNull;
import androidx.documentfile.provider.DocumentFile;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

/**
 * Files of one course inside a folder the user picks once (the Storage
 * Access Framework), so modules, notes and archives live in the phone's own
 * storage and are reachable with any file manager instead of being locked
 * inside the app. The channel is synchronous-ish: every method either
 * answers inline or routes through the pending pick result.
 */
public final class LekasFileChannel implements MethodChannel.MethodCallHandler {
    public static final String NAME = "lekas/files";
    private static final int REQUEST_PICK_TREE = 6101;

    private final Activity activity;
    private final MethodChannel channel;

    private String lastError;
    private MethodChannel.Result pickResult;

    private LekasFileChannel(Activity activity, MethodChannel channel) {
        this.activity = activity;
        this.channel = channel;
    }

    public static void register(Activity activity, BinaryMessenger messenger) {
        MethodChannel channel = new MethodChannel(messenger, NAME);
        LekasFileChannel handler = new LekasFileChannel(activity, channel);
        channel.setMethodCallHandler(handler);
        instance = handler;
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        String method = call.method;
        switch (method) {
            case "pickTree":
                if (pickResult != null) {
                    result.error("busy", "A folder picker is already open.", null);
                    return;
                }
                pickResult = result;
                openTreePicker();
                break;
            case "ensureFolder": {
                String treeUri = call.argument("treeUri");
                String[] segments = asStringArray(call.argument("segments"));
                result.success(ensureFolder(treeUri, segments));
                break;
            }
            case "listFolder": {
                String treeUri = call.argument("treeUri");
                String[] segments = asStringArray(call.argument("segments"));
                result.success(listFolder(treeUri, segments));
                break;
            }
            case "createFolder": {
                String treeUri = call.argument("treeUri");
                String[] segments = asStringArray(call.argument("segments"));
                String name = call.argument("name");
                result.success(createFolder(treeUri, segments, name));
                break;
            }
            case "importFile": {
                String treeUri = call.argument("treeUri");
                String[] segments = asStringArray(call.argument("segments"));
                String displayName = call.argument("displayName");
                String sourcePath = call.argument("sourcePath");
                result.success(importFile(treeUri, segments, displayName, sourcePath));
                break;
            }
            case "deleteEntry": {
                String treeUri = call.argument("treeUri");
                String[] segments = asStringArray(call.argument("segments"));
                String name = call.argument("name");
                result.success(deleteEntry(treeUri, segments, name));
                break;
            }
            case "renameEntry": {
                String treeUri = call.argument("treeUri");
                String[] segments = asStringArray(call.argument("segments"));
                String name = call.argument("name");
                String newName = call.argument("newName");
                result.success(renameEntry(treeUri, segments, name, newName));
                break;
            }
            case "openEntry": {
                String treeUri = call.argument("treeUri");
                String[] segments = asStringArray(call.argument("segments"));
                String name = call.argument("name");
                result.success(openEntry(treeUri, segments, name));
                break;
            }
            case "lastError":
                result.success(lastError);
                break;
            default:
                result.notImplemented();
        }
    }

    /** Called from MainActivity.onActivityResult for the tree picker. */
    public static void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (requestCode != REQUEST_PICK_TREE) return;
        // The handler lives behind the static registration; MainActivity
        // forwards the picker result to it.
        LekasFileChannel self = instance;
        if (self != null) {
            self.finishPick(resultCode, data);
        }
    }

    private static LekasFileChannel instance;

    private void openTreePicker() {
        lastError = null;
        Intent intent = new Intent(Intent.ACTION_OPEN_DOCUMENT_TREE);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            // Land the picker on Documents when possible so the user picks
            // one folder under it instead of wandering the whole phone.
            Uri suggested = DocumentsContract.buildDocumentUriUsingTree(
                    DocumentsContract.EXTERNAL_STORAGE_PRIMARY_EMULATED_DOCUMENT_URI,
                    "primary:Documents");
            intent.putExtra(Intent.EXTRA_INITIAL_URI, suggested);
        }
        try {
            activity.startActivityForResult(intent, REQUEST_PICK_TREE);
        } catch (Exception e) {
            finishPickError("Could not open the folder picker.");
        }
    }

    private void finishPick(int resultCode, Intent data) {
        MethodChannel.Result pending = pickResult;
        pickResult = null;
        if (pending == null) return;
        if (resultCode != Activity.RESULT_OK || data == null || data.getData() == null) {
            pending.success(null);
            return;
        }
        Uri treeUri = data.getData();
        int takeFlags = Intent.FLAG_GRANT_READ_URI_PERMISSION | Intent.FLAG_GRANT_WRITE_URI_PERMISSION;
        try {
            activity.getContentResolver().takePersistableUriPermission(treeUri, takeFlags);
        } catch (Exception e) {
            lastError = e.getMessage();
            pending.success(null);
            return;
        }
        pending.success(treeUri.toString());
    }

    private void finishPickError(String message) {
        lastError = message;
        MethodChannel.Result pending = pickResult;
        pickResult = null;
        if (pending != null) {
            pending.success(null);
        }
    }

    private String[] asStringArray(Object argument) {
        if (!(argument instanceof java.util.List)) return new String[0];
        java.util.List<?> raw = (java.util.List<?>) argument;
        ArrayList<String> out = new ArrayList<>();
        for (Object item : raw) {
            if (item instanceof String) out.add((String) item);
        }
        return out.toArray(new String[0]);
    }

    private DocumentFile rootOf(Uri treeUri) {
        return DocumentFile.fromTreeUri(activity, treeUri);
    }

    private DocumentFile find(DocumentFile start, String[] segments, boolean create) {
        DocumentFile current = start;
        if (current == null) return null;
        for (String segment : segments) {
            DocumentFile child = current.findFile(segment);
            if (child == null) {
                if (!create) return null;
                child = current.createDirectory(segment);
                if (child == null) return null;
            } else if (!child.isDirectory()) {
                return null;
            }
            current = child;
        }
        return current;
    }

    private boolean ensureFolder(String treeUri, String[] segments) {
        lastError = null;
        try {
            DocumentFile root = rootOf(Uri.parse(treeUri));
            DocumentFile found = find(root, segments, true);
            if (found == null) {
                lastError = "The folder could not be created.";
                return false;
            }
            return true;
        } catch (Exception e) {
            lastError = e.getMessage();
            return false;
        }
    }

    private boolean createFolder(String treeUri, String[] segments, String name) {
        lastError = null;
        try {
            DocumentFile root = rootOf(Uri.parse(treeUri));
            DocumentFile parent = find(root, segments, true);
            if (parent == null) {
                lastError = "The parent folder does not exist.";
                return false;
            }
            if (parent.findFile(name) != null) {
                lastError = "exists";
                return false;
            }
            DocumentFile child = parent.createDirectory(name);
            if (child == null) {
                lastError = "Folder could not be created.";
                return false;
            }
            return true;
        } catch (Exception e) {
            lastError = e.getMessage();
            return false;
        }
    }

    private ArrayList<Map<String, Object>> listFolder(String treeUri, String[] segments) {
        lastError = null;
        ArrayList<Map<String, Object>> rows = new ArrayList<>();
        try {
            DocumentFile root = rootOf(Uri.parse(treeUri));
            DocumentFile folder = find(root, segments, false);
            if (folder == null) {
                // Missing root reads as empty so the screen can offer to recreate.
                return rows;
            }
            for (DocumentFile child : folder.listFiles()) {
                Map<String, Object> row = new HashMap<>();
                row.put("name", child.getName());
                row.put("isDirectory", child.isDirectory());
                row.put("size", child.length());
                row.put("mime", child.getType() == null ? "" : child.getType());
                row.put("modified", child.lastModified());
                rows.add(row);
            }
            return rows;
        } catch (Exception e) {
            lastError = e.getMessage();
            return rows;
        }
    }

    private boolean importFile(String treeUri, String[] segments, String displayName, String sourcePath) {
        lastError = null;
        if (displayName == null || displayName.trim().isEmpty() || sourcePath == null) {
            lastError = "Bad arguments.";
            return false;
        }
        File source = new File(sourcePath);
        if (!source.isFile()) {
            lastError = "The picked file does not exist.";
            return false;
        }
        OutputStream out = null;
        try {
            DocumentFile root = rootOf(Uri.parse(treeUri));
            DocumentFile folder = find(root, segments, true);
            if (folder == null) {
                lastError = "The destination folder could not be created.";
                return false;
            }
            // Import replaces same-name files on purpose: re-importing an
            // updated module must not leave stale duplicates behind.
            DocumentFile existing = folder.findFile(displayName);
            if (existing != null) {
                existing.delete();
            }
            String mime = guessMime(displayName);
            DocumentFile created = folder.createFile(mime, displayName);
            if (created == null) {
                lastError = "The file could not be created.";
                return false;
            }
            out = activity.getContentResolver().openOutputStream(created.getUri());
            if (out == null) {
                lastError = "The file could not be opened for writing.";
                return false;
            }
            FileInputStream in = new FileInputStream(source);
            byte[] buffer = new byte[64 * 1024];
            int read;
            while ((read = in.read(buffer)) != -1) {
                out.write(buffer, 0, read);
            }
            in.close();
            out.close();
            return true;
        } catch (Exception e) {
            lastError = e.getMessage();
            try {
                if (out != null) out.close();
            } catch (IOException ignored) {
            }
            return false;
        }
    }

    private boolean deleteEntry(String treeUri, String[] segments, String name) {
        lastError = null;
        try {
            DocumentFile root = rootOf(Uri.parse(treeUri));
            DocumentFile folder = find(root, segments, false);
            if (folder == null) return false;
            DocumentFile child = folder.findFile(name);
            if (child == null) {
                lastError = "Not found.";
                return false;
            }
            return child.delete();
        } catch (Exception e) {
            lastError = e.getMessage();
            return false;
        }
    }

    private boolean renameEntry(String treeUri, String[] segments, String name, String newName) {
        lastError = null;
        try {
            DocumentFile root = rootOf(Uri.parse(treeUri));
            DocumentFile folder = find(root, segments, false);
            if (folder == null) return false;
            DocumentFile child = folder.findFile(name);
            if (child == null) {
                lastError = "Not found.";
                return false;
            }
            return child.renameTo(newName);
        } catch (Exception e) {
            lastError = e.getMessage();
            return false;
        }
    }

    private boolean openEntry(String treeUri, String[] segments, String name) {
        lastError = null;
        try {
            DocumentFile root = rootOf(Uri.parse(treeUri));
            DocumentFile folder = find(root, segments, false);
            if (folder == null) return false;
            DocumentFile child = folder.findFile(name);
            if (child == null || child.isDirectory()) {
                lastError = "Not found.";
                return false;
            }
            Intent intent = new Intent(Intent.ACTION_VIEW);
            String type = child.getType();
            intent.setDataAndType(child.getUri(), type == null || type.isEmpty() ? "application/octet-stream" : type);
            intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
            activity.startActivity(intent);
            return true;
        } catch (Exception e) {
            lastError = e.getMessage();
            return false;
        }
    }

    private static String guessMime(String name) {
        String lower = name.toLowerCase(Locale.US);
        int dot = lower.lastIndexOf('.');
        String ext = dot >= 0 ? lower.substring(dot + 1) : "";
        switch (ext) {
            case "pdf": return "application/pdf";
            case "png": return "image/png";
            case "jpg":
            case "jpeg": return "image/jpeg";
            case "gif": return "image/gif";
            case "webp": return "image/webp";
            case "zip": return "application/zip";
            case "rar": return "application/vnd.rar";
            case "7z": return "application/x-7z-compressed";
            case "txt": return "text/plain";
            case "md": return "text/markdown";
            case "csv": return "text/csv";
            case "doc": return "application/msword";
            case "docx": return "application/vnd.openxmlformats-officedocument.wordprocessingml.document";
            case "xls": return "application/vnd.ms-excel";
            case "xlsx": return "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
            case "ppt": return "application/vnd.ms-powerpoint";
            case "pptx": return "application/vnd.openxmlformats-officedocument.presentationml.presentation";
            case "json": return "application/json";
            case "mp3": return "audio/mpeg";
            case "mp4": return "video/mp4";
            default: return "application/octet-stream";
        }
    }

}
