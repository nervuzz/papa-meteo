package com.nervuzz.papa_meteo

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.graphics.Bitmap
import android.graphics.drawable.Drawable
import android.net.Uri
import android.util.Log
import android.widget.RemoteViews
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter
import com.squareup.picasso.Picasso
import com.squareup.picasso.Target
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetProvider


class HomeScreenWidgetProvider : HomeWidgetProvider() {

    fun getCurrentTime(): String {
        val current = LocalDateTime.now()
        val formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")
        val ts = current.format(formatter)
        Log.d("~papa_meteo", "getCurrentTime: " + ts)
        return ts
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences) 
    {
        val widgetId = appWidgetIds[0]
        val myviews = RemoteViews(context.packageName, R.layout.widget_layout)

        // Set current city label
        val city = widgetData.getString("city", null)
        myviews.setTextViewText(R.id.widget_city, city?: "No city set")

        // Set current datetime label
        val dt = getCurrentTime()
        myviews.setTextViewText(R.id.widget_dt, dt?: "Pending refresh..")

        // Set current forecast image
        val imageURL = widgetData.getString("widgetImg", null)

        val picasso = Picasso.get()
        val target = object : Target {
            override fun onPrepareLoad(placeHolderDrawable: Drawable?) {}
            override fun onBitmapFailed(e: Exception?, errorDrawable: Drawable?) {}
            override fun onBitmapLoaded(bitmap: Bitmap?, from: Picasso.LoadedFrom?) {
                // Downloaded bitmap goes here
                myviews.setImageViewBitmap(R.id.widget_meteo_img, bitmap)
                appWidgetManager.updateAppWidget(widgetId, myviews)
                Log.d("~papa_meteo", city + " bitmap loaded | " + imageURL)
            }
        }
        picasso.load(imageURL).into(target)

        // Change to next favorite by click on city label
        val nextCityIntent = HomeWidgetBackgroundIntent.getBroadcast(
            context, Uri.parse("homeScreenWidget://nextcity")
        )
        myviews.setOnClickPendingIntent(R.id.widget_city, nextCityIntent)

        // Get most recent forecast by click on time label
        val updateForecastIntent = HomeWidgetBackgroundIntent.getBroadcast(
            context, Uri.parse("homeScreenWidget://updateforecast#" + city)
        )
        myviews.setOnClickPendingIntent(R.id.widget_dt, updateForecastIntent)
    }
}