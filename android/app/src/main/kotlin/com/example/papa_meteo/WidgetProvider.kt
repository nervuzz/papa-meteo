package com.example.papa_meteo // your package name

import android.os.Bundle
import android.graphics.Bitmap
import com.squareup.picasso.Picasso
import android.graphics.drawable.Drawable
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class HomeScreenWidgetProvider : HomeWidgetProvider() {

     override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, widgetData: SharedPreferences) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_layout).apply {
                // Open App on Widget Click
                val pendingIntent = HomeWidgetLaunchIntent.getActivity(
                        context,
                        MainActivity::class.java)
                setOnClickPendingIntent(R.id.widget_container, pendingIntent)

                // Swap Title Text by calling Dart Code in the Background
                // setTextViewText(R.id.widget_title, widgetData.getString("title", null)?: "No Title Set")
                // val backgroundIntent = HomeWidgetBackgroundIntent.getBroadcast(
                //         context,
                //         Uri.parse("homeWidgetExample://titleClicked")
                // )
                // setOnClickPendingIntent(R.id.widget_title, backgroundIntent)

                val message = widgetData.getString("message", null)
                setTextViewText(R.id.widget_message, message?: "No Message Set")

                // // Detect App opened via Click inside Flutter
                // val pendingIntentWithData = HomeWidgetLaunchIntent.getActivity(
                //         context,
                //         MainActivity::class.java,
                //         Uri.parse("homeWidgetExample://message?message=$message"))
                // setOnClickPendingIntent(R.id.widget_message, pendingIntentWithData)

                val imageURL = widgetData.getString("widgetImg", "https://www.nasa.gov/sites/default/files/styles/full_width/public/thumbnails/image/spitzer20180822-nasa-small.jpg")

                Picasso.get().load(imageURL).into(object : com.squareup.picasso.Target {
                        override fun onBitmapFailed(e: Exception?, errorDrawable: Drawable?) {}
                        override fun onBitmapLoaded(bitmap: Bitmap?, from: Picasso.LoadedFrom?) {
                                // loaded bitmap is here (bitmap)
                                setImageViewBitmap(R.id.widgetImg, bitmap)
                        }
                        override fun onPrepareLoad(placeHolderDrawable: Drawable?) {}
                        })
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}