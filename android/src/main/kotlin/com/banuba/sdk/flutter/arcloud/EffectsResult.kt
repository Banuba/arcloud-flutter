package com.banuba.sdk.flutter.arcloud

import com.banuba.sdk.arcloud.data.source.model.ArEffect

data class EffectsResult(
    val errorCode: String?,
    val effects: List<ArEffect>?
) {
    constructor(errorCode: String) : this(errorCode, null)
    constructor(effects: List<ArEffect>) : this(null, effects)
}
