package com.banuba.sdk.flutter.arcloud

import androidx.lifecycle.LifecycleOwner
import com.banuba.sdk.arcloud.data.source.ArEffectsRepository
import com.banuba.sdk.arcloud.data.source.model.ArEffect
import com.banuba.sdk.arcloud.data.source.model.EffectsLoadingResult
import com.google.gson.Gson
import com.google.gson.JsonIOException
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.*
import org.koin.core.component.KoinApiExtension
import org.koin.core.component.inject
import org.koin.core.component.KoinComponent

@KoinApiExtension
class FlutterARCloudPlugin : FlutterPlugin, ActivityAware, KoinComponent {
    companion object {
        private const val CHANNEL_NAME = "com.banuba.sdk.flutter.arcloud"

        private const val METHOD_GET_EFFECTS = "get_effects"
        private const val METHOD_DOWNLOAD_EFFECT = "download_effect"
        private const val METHOD_EFFECTS_LOADED = "effects_loaded"

        private const val PARAM_EFFECT_NAME = "effect_name"

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
        observeEffects(binding.activity as FlutterActivity)
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
            METHOD_GET_EFFECTS -> {
                onGetEffectsCall(result)
            }
            METHOD_DOWNLOAD_EFFECT -> {
                onDownloadEffectCall(call, result)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun onGetEffectsCall(result: MethodChannel.Result) {
        scope.launch {
            try {
                val effectsResult = arEffectsRepository.getEffects()
                if (effectsResult is EffectsLoadingResult.Success) {
                    replaceEffects(effectsResult.data)
                    val effectsJson = gson.toJson(effects)
                    result.success(effectsJson)
                } else if (effectsResult is EffectsLoadingResult.Error) {
                    result.error(ERROR_CODE_GET_EFFECTS, effectsResult.exception.toString(), null)
                }
            } catch (exception: Exception) {
                result.error(ERROR_CODE_GET_EFFECTS, exception.toString(), null)
            }
        }
    }


    private fun onDownloadEffectCall(call: MethodCall, result: MethodChannel.Result) {
        scope.launch {
            try {
                val effectNameParam = call.obtainArgument<String>(PARAM_EFFECT_NAME)
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
                        result.error(
                            ERROR_CODE_DOWNLOAD_EFFECT,
                            "Downloading error. ${effectResult.exception}",
                            null
                        )
                    }
                }
            } catch (exception: JsonIOException) {
                result.error(
                    ERROR_CODE_DOWNLOAD_EFFECT,
                    "Effects serialization error. $exception",
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
                        val effectsWrapper = ArEffectsJsonWrapper(effects)
                        val effectsJson = gson.toJson(effectsWrapper)
                        channel?.invokeMethod(METHOD_EFFECTS_LOADED, effectsJson)
                    } else {
                        val effectsWrapper = ArEffectsJsonWrapper(ERROR_CODE_DOWNLOAD_EFFECT)
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