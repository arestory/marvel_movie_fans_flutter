package com.example.marvel_movie_fans_flutter

import android.Manifest
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.support.v4.app.ActivityCompat
import android.support.v4.content.ContextCompat
import android.support.v4.content.FileProvider
import android.support.v7.app.AppCompatActivity
import com.miui.zeus.mimo.sdk.MimoSdk
import com.miui.zeus.mimo.sdk.api.IMimoSdkListener
import kotlinx.android.synthetic.main.activity_adv_layout.*
import com.miui.zeus.mimo.sdk.ad.IRewardVideoAdWorker
import com.xiaomi.ad.common.pojo.AdType
import com.miui.zeus.mimo.sdk.ad.AdWorkerFactory
import com.miui.zeus.mimo.sdk.listener.MimoRewardVideoListener
import io.reactivex.Observable
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.schedulers.Schedulers
import java.util.concurrent.TimeUnit
import java.util.function.Predicate


class AdvActivity : AppCompatActivity() {
     private var mPortraitVideoAdWorker: IRewardVideoAdWorker?=null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        setContentView(R.layout.activity_adv_layout)
        setSupportActionBar(toolbar)


        supportActionBar?.setDisplayHomeAsUpEnabled(true)
        supportActionBar?.setDisplayShowHomeEnabled(true)
        toolbar.setNavigationOnClickListener{

            finish()
        }
        if (Build.VERSION.SDK_INT >= 23) {
            if (ContextCompat.checkSelfPermission(this, Manifest.permission.READ_PHONE_STATE) != PackageManager.PERMISSION_GRANTED) {
                ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.READ_PHONE_STATE), 0)
            } else {

                initAdv()
            }
        }

        MimoSdk.setDebugOn()
        MimoSdk.setStageOn()

        //测试 92d90db71791e6b9f7caaf46e4a997ec
        //正式 92d90db71791e6b9f7caaf46e4a997ec
        if(MimoSdk.isSdkReady()){

            println("MimoSdk.isSdkReady")
            mPortraitVideoAdWorker = AdWorkerFactory
                    .getRewardVideoAdWorker(applicationContext, TEST_ADV_ID, AdType.AD_REWARDED_VIDEO)

            val dis = Observable.interval(200,TimeUnit.MILLISECONDS).takeUntil{

                !mPortraitVideoAdWorker?.isReady!!
            }.subscribeOn(Schedulers.io()).observeOn(AndroidSchedulers.mainThread()).subscribe {
                println("mPortraitVideoAdWorker is Ready")
                mPortraitVideoAdWorker?.setListener(object :MimoRewardVideoListener{
                    override fun onAdFailed(p0: String?) {

                        println("onAdFailed $p0")
                    }

                    override fun onAdDismissed() {
                        println("onAdDismissed")
                    }

                    override fun onAdPresent() {
                        println("onAdPresent")

                    }

                    override fun onAdClick() {
                        println("onAdClick")

                    }

                    override fun onVideoPause() {
                        println("onVideoPause")
                    }

                    override fun onVideoStart() {
                        println("onVideoStart")

                    }

                    override fun onVideoComplete() {
                        println("onVideoComplete")

                    }

                    override fun onStimulateSuccess() {
                        println("onStimulateSuccess")

                    }

                    override fun onAdLoaded(p0: Int) {
                        println("onAdLoaded $p0")

                    }


                })

                mPortraitVideoAdWorker?.load()
            }
//            Observable<IRewardVideoAdWorker>.just(mPortraitVideoAdWorker)).subscribeOn(Schedulers.io()).observeOn(AndroidSchedulers.mainThread())
//            Thread(Runnable {
//
//
//                do {
//                    println("mPortraitVideoAdWorker is Ready")
//                }while (mPortraitVideoAdWorker?.isReady!!)
//
//
//            }).start()

        }

    }

    override fun onDestroy() {
        super.onDestroy()
        mPortraitVideoAdWorker?.recycle()
    }
    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)

    }

    companion object {
        const val TEST_APP_ID = "2882303761517411490"
        const val TEST_ADV_ID = "92d90db71791e6b9f7caaf46e4a997ec"
        const val APP_ID = "2882303761517859789"
        const val ADV_ID = "8df8bb781e8a6399ecafb5501deb4cb7"

    }
    private fun initAdv(){

        MimoSdk.init(this, TEST_APP_ID, "fake_app_key", "fake_app_token", object : IMimoSdkListener {
            override fun onSdkInitSuccess() {

                print("onSdkInitSuccess")
            }

            override fun onSdkInitFailed() {
                print("onSdkInitFailed")
            }
        })
    }
}
