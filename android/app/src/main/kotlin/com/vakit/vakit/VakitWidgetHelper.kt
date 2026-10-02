package com.vakit.vakit

import android.app.AlarmManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.net.Uri
import android.os.Build
import android.os.SystemClock
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetPlugin
import org.json.JSONArray
import org.json.JSONObject
import java.util.Calendar

object VakitWidgetHelper {

    private const val PREFS_FLUTTER = "FlutterSharedPreferences"
    private const val PREFS_HOME_WIDGET = "HomeWidgetPreferences"

    fun getPrefs(context: Context): SharedPreferences {
        return try {
            HomeWidgetPlugin.getData(context)
        } catch (_: Exception) {
            context.getSharedPreferences(PREFS_HOME_WIDGET, Context.MODE_PRIVATE)
        }
    }

    private fun getStringValue(context: Context, prefs: SharedPreferences, key: String, defaultVal: String): String {
        val v1 = prefs.getString(key, null)
        if (!v1.isNullOrEmpty()) return v1

        val hwPrefs = context.getSharedPreferences(PREFS_HOME_WIDGET, Context.MODE_PRIVATE)
        val v2 = hwPrefs.getString(key, null)
        if (!v2.isNullOrEmpty()) return v2

        val fltPrefs = context.getSharedPreferences(PREFS_FLUTTER, Context.MODE_PRIVATE)
        val v3 = fltPrefs.getString("flutter.$key", null) ?: fltPrefs.getString(key, null)
        if (!v3.isNullOrEmpty()) return v3

        return defaultVal
    }

    fun getLaunchPendingIntent(context: Context, uriStr: String, requestCode: Int): PendingIntent {
        val intent = Intent(context, MainActivity::class.java).apply {
            action = HomeWidgetLaunchIntent.HOME_WIDGET_LAUNCH_ACTION
            data = Uri.parse(uriStr)
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        } else {
            PendingIntent.FLAG_UPDATE_CURRENT
        }
        return PendingIntent.getActivity(context, requestCode, intent, flags)
    }

    data class PrayerEvent(
        val name: String,
        val epochMs: Long,
        val timeStr: String,
    )

    data class DayData(
        val dateStr: String,
        val events: List<PrayerEvent>,
        val kerahatMorningEnd: Long,
        val kerahatMiddayStart: Long,
        val kerahatMiddayEnd: Long,
        val kerahatEveningStart: Long,
        val kerahatEveningEnd: Long,
    )

    fun parsePrayerData(context: Context, prefs: SharedPreferences): List<DayData> {
        val jsonStr = getStringValue(context, prefs, "days_prayer_json", "")
        if (jsonStr.isEmpty()) return emptyList()

        val result = mutableListOf<DayData>()
        try {
            val array = JSONArray(jsonStr)
            for (i in 0 until array.length()) {
                val dayObj = array.getJSONObject(i)
                val dateStr = dayObj.optString("dateStr", "")
                val timesObj = dayObj.optJSONObject("times") ?: JSONObject()
                val kerahatObj = dayObj.optJSONObject("kerahat") ?: JSONObject()

                val events = listOf(
                    PrayerEvent("İmsak", timesObj.optJSONObject("imsak")?.optLong("epochMs") ?: 0L, timesObj.optJSONObject("imsak")?.optString("timeStr") ?: ""),
                    PrayerEvent("Güneş", timesObj.optJSONObject("gunes")?.optLong("epochMs") ?: 0L, timesObj.optJSONObject("gunes")?.optString("timeStr") ?: ""),
                    PrayerEvent("Öğle", timesObj.optJSONObject("ogle")?.optLong("epochMs") ?: 0L, timesObj.optJSONObject("ogle")?.optString("timeStr") ?: ""),
                    PrayerEvent("İkindi", timesObj.optJSONObject("ikindi")?.optLong("epochMs") ?: 0L, timesObj.optJSONObject("ikindi")?.optString("timeStr") ?: ""),
                    PrayerEvent("Akşam", timesObj.optJSONObject("aksam")?.optLong("epochMs") ?: 0L, timesObj.optJSONObject("aksam")?.optString("timeStr") ?: ""),
                    PrayerEvent("Yatsı", timesObj.optJSONObject("yatsi")?.optLong("epochMs") ?: 0L, timesObj.optJSONObject("yatsi")?.optString("timeStr") ?: "")
                )

                result.add(
                    DayData(
                        dateStr = dateStr,
                        events = events,
                        kerahatMorningEnd = kerahatObj.optLong("morning_end", 0L),
                        kerahatMiddayStart = kerahatObj.optLong("midday_start", 0L),
                        kerahatMiddayEnd = kerahatObj.optLong("midday_end", 0L),
                        kerahatEveningStart = kerahatObj.optLong("evening_start", 0L),
                        kerahatEveningEnd = kerahatObj.optLong("evening_end", 0L)
                    )
                )
            }
        } catch (_: Exception) {
            // Json parse fallback
        }
        return result
    }

