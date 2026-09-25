package com.mycompany.plugins.example

import com.getcapacitor.JSObject
import com.getcapacitor.Plugin
import com.getcapacitor.PluginCall
import com.getcapacitor.PluginException
import com.getcapacitor.PluginMethod
import com.getcapacitor.annotation.CapacitorPlugin

@CapacitorPlugin(name = "AppIcon")
public class AppIconPlugin : Plugin() {
    private lateinit var implementation: AppIconBase

    override fun load() {
        implementation = AppIconBase(activity, context)
    }

    @PluginMethod
    public fun isSupported(call: PluginCall) {
        val r = JSObject()
        r.put("value", implementation.isSupported)
        call.resolve(r)
    }

    @PluginMethod
    public fun getName(call: PluginCall) {
        val r = JSObject()
        r.put("value", implementation.getName())
        call.resolve(r)
    }

    @PluginMethod
    public fun change(call: PluginCall) {
        if (!call.data.has("name")) {
            throw PluginException("Must provide an icon name")
        }
        if (!call.data.has("disable")) {
            throw PluginException("Must provide an array of icon names to disable")
        }

        implementation.change(call.getString("name"), call.getArray("disable"))
        call.resolve()
    }

    @PluginMethod
    public fun reset(call: PluginCall) {
        if (!call.data.has("disable")) {
            throw PluginException("Must provide an array of icon names to disable")
        }

        implementation.reset(call.getArray("disable"))
        call.resolve()
    }
}
