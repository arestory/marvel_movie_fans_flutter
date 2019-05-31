package com.example.marvel_movie_fans_flutter

import android.os.Bundle
import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        GeneratedPluginRegistrant.registerWith(this)

        MethodChannel(flutterView, LOGIN_USER_CHANNEL).setMethodCallHandler { methodCall, result ->

            if (methodCall.method == "getLoginUser") {
                result.success(UserDataSource.getLoginUser(this@MainActivity))
            } else if (methodCall.method == "clearLoginUser") {
                UserDataSource.clearLoginUser(this@MainActivity)
                result.success(200)
            } else if (methodCall.method == "checkFinishLevel") {

                methodCall.argument<Any>("userId")
            }
        }

    }

    companion object {

        internal var LOGIN_USER_CHANNEL = "loginUser"
    }
}
