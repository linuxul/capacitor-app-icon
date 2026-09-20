package com.mycompany.plugins.example

import android.app.Activity
import android.content.ComponentName
import android.content.Context
import android.content.pm.PackageManager
import android.util.Log
import com.getcapacitor.JSArray
import org.json.JSONException

public class AppIconBase(@Suppress("UNUSED_PARAMETER") activity: Activity, private val context: Context) {
    private val packageName: String = context.packageName
    internal var pm: PackageManager = context.applicationContext.packageManager

    public val isSupported: Boolean
        get() = true

    public fun getName(): String? {
        // An app without a launch intent has always failed here with a NullPointerException.
        val componentName = pm.getLaunchIntentForPackage(context.packageName)!!.component!!
        val status = pm.getComponentEnabledSetting(componentName)

        if (status == PackageManager.COMPONENT_ENABLED_STATE_ENABLED || status == PackageManager.COMPONENT_ENABLED_STATE_DEFAULT) {
            // The component is currently enabled
            val name = componentName.shortClassName
            if (name == ".MainActivity") {
                return null
            }
            return name.substring(1)
        } else {
            // The component is currently disabled
            return null
        }
    }

    // `disableNames` is null when the call passed something other than an array, which has always been a
    // NullPointerException, here and in reset.
    public fun change(enableName: String?, disableNames: JSArray?) {
        try {
            val newList = disableNames!!.toList<String>()

            pm.setComponentEnabledSetting(
                ComponentName(packageName, "$packageName.$enableName"),
                PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
                PackageManager.DONT_KILL_APP
            )

            for (value in newList) {
                Log.i("AppIconBase", "$packageName.$value")
                pm.setComponentEnabledSetting(
                    ComponentName(packageName, "$packageName.$value"),
                    PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
                    PackageManager.DONT_KILL_APP
                )
            }

            // Always disable main app icon
            pm.setComponentEnabledSetting(
                ComponentName(packageName, "$packageName.MainActivity"),
                PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
                PackageManager.DONT_KILL_APP
            )
        } catch (ignore: JSONException) {
            // do nothing
        }
    }

    public fun reset(disableNames: JSArray?) {
        try {
            val newList = disableNames!!.toList<String>()
            // Reset the icon to the default icon
            pm.setComponentEnabledSetting(
                ComponentName(packageName, "$packageName.MainActivity"),
                PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
                PackageManager.DONT_KILL_APP
            )
            for (value in newList) {
                Log.i("AppIconBaseReset", "$packageName.$value")
                pm.setComponentEnabledSetting(
                    ComponentName(packageName, "$packageName.$value"),
                    PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
                    PackageManager.DONT_KILL_APP
                )
            }
        } catch (ignore: JSONException) {
            // do nothing
        }
    }
}
