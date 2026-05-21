package com.mahdaly.my_task

import es.antonborri.home_widget.HomeWidgetPlugin
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.widget.RemoteViews
import android.widget.RemoteViewsService
import org.json.JSONArray

class TaskWidgetService : RemoteViewsService() {
    override fun onGetViewFactory(intent: Intent): RemoteViewsFactory {
        return TaskRemoteViewsFactory(this.applicationContext)
    }
}

class TaskRemoteViewsFactory(private val context: Context) : RemoteViewsService.RemoteViewsFactory {

    private val tasksList = mutableListOf<Map<String, String>>()

    override fun onCreate() {}

override fun onDataSetChanged() {
        tasksList.clear()
        
        val widgetData = HomeWidgetPlugin.getData(context)
        val tasksJsonString = widgetData.getString("tasks_data", "[]")

        try {
            val jsonArray = JSONArray(tasksJsonString)
            for (i in 0 until jsonArray.length()) {
                val item = jsonArray.getJSONObject(i)
                tasksList.add(mapOf(
                    "id" to item.getString("id"),
                    "title" to item.getString("title")
                ))
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    override fun onDestroy() {
        tasksList.clear()
    }

    override fun getCount(): Int = tasksList.size

override fun getViewAt(position: Int): RemoteViews {
        if (position >= tasksList.size) return RemoteViews(context.packageName, R.layout.widget_task_item)

        val task = tasksList[position]
        val views = RemoteViews(context.packageName, R.layout.widget_task_item)
        
        views.setTextViewText(R.id.task_item_title, task["title"])

        val fillInIntent = Intent().apply {
            data = Uri.parse("mywidget://completetask?id=${task["id"]}")
        }
        
       

        return views
    }

    override fun getLoadingView(): RemoteViews? = null
    override fun getViewTypeCount(): Int = 1
    override fun getItemId(position: Int): Long = position.toLong()
    override fun hasStableIds(): Boolean = true
}