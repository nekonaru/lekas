package com.lekas.lekas

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONArray
import org.json.JSONObject

/**
 * Shared behaviour of the four home screen widgets (design section 7.8).
 * Flutter writes the payloads under [dataKey], this class draws them and
 * wires the two click targets every widget has: the body opens the app,
 * the add button opens quick add.
 */
abstract class LekasWidgetProvider(
    private val layoutId: Int,
    private val dataKey: String,
) : HomeWidgetProvider() {

    protected abstract val titleRes: Int

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        val payload = widgetData.getString(dataKey, null)
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, layoutId).apply {
                setTextViewText(R.id.widget_title, context.getString(titleRes))
                setOnClickPendingIntent(
                    R.id.widget_container,
                    HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java),
                )
                setOnClickPendingIntent(
                    R.id.widget_add,
                    HomeWidgetLaunchIntent.getActivity(
                        context,
                        MainActivity::class.java,
                        Uri.parse("lekas://quickadd"),
                    ),
                )
                fill(context, this, payload)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    /** Draws the payload into [views]. */
    protected abstract fun fill(context: Context, views: RemoteViews, payload: String?)

    /** Rows of a payload, empty when Flutter wrote nothing usable. */
    protected fun rows(payload: String?): List<JSONObject> {
        if (payload.isNullOrEmpty()) return emptyList()
        return try {
            val array = JSONArray(payload)
            (0 until array.length()).map { array.getJSONObject(it) }
        } catch (error: Exception) {
            emptyList()
        }
    }

    /** A row whose checkbox toggles the task straight from the launcher. */
    protected fun addTaskRow(context: Context, views: RemoteViews, row: JSONObject) {
        val item = RemoteViews(context.packageName, R.layout.widget_row).apply {
            setTextViewText(R.id.row_text, row.optString("title"))
            setImageViewResource(
                R.id.row_check,
                if (row.optBoolean("done")) {
                    R.drawable.widget_check_on
                } else {
                    R.drawable.widget_check_off
                },
            )
            setOnClickPendingIntent(
                R.id.row_check,
                HomeWidgetBackgroundIntent.getBroadcast(
                    context,
                    Uri.parse("lekas://toggle?id=${Uri.encode(row.optString("id"))}"),
                ),
            )
        }
        views.addView(R.id.widget_rows, item)
    }

    /** A row without a checkbox, used by the classes widget. */
    protected fun addPlainRow(context: Context, views: RemoteViews, text: String) {
        val item = RemoteViews(context.packageName, R.layout.widget_row).apply {
            setTextViewText(R.id.row_text, text)
            setViewVisibility(R.id.row_check, View.GONE)
        }
        views.addView(R.id.widget_rows, item)
    }

    /** Swaps between the empty text and a filled list. */
    protected fun showEmpty(context: Context, views: RemoteViews, emptyRes: Int) {
        views.setViewVisibility(R.id.widget_empty, View.VISIBLE)
        views.setTextViewText(R.id.widget_empty, context.getString(emptyRes))
    }
}

/** Three to six open tasks with a checkbox each (design section 7.8). */
class TaskListWidgetProvider :
    LekasWidgetProvider(R.layout.widget_list, "widget_tasks") {

    override val titleRes = R.string.widget_tasks_title

    override fun fill(context: Context, views: RemoteViews, payload: String?) {
        val items = rows(payload)
        if (items.isEmpty()) {
            showEmpty(context, views, R.string.widget_empty_tasks)
            return
        }
        items.forEach { addTaskRow(context, views, it) }
    }
}

/** Today's classes with their time and room (design section 7.8). */
class ClassWidgetProvider : LekasWidgetProvider(R.layout.widget_list, "widget_classes") {

    override val titleRes = R.string.widget_classes_title

    override fun fill(context: Context, views: RemoteViews, payload: String?) {
        val items = rows(payload)
        if (items.isEmpty()) {
            showEmpty(context, views, R.string.widget_empty_classes)
            return
        }
        items.forEach { row ->
            val time = row.optString("time")
            val course = row.optString("course")
            val room = row.optString("room")
            val text = if (room.isEmpty()) {
                "$time $course"
            } else {
                "$time $course ($room)"
            }
            addPlainRow(context, views, text)
        }
    }
}

/** The focus of today with its checkboxes (design sections 5.24 and 7.8). */
class FocusWidgetProvider : LekasWidgetProvider(R.layout.widget_list, "widget_focus") {

    override val titleRes = R.string.widget_focus_title

    override fun fill(context: Context, views: RemoteViews, payload: String?) {
        val items = rows(payload)
        if (items.isEmpty()) {
            showEmpty(context, views, R.string.widget_empty_focus)
            return
        }
        items.forEach { addTaskRow(context, views, it) }
    }
}

/** Days until the nearest deadline (design section 7.8). */
class ExamWidgetProvider : LekasWidgetProvider(R.layout.widget_exam, "widget_exam") {

    override val titleRes = R.string.widget_exam_title

    override fun fill(context: Context, views: RemoteViews, payload: String?) {
        // Unlike the other three, this payload is a single object.
        val exam = if (payload.isNullOrEmpty()) null else try {
            JSONObject(payload)
        } catch (error: Exception) {
            null
        }
        if (exam == null) {
            views.setTextViewText(R.id.widget_exam_days, "")
            views.setTextViewText(R.id.widget_exam_caption, context.getString(R.string.widget_empty_exam))
            return
        }
        views.setTextViewText(
            R.id.widget_exam_days,
            context.getString(R.string.widget_exam_days, exam.optInt("days")),
        )
        val course = exam.optString("course")
        val title = exam.optString("title")
        views.setTextViewText(
            R.id.widget_exam_caption,
            if (course.isEmpty()) title else "$course: $title",
        )
    }
}
