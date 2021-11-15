package com.banuba.sdk.flutter.arcloud

import io.flutter.plugin.common.MethodCall

fun <T> MethodCall.obtainArgument(argumentName: String): T {
    @Suppress("UNCHECKED_CAST")
    val argumentsMap = arguments as Map<String, Any?>
    return argumentsMap.obtainArgument(argumentName)
}

fun <T> Map<String, Any?>.obtainArgument(argumentName: String): T {
    return if (containsKey(argumentName)) {
        @Suppress("UNCHECKED_CAST")
        this[argumentName] as T
    } else {
        throw IllegalArgumentException()
    }
}