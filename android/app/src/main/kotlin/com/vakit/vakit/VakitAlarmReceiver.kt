package com.vakit.vakit

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class VakitAlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        VakitWidgetHelper.updateAllWidgets(context)
    }
}
