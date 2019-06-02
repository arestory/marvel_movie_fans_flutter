package com.example.marvel_movie_fans_flutter

import android.content.Intent
import android.os.Bundle
import com.miui.zeus.mimo.sdk.MimoSdk
import com.miui.zeus.mimo.sdk.api.IMimoSdkListener
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

        methodChannel =  MethodChannel(flutterView, LOGIN_USER_CHANNEL)
//        Bugly.init(applicationContext, "8d7193eaf2", BuildConfig.DEBUG)
        methodChannel.setMethodCallHandler { methodCall, result ->

            when ( methodCall.method){
                "getLoginUser" -> result.success(UserDataSource.getLoginUser(this@MainActivity))
                  "clearLoginUser" -> {
                    UserDataSource.clearLoginUser(this@MainActivity)
                    result.success(200)
                }
                "seeAdv"->{

                    val intent = Intent(this,AdvActivity::class.java)
                    startActivityForResult(intent,200)
                }
                "checkFinishLevel" -> methodCall.argument<Any>("userId")

            }
        }

    }

    companion object {

        internal var LOGIN_USER_CHANNEL = "loginUser"
    }
}
