package app.situationist.situationist

import android.content.Intent
import com.linusu.flutter_web_auth_2.FlutterWebAuth2Plugin
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        val url = intent.data ?: return
        val scheme = url.scheme ?: return
        FlutterWebAuth2Plugin.callbacks.remove(scheme)?.success(url.toString())
    }
}
