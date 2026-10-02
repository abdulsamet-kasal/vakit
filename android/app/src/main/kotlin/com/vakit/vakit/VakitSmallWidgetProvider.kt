package com.vakit.vakit

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.os.Bundle
import es.antonborri.home_widget.HomeWidgetProvider

class VakitSmallWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (appWidgetId in appWidgetIds) {
            VakitWidgetHelper.updateSmallWidget(context, appWidgetManager, appWidgetId, widgetData)
        }
        VakitWidgetHelper.scheduleNextAlarm(context, widgetData)
    }

    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: Bundle?
    ) {
        super.onAppWidgetOptionsChanged(context, appWidgetManager, appWidgetId, newOptions)
        val prefs = VakitWidgetHelper.getPrefs(context)
        VakitWidgetHelper.updateSmallWidget(context, appWidgetManager, appWidgetId, prefs)
    }
}
