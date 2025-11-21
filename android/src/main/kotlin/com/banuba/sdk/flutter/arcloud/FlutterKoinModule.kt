package com.banuba.sdk.flutter.arcloud

import com.banuba.sdk.arcloud.data.source.ArEffectsRepositoryProvider
import com.banuba.sdk.arcloud.di.ArCloudKoinModule
import org.koin.core.module.Module
import org.koin.core.qualifier.named
import org.koin.dsl.module
import kotlinx.coroutines.Dispatchers

object FlutterKoinModule {

    var url: String = ""

    private val flutterArCloudModule: Module = module {
        single(createdAtStart = true) {
            ArEffectsRepositoryProvider(
                arEffectsRepository = get(named("backendArEffectsRepository"))
            ).provide(get(named("prioritizedMasks")))
        }

        single(named("prioritizedMasks")) {
            emptySet<String>()
        }
        
        single(named("arEffectsCloudUrl")) {
            url
        }
    }

    val modules: List<Module> by lazy {
        ArCloudKoinModule().module.plus(flutterArCloudModule)
    }
}