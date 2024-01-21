package com.banuba.sdk.flutter.arcloud

import android.util.Log
import androidx.lifecycle.LifecycleOwner
import com.banuba.sdk.arcloud.data.source.ArEffectsRepository
import com.banuba.sdk.arcloud.data.source.model.ArEffect
import com.banuba.sdk.arcloud.data.source.model.EffectsLoadingResult
import com.google.gson.Gson

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.*
import org.koin.core.component.inject
import org.koin.core.component.KoinComponent


class FlutterARCloudPlugin : FlutterPlugin, ActivityAware, KoinComponent {
    companion object {
        private const val TAG = "ARCloudAndroid"

        private const val CHANNEL_NAME = "com.banuba.sdk.flutter.arcloud"

        private const val METHOD_GET_EFFECTS = "get_effects"
        private const val METHOD_DOWNLOAD_EFFECT = "download_effect"
        private const val METHOD_EFFECTS_LOADED = "effects_loaded"
        private const val METHOD_ARCLOUD_URL = "ar_cloud_url"

        private const val PARAM_EFFECT_NAME = "effect_name"
        private const val PARAM_ARCLOUD_URL = "arCloudUrl"

        private const val ERROR_CODE_GET_EFFECTS = "error_get_effects"
        private const val ERROR_CODE_DOWNLOAD_EFFECT = "error_download_effect"
    }

    private val arEffectsRepository: ArEffectsRepository by inject()

    private val job = Job()
    private val scope = CoroutineScope(job + Dispatchers.Main)
    private val gson = Gson()

    private val effects = mutableListOf<ArEffect>()

    private var channel: MethodChannel? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        initChannel(binding.binaryMessenger)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        teardownChannel()
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        observeEffects(binding.activity as FlutterFragmentActivity)
    }

    override fun onDetachedFromActivity() {
        scope.cancel()
    }

    override fun onDetachedFromActivityForConfigChanges() {}

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {}

    private fun initChannel(messenger: BinaryMessenger) {
        channel = MethodChannel(messenger, CHANNEL_NAME)
        channel?.setMethodCallHandler { call, result -> onMethodCall(call, result) }
    }

    private fun teardownChannel() {
        channel?.setMethodCallHandler(null)
        channel = null
    }

    private fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            METHOD_GET_EFFECTS -> loadEffects(result)
            METHOD_DOWNLOAD_EFFECT -> downloadEffect(call, result)
            METHOD_ARCLOUD_URL -> initWithUrl(call, result)
            else -> result.notImplemented()
        }
    }

    private fun initWithUrl(
        call: MethodCall,
        result: MethodChannel.Result
    ) {
        val cloudUrl = call.obtainArgument<String>(PARAM_ARCLOUD_URL)
        Log.d(TAG, "initWithUrl = $cloudUrl")
        FlutterKoinModule.url = cloudUrl
        result.success(null)
    }

    private fun loadEffects(result: MethodChannel.Result) {
        scope.launch {
            try {
                Log.d(TAG, "Load effects")
                val effectsResult = arEffectsRepository.getEffects()
                if (effectsResult is EffectsLoadingResult.Success) {
                    replaceEffects(effectsResult.data)
                    val effectsJson = gson.toJson(effects)
                    result.success(effectsJson)
                } else if (effectsResult is EffectsLoadingResult.Error) {
                    Log.w(TAG, "Failed to load effects")
                    result.error(ERROR_CODE_GET_EFFECTS, effectsResult.exception.toString(), null)
                }
            } catch (e: Exception) {
                Log.w(TAG, "Failed to load effects", e)
                result.error(ERROR_CODE_GET_EFFECTS, e.toString(), null)
            }
        }
    }


    private fun downloadEffect(
        call: MethodCall,
        result: MethodChannel.Result
    ) {
        scope.launch {
            try {
                val effectNameParam = call.obtainArgument<String>(PARAM_EFFECT_NAME)
                Log.d(TAG, "Download effect = $effectNameParam")
                val effect = effects.find { effect -> effect.name == effectNameParam }
                if (effect == null) {
                    result.error(
                        ERROR_CODE_DOWNLOAD_EFFECT,
                        "Effect $effectNameParam not found",
                        null
                    )
                } else {
                    val effectResult = arEffectsRepository.getEffectData(effect)
                    if (effectResult is EffectsLoadingResult.Success) {
                        val effectJson = gson.toJson(effectResult.data)
                        result.success(effectJson)
                    } else if (effectResult is EffectsLoadingResult.Error) {
                        Log.w(TAG, "Failed to download effect = $effectNameParam")
                        result.error(
                            ERROR_CODE_DOWNLOAD_EFFECT,
                            "Downloading error. ${effectResult.exception}",
                            null
                        )
                    }
                }
            } catch (e: Exception) {
                Log.w(TAG, "Failed to download effect", e)
                result.error(
                    ERROR_CODE_DOWNLOAD_EFFECT,
                    "Effects serialization error. $e",
                    null
                )
            }
        }
    }

    private fun observeEffects(lifecycleOwner: LifecycleOwner) {
        scope.launch {
            arEffectsRepository.observeEffects()
                .observe(lifecycleOwner, { result ->
                    if (result is EffectsLoadingResult.Success) {
                        replaceEffects(result.data)
                        val effectsWrapper = EffectsResult(effects)
                        val effectsJson = gson.toJson(effectsWrapper)
                        channel?.invokeMethod(METHOD_EFFECTS_LOADED, effectsJson)
                    } else {
                        val effectsWrapper = EffectsResult(ERROR_CODE_DOWNLOAD_EFFECT)
                        val effectsJson = gson.toJson(effectsWrapper)
                        channel?.invokeMethod(METHOD_EFFECTS_LOADED, effectsJson)
                    }
                })
        }
    }

    private fun replaceEffects(newEffects: List<ArEffect>) {
        effects.clear()
        effects.addAll(newEffects)
    }
}