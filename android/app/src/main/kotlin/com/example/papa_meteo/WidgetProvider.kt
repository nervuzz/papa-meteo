package com.nervuzz.papa_meteo // your package name

import android.os.Bundle
import android.graphics.Bitmap
import com.squareup.picasso.Picasso
import com.squareup.picasso.Target
import android.graphics.drawable.Drawable
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetProvider

class HomeScreenWidgetProvider : HomeWidgetProvider() {

     override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, widgetData: SharedPreferences) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_layout).apply {
                // Set current city label
                val city = widgetData.getString("city", null)
                setTextViewText(R.id.widget_city, city?: "No city set")

                // Set current datetime label
                val dt = widgetData.getString("dt", null)
                setTextViewText(R.id.widget_dt, dt?: "Pending refresh..")

                // Set current forecast image
                val imageURL = widgetData.getString("widgetImg", "https://www.nasa.gov/sites/default/files/styles/full_width/public/thumbnails/image/spitzer20180822-nasa-small.jpg")
                Picasso.get().load(imageURL).into(object : Target {
                        override fun onBitmapFailed(e: Exception?, errorDrawable: Drawable?) {}
                        override fun onBitmapLoaded(bitmap: Bitmap?, from: Picasso.LoadedFrom?) {
                                // Downloaded bitmap goes here
                                setImageViewBitmap(R.id.widgetImg, bitmap)
                        }
                        override fun onPrepareLoad(placeHolderDrawable: Drawable?) {}
                })

                // Update forecast by click on City label
                val backgroundIntent = HomeWidgetBackgroundIntent.getBroadcast(
                        context,
                        Uri.parse("homeScreenWidget://cityClicked")
                )
                setOnClickPendingIntent(R.id.widget_city, backgroundIntent)  
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}