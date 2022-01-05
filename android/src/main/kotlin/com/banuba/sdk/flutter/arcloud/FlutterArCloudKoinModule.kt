package com.banuba.sdk.flutter.arcloud

import com.banuba.sdk.arcloud.data.source.ArEffectsRepositoryProvider
import com.banuba.sdk.arcloud.di.ArCloudKoinModule
import org.koin.core.module.Module
import org.koin.core.qualifier.named
import org.koin.dsl.module

class FlutterArCloudKoinModule {

    private val flutterArCloudModule: Module = module {
        single(createdAtStart = true, override = true) {
            ArEffectsRepositoryProvider(
                arEffectsRepository = get(named("backendArEffectsRepository")),
                ioDispatcher = get(named("ioDispatcher"))
            ).provide()
        }
        
        single(named("arEffectsCloudUrl"), override = true) {
            ArCloudUrlHolder.url
        }   
    }

    val modules: List<Module> by lazy {
        ArCloudKoinModule().module.plus(flutterArCloudModule)
    }
}