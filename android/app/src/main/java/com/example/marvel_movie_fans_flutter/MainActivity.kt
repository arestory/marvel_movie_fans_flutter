package com.example.marvel_movie_fans_flutter

import android.content.Intent
import android.os.Bundle
import android.widget.Toast
import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity : FlutterActivity() {

    lateinit var methodChannel: MethodChannel
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

//        methodChannel.invokeMethod()

    }
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        GeneratedPluginRegistrant.registerWith(this)

        val methodChannel = MethodChannel(flutterView, "loginUser")
        methodChannel.setMethodCallHandler { methodCall, result ->

            when (methodCall.method){
                "showToast" -> {
                    Toast.makeText(this,"toast", Toast.LENGTH_SHORT).show()
                    result.success("success")
                }
                "getLoginUser" -> result.success(UserDataSource.getLoginUser(this@MainActivity))
                  "clearLoginUser" -> {
                    UserDataSource.clearLoginUser(this@MainActivity)
                    result.success(200)
                }
                "watchAdv"->{

                    result.success("success")
                }
                "checkFinishLevel" -> methodCall.argument<Any>("userId")

            }
        }

    }
    companion object {

        internal var LOGIN_USER_CHANNEL = "loginUser"
    }
}
