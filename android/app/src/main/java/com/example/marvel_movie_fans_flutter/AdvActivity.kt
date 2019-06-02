package com.example.marvel_movie_fans_flutter

import android.Manifest
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.fragment.app.FragmentActivity
import com.miui.zeus.mimo.sdk.MimoSdk
import com.miui.zeus.mimo.sdk.api.IMimoSdkListener

class AdvActivity : FragmentActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        setContentView(R.layout.activity_adv_layout)

        if (Build.VERSION.SDK_INT >= 23) {
            if (ContextCompat.checkSelfPermission(this, Manifest.permission.READ_PHONE_STATE) != PackageManager.PERMISSION_GRANTED) {
                ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.READ_PHONE_STATE), 0)
            } else {

                initAdv()
            }
        }

    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)

    }

    fun initAdv(){

        MimoSdk.init(this, "2882303761518008528", "fake_app_key", "fake_app_token", object : IMimoSdkListener {
            override fun onSdkInitSuccess() {

                print("onSdkInitSuccess")
            }

            override fun onSdkInitFailed() {
                print("onSdkInitFailed")
            }
        })
    }
}
