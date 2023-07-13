package com.nervuzz.papa_meteo

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.graphics.Bitmap
import android.graphics.drawable.Drawable
import android.net.Uri
import android.util.Log
import android.widget.RemoteViews
import com.squareup.picasso.Picasso
import com.squareup.picasso.Target
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetProvider
import es.antonborri.home_widget.HomeWidgetPlugin

class HomeScreenWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences) 
    {
        val sp = HomeWidgetPlugin.getData(context)
        val sharedPreferenceIds = sp.all.map { it.key } //returns List<String>
        Log.d("/flutter", sharedPreferenceIds.toString())
        val widgetId = appWidgetIds[0]
        val myviews = RemoteViews(context.packageName, R.layout.widget_layout)

        // Set current city label
        val city = widgetData.getString("city", null)
        myviews.setTextViewText(R.id.widget_city, city?: "No city set")

        // Set current datetime label
        val dt = widgetData.getString("dt", null)
        myviews.setTextViewText(R.id.widget_dt, dt?: "Pending refresh..")

        // Set current forecast image
        val imageURL = widgetData.getString("widgetImg", null)
        // val imageURL = "https://pretekaj.sk/upload/events/716/logo.png"

        // Przetestowac!!        
        // lateinit var logo: ImageView
        // logo = findViewById(R.id.widget_meteo_img)
        // Log.d("/flutter", "findViewById "+logo)
        
        val pika = Picasso.get()
        val targ = object : Target {
            override fun onPrepareLoad(placeHolderDrawable: Drawable?) {}
            override fun onBitmapFailed(e: Exception?, errorDrawable: Drawable?) {
                Log.d("/flutter", "onBitmapFailed: " + e)
            }
            override fun onBitmapLoaded(bitmap: Bitmap?, from: Picasso.LoadedFrom?) {
                // Downloaded bitmap goes here
                Log.d("/flutter", "setImageViewBitmap start")
                myviews.setImageViewBitmap(R.id.widget_meteo_img, bitmap)
                appWidgetManager.updateAppWidget(widgetId, myviews)
                Log.d("/flutter", "setImageViewBitmap end")
            }
        }
        pika.load(imageURL).into(targ)

        // Picasso.get().load(imageURL).into(object : Target {
        //     override fun onPrepareLoad(placeHolderDrawable: Drawable?) {}
        //     override fun onBitmapFailed(e: Exception?, errorDrawable: Drawable?) {}
        //     override fun onBitmapLoaded(bitmap: Bitmap?, from: Picasso.LoadedFrom?) {
        //         // Downloaded bitmap goes here
        //         setImageViewBitmap(R.id.widget_meteo_img, bitmap)
        //         Log.d("/flutter", "setImageViewBitmap")
        //     }
        // })

        // ImageView imageView = (ImageView) findViewById(R.id.widgetImg)
        // Log.d("debugging", "imageView " + imageView)
        // Glide.with(context)
        //     .asBitmap()
        //     .load(imageURL)
        //     .into(object : CustomTarget<Bitmap>(){
        //         override fun onResourceReady(resource: Bitmap, transition: Transition<in Bitmap>?) {
        //             setImageViewBitmap(R.id.widgetImg, resource)
        //         }
        //         override fun onLoadCleared(placeholder: Drawable?) {}
        // })
        Log.d("/flutter", city + " | image bitmap loaded " + imageURL)

        // Change to next favorite by click on City label
        val nextCityIntent = HomeWidgetBackgroundIntent.getBroadcast(
            context, Uri.parse("homeScreenWidget://nextCity")
        )
        myviews.setOnClickPendingIntent(R.id.widget_city, nextCityIntent)

        // Update forecast by click on time label
        val refreshDataIntent = HomeWidgetBackgroundIntent.getBroadcast(
            context, Uri.parse("homeScreenWidget://refreshDataIntent")
        )
        myviews.setOnClickPendingIntent(R.id.widget_city, refreshDataIntent)

        // appWidgetManager.updateAppWidget(widgetId, myviews)
        // Log.d("/flutter", "updateAppWidget " + dt)
        // appWidgetManager.notifyAppWidgetViewDataChanged(widgetId, R.id.widget_meteo_img)
        appWidgetManager.partiallyUpdateAppWidget(widgetId, myviews)
        // Log.d("/flutter", "partiallyUpdateAppWidget")   
    }

    // override fun onAppWidgetOptionsChanged(
    //     context: Context,
    //     appWidgetManager: AppWidgetManager,
    //     appWidgetIds: Int,
    //     newOptions: Bundle)
    // {
    //     val sp = HomeWidgetPlugin.getData(context)
    //     val widgetId = appWidgetIds
    //     val myviews = RemoteViews(context.packageName, R.layout.widget_layout)

    //     val imageURL = "https://pretekaj.sk/upload/events/716/logo.png"
    //     val pika = Picasso.get()
    //     val targ = object : Target {
    //         override fun onPrepareLoad(placeHolderDrawable: Drawable?) {}
    //         override fun onBitmapFailed(e: Exception?, errorDrawable: Drawable?) {}
    //         override fun onBitmapLoaded(bitmap: Bitmap?, from: Picasso.LoadedFrom?) {
    //             // Downloaded bitmap goes here
    //             Log.d("/flutter1", "setImageViewBitmap start")
    //             myviews.setImageViewBitmap(R.id.widget_meteo_img, bitmap)
    //             Log.d("/flutter1", "setImageViewBitmap end")
    //         }
    //     }
    //     pika.load(imageURL).into(targ)

    //     appWidgetManager.updateAppWidget(widgetId, myviews)
    //     Log.d("/flutter1", "updateAppWidget ")
    // }
}