    fun findTodayDayData(days: List<DayData>): DayData? {
        if (days.isEmpty()) return null
        val calNow = Calendar.getInstance()
        val match = days.firstOrNull { d ->
            val imsakMs = d.events.firstOrNull()?.epochMs ?: 0L
            if (imsakMs <= 0L) return@firstOrNull false
            val calDay = Calendar.getInstance().apply { timeInMillis = imsakMs }
            calNow.get(Calendar.YEAR) == calDay.get(Calendar.YEAR) &&
                    calNow.get(Calendar.DAY_OF_YEAR) == calDay.get(Calendar.DAY_OF_YEAR)
        }
        return match ?: days.firstOrNull()
    }

    fun isKerahatActive(now: Long, dayData: DayData?): Boolean {
        if (dayData == null) return false
        val morningStart = dayData.events.find { it.name == "Güneş" }?.epochMs ?: 0L
        val morningActive = now in morningStart until dayData.kerahatMorningEnd
        val middayActive = now in dayData.kerahatMiddayStart until dayData.kerahatMiddayEnd
        val eveningActive = now in dayData.kerahatEveningStart until dayData.kerahatEveningEnd
        return morningActive || middayActive || eveningActive
    }

    fun updateSmallWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        prefs: SharedPreferences
    ) {
        val views = RemoteViews(context.packageName, R.layout.widget_small)
        val cityName = getStringValue(context, prefs, "city_name", "İstanbul")
        val days = parsePrayerData(context, prefs)
        val now = System.currentTimeMillis()

        var nextEvent: PrayerEvent? = null
        val todayDay = findTodayDayData(days)
        val isKerahat = isKerahatActive(now, todayDay)

        if (days.isNotEmpty()) {
            val allEvents = days.flatMap { it.events }.filter { it.epochMs > 0 }
            nextEvent = allEvents.firstOrNull { it.epochMs > now }
        }

        views.setTextViewText(R.id.tv_city, cityName)

        if (nextEvent != null) {
            views.setTextViewText(R.id.tv_prayer_name, nextEvent.name)
            views.setTextViewText(R.id.tv_prayer_time, "Ezan: ${nextEvent.timeStr}")
            val deltaMs = nextEvent.epochMs - now
            val chronometerBase = SystemClock.elapsedRealtime() + deltaMs
            views.setChronometer(R.id.widget_chronometer, chronometerBase, null, true)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                views.setChronometerCountDown(R.id.widget_chronometer, true)
            }
        } else {
            views.setTextViewText(R.id.tv_prayer_name, "Vakit")
            views.setTextViewText(R.id.tv_prayer_time, "--:--")
        }

        views.setViewVisibility(
            R.id.tv_kerahat_badge,
            if (isKerahat) View.VISIBLE else View.GONE
        )

        // Tıklayınca Vakitler ekranına git
        val pendingIntent = getLaunchPendingIntent(context, "vakit://vakitler", 101)
        views.setOnClickPendingIntent(R.id.widget_small_root, pendingIntent)

        appWidgetManager.updateAppWidget(appWidgetId, views)
    }

    fun updateMediumWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        prefs: SharedPreferences
    ) {
        val views = RemoteViews(context.packageName, R.layout.widget_medium)
        val cityName = getStringValue(context, prefs, "city_name", "İstanbul")
        val days = parsePrayerData(context, prefs)
        val now = System.currentTimeMillis()

        views.setTextViewText(R.id.tv_medium_city, cityName)

        val day = findTodayDayData(days)
        val bars = listOf(
            R.id.bar_imsak, R.id.bar_gunes, R.id.bar_ogle,
            R.id.bar_ikindi, R.id.bar_aksam, R.id.bar_yatsi
        )
        bars.forEach { views.setViewVisibility(it, View.INVISIBLE) }

        if (day != null) {
            views.setTextViewText(R.id.tv_medium_date, day.dateStr)

            val imsak = day.events.getOrNull(0)
            val gunes = day.events.getOrNull(1)
            val ogle = day.events.getOrNull(2)
            val ikindi = day.events.getOrNull(3)
            val aksam = day.events.getOrNull(4)
            val yatsi = day.events.getOrNull(5)

            views.setTextViewText(R.id.val_imsak, imsak?.timeStr ?: "--:--")
            views.setTextViewText(R.id.val_gunes, gunes?.timeStr ?: "--:--")
            views.setTextViewText(R.id.val_ogle, ogle?.timeStr ?: "--:--")
            views.setTextViewText(R.id.val_ikindi, ikindi?.timeStr ?: "--:--")
            views.setTextViewText(R.id.val_aksam, aksam?.timeStr ?: "--:--")
            views.setTextViewText(R.id.val_yatsi, yatsi?.timeStr ?: "--:--")

            // Aktif vakti bul ve altındaki pirinç çubuğu göster
            val activeIndex = when {
                imsak != null && now < imsak.epochMs -> -1
                gunes != null && now < gunes.epochMs -> 0
                ogle != null && now < ogle.epochMs -> 1
                ikindi != null && now < ikindi.epochMs -> 2
                aksam != null && now < aksam.epochMs -> 3
                yatsi != null && now < yatsi.epochMs -> 4
                else -> 5
            }

            if (activeIndex in 0..5) {
                views.setViewVisibility(bars[activeIndex], View.VISIBLE)
            }

            val isKerahat = isKerahatActive(now, day)
            views.setViewVisibility(
                R.id.tv_medium_kerahat,
                if (isKerahat) View.VISIBLE else View.GONE
            )
        } else {
            views.setTextViewText(R.id.tv_medium_date, "Bugün")
            views.setTextViewText(R.id.val_imsak, "--:--")
            views.setTextViewText(R.id.val_gunes, "--:--")
            views.setTextViewText(R.id.val_ogle, "--:--")
            views.setTextViewText(R.id.val_ikindi, "--:--")
            views.setTextViewText(R.id.val_aksam, "--:--")
            views.setTextViewText(R.id.val_yatsi, "--:--")
            views.setViewVisibility(R.id.tv_medium_kerahat, View.GONE)
        }

        val pendingIntent = getLaunchPendingIntent(context, "vakit://vakitler", 102)
        views.setOnClickPendingIntent(R.id.widget_medium_root, pendingIntent)

        appWidgetManager.updateAppWidget(appWidgetId, views)
    }

    fun updateStripWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        prefs: SharedPreferences
    ) {
        val views = RemoteViews(context.packageName, R.layout.widget_strip)
        val cityName = getStringValue(context, prefs, "city_name", "İstanbul")
        val days = parsePrayerData(context, prefs)
        val now = System.currentTimeMillis()

        views.setTextViewText(R.id.tv_strip_city, cityName)

        var nextEvent: PrayerEvent? = null
        val todayDay = findTodayDayData(days)
        val isKerahat = isKerahatActive(now, todayDay)

        if (days.isNotEmpty()) {
            val allEvents = days.flatMap { it.events }.filter { it.epochMs > 0 }
            nextEvent = allEvents.firstOrNull { it.epochMs > now }
        }

        if (nextEvent != null) {
            views.setTextViewText(R.id.tv_strip_prayer_name, nextEvent.name)
            views.setTextViewText(R.id.tv_strip_prayer_time, nextEvent.timeStr)
            val deltaMs = nextEvent.epochMs - now
            val chronometerBase = SystemClock.elapsedRealtime() + deltaMs
            views.setChronometer(R.id.widget_strip_chronometer, chronometerBase, null, true)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                views.setChronometerCountDown(R.id.widget_strip_chronometer, true)
            }
        } else {
            views.setTextViewText(R.id.tv_strip_prayer_name, "Vakit")
            views.setTextViewText(R.id.tv_strip_prayer_time, "--:--")
        }

        views.setViewVisibility(
            R.id.tv_strip_kerahat_badge,
            if (isKerahat) View.VISIBLE else View.GONE
        )

        val pendingIntent = getLaunchPendingIntent(context, "vakit://vakitler", 103)
        views.setOnClickPendingIntent(R.id.widget_strip_root, pendingIntent)

        appWidgetManager.updateAppWidget(appWidgetId, views)
    }

    fun updateVerseWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        prefs: SharedPreferences
    ) {
        val views = RemoteViews(context.packageName, R.layout.widget_verse)
        val verseText = getStringValue(
            context,
            prefs,
            "today_verse_short",
            "“Beni anın ki ben de sizi anayım; bana şükredin, nankörlük etmeyin.”"
        )
        val verseSource = getStringValue(context, prefs, "today_verse_source", "Bakara, 152")

        views.setTextViewText(R.id.tv_verse_text, verseText)
        views.setTextViewText(R.id.tv_verse_source, verseSource)

        val pendingIntent = getLaunchPendingIntent(context, "vakit://ayet", 104)
        views.setOnClickPendingIntent(R.id.widget_verse_root, pendingIntent)

        appWidgetManager.updateAppWidget(appWidgetId, views)
    }

    fun updateHadithWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        prefs: SharedPreferences
    ) {
        val views = RemoteViews(context.packageName, R.layout.widget_hadith)
        val hadithText = getStringValue(
            context,
            prefs,
            "today_hadith_short",
            "“Ameller niyetlere göredir; herkes için ancak niyet ettiği şey vardır.”"
        )
        val hadithSource = getStringValue(context, prefs, "today_hadith_source", "Buhârî, Bed’ü’l-vahy, 1")
        val hadithNarrator = getStringValue(context, prefs, "today_hadith_narrator", "Hz. Ömer (r.a.)")

        views.setTextViewText(R.id.tv_hadith_text, hadithText)
        views.setTextViewText(R.id.tv_hadith_source, hadithSource)
        views.setTextViewText(R.id.tv_hadith_narrator, hadithNarrator)

        val pendingIntent = getLaunchPendingIntent(context, "vakit://hadis", 105)
        views.setOnClickPendingIntent(R.id.widget_hadith_root, pendingIntent)

        appWidgetManager.updateAppWidget(appWidgetId, views)
    }

    fun scheduleNextAlarm(context: Context, prefs: SharedPreferences) {
        val days = parsePrayerData(context, prefs)
        val now = System.currentTimeMillis()

        val triggerTimes = mutableListOf<Long>()

        for (day in days) {
            for (event in day.events) {
                if (event.epochMs > now) triggerTimes.add(event.epochMs)
            }
            if (day.kerahatMorningEnd > now) triggerTimes.add(day.kerahatMorningEnd)
            if (day.kerahatMiddayStart > now) triggerTimes.add(day.kerahatMiddayStart)
            if (day.kerahatMiddayEnd > now) triggerTimes.add(day.kerahatMiddayEnd)
            if (day.kerahatEveningStart > now) triggerTimes.add(day.kerahatEveningStart)
            if (day.kerahatEveningEnd > now) triggerTimes.add(day.kerahatEveningEnd)
        }

        // Gece yarısı tetikleyicisi
        val midnightCal = Calendar.getInstance().apply {
            add(Calendar.DAY_OF_YEAR, 1)
            set(Calendar.HOUR_OF_DAY, 0)
            set(Calendar.MINUTE, 0)
            set(Calendar.SECOND, 5)
        }
        triggerTimes.add(midnightCal.timeInMillis)

        val nextTrigger = triggerTimes.filter { it > now }.minOrNull() ?: return

        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as? AlarmManager ?: return
        val intent = Intent(context, VakitAlarmReceiver::class.java).apply {
            action = "com.vakit.vakit.ACTION_WIDGET_ALARM"
        }
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            1001,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, nextTrigger, pendingIntent)
            } else {
                alarmManager.setExact(AlarmManager.RTC_WAKEUP, nextTrigger, pendingIntent)
            }
        } catch (_: SecurityException) {
            alarmManager.set(AlarmManager.RTC_WAKEUP, nextTrigger, pendingIntent)
        }
    }

    fun updateAllWidgets(context: Context) {
        val appWidgetManager = AppWidgetManager.getInstance(context)
        val prefs = getPrefs(context)

        // 1. Small
        val smallComponent = ComponentName(context, VakitSmallWidgetProvider::class.java)
        val smallIds = appWidgetManager.getAppWidgetIds(smallComponent)
        for (id in smallIds) {
            updateSmallWidget(context, appWidgetManager, id, prefs)
        }

        // 2. Medium
        val mediumComponent = ComponentName(context, VakitMediumWidgetProvider::class.java)
        val mediumIds = appWidgetManager.getAppWidgetIds(mediumComponent)
        for (id in mediumIds) {
            updateMediumWidget(context, appWidgetManager, id, prefs)
        }

        // 3. Strip
        val stripComponent = ComponentName(context, VakitStripWidgetProvider::class.java)
        val stripIds = appWidgetManager.getAppWidgetIds(stripComponent)
        for (id in stripIds) {
            updateStripWidget(context, appWidgetManager, id, prefs)
        }

        // 4. Verse
        val verseComponent = ComponentName(context, VakitVerseWidgetProvider::class.java)
        val verseIds = appWidgetManager.getAppWidgetIds(verseComponent)
        for (id in verseIds) {
            updateVerseWidget(context, appWidgetManager, id, prefs)
        }

        // 5. Hadith
        val hadithComponent = ComponentName(context, VakitHadithWidgetProvider::class.java)
        val hadithIds = appWidgetManager.getAppWidgetIds(hadithComponent)
        for (id in resizeHadithIds(appWidgetManager, hadithComponent)) {
            updateHadithWidget(context, appWidgetManager, id, prefs)
        }

        scheduleNextAlarm(context, prefs)
    }

    private fun resizeHadithIds(manager: AppWidgetManager, comp: ComponentName): IntArray {
        return manager.getAppWidgetIds(comp)
    }
}
