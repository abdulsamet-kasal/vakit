package com.vakit.vakit

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import es.antonborri.home_widget.HomeWidgetProvider

class VakitMediumWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (appWidgetId in appWidgetIds) {
            VakitWidgetHelper.updateMediumWidget(context, appWidgetManager, appWidgetId, widgetData)
        }
        VakitWidgetHelper.scheduleNextAlarm(context, widgetData)
    }
}
