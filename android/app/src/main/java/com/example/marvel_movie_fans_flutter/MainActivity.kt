package com.example.marvel_movie_fans_flutter

import android.content.Intent
import android.os.Bundle
import android.widget.Toast
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

        initAdv()
        val methodChannel = MethodChannel(flutterView, "loginUser")
        methodChannel.setMethodCallHandler { methodCall, result ->

            when (methodCall.method){
                "showToast" -> {
                    Toast.makeText(this,"toast",Toast.LENGTH_SHORT).show()
                    result.success("success")
                }
                "getLoginUser" -> result.success(UserDataSource.getLoginUser(this@MainActivity))
                  "clearLoginUser" -> {
                    UserDataSource.clearLoginUser(this@MainActivity)
                    result.success(200)
                }
                "watchAdv"->{
                    val intent = Intent(this,AdvActivity::class.java)
                    startActivityForResult(intent,200)
                    result.success("success")
                }
                "checkFinishLevel" -> methodCall.argument<Any>("userId")

            }
        }

    }

    private fun initAdv(){

        MimoSdk.init(this, AdvActivity.TEST_APP_ID, "fake_app_key", "fake_app_token", object : IMimoSdkListener {
            override fun onSdkInitSuccess() {

                print("onSdkInitSuccess")
            }

            override fun onSdkInitFailed() {
                print("onSdkInitFailed")
            }
        })
    }

    companion object {

        internal var LOGIN_USER_CHANNEL = "loginUser"
    }
}
