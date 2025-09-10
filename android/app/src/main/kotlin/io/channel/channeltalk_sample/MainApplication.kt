package io.channel.channeltalk_sample

import android.app.Application
// Import ChannelIO Android SDK.
import com.zoyi.channel.plugin.android.ChannelIO

class MainApplication : Application() {
    
    override fun onCreate() {
        super.onCreate()
        
        // Initialize ChannelIO Android SDK
        ChannelIO.initialize(this)
    }
}
