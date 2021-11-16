package com.banuba.sdk.arcloud.example

import com.banuba.sdk.arcloud.common.BANUBA_AR_CLOUD_URL
import com.banuba.sdk.arcloud.common.BANUBA_CLIENT_TOKEN
import org.koin.core.qualifier.named
import org.koin.dsl.module

class MainKoinModule {

    val module = module {

        single(named("banubaLocalToken"), override = true) {
            BANUBA_CLIENT_TOKEN
        }

        single(named("arEffectsCloudUrl"), override = true) {
            BANUBA_AR_CLOUD_URL
        }
    }
}