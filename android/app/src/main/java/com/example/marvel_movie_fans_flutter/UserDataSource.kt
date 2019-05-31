package com.example.marvel_movie_fans_flutter

import android.annotation.SuppressLint
import android.content.Context
import com.google.gson.Gson

@SuppressLint("NewApi")
object UserDataSource {

    fun getLoginUser(context: Context): String? {

        return context.getSharedPreferences("movie", Context.MODE_PRIVATE).getString("user", "")

    }
    fun saveLoginUser(context: Context){

        val sp = context.getSharedPreferences("movie", Context.MODE_PRIVATE).edit()
        val user = UserInfo()
        user.id="1125043102839496704"
        user.nickName="反托尼装甲"
        user.sex="地球人"
        user.slogan="Hail Hydra!!!"
        user.avatar="avatar/1125043102839496704img-6bdf181aly1g3bnhjf0s4g20h80h8x6q.gif"
        sp.putString("user",Gson().toJson(user))
        sp.apply()

    }

    fun checkLevelFinish(context: Context, userId: String?, level: Int):Boolean {

        if(userId==null){
            return false
        }
        val userFinishLevelJson =
                context.getSharedPreferences("movie", Context.MODE_PRIVATE).getString(userId.plus("-level"), "")
        if (userFinishLevelJson!!.isNotEmpty()) {

            val userFinishLevel = Gson().fromJson(userFinishLevelJson, UserFinishLevel::class.java)
            if(userFinishLevel!=null){
                return userFinishLevel.levelSet.contains(level)
            }
        }
        return false
    }


    fun clearLoginUser(context: Context) {
        val sp = context.getSharedPreferences("movie", Context.MODE_PRIVATE).edit()
        sp.remove("user")
        sp.apply()
    }
}

class UserFinishLevel {

    var userId:String?=null
    val levelSet = HashSet<Int>()
}