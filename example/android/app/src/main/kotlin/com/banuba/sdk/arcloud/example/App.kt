package com.banuba.sdk.arcloud.example

import android.app.Application
import com.banuba.sdk.flutter.arcloud.FlutterArCloudKoinModule
import org.koin.core.context.startKoin
import org.koin.android.ext.koin.androidContext

class App : Application() {

    override fun onCreate() {
        super.onCreate()
        startKoin {
            androidContext(this@App)
            modules(FlutterArCloudKoinModule().modules)
        }
    }
}