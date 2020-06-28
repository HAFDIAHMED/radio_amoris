package com.zindolla.radioamoris;

import android.app.Activity;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.ResultReceiver;
import android.util.Log;
// https://developer.android.com/jetpack/androidx/migrate/class-mappings
import androidx.core.content.ContextCompat;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

import static android.app.NotificationManager.IMPORTANCE_LOW;

public class MainActivity extends FlutterActivity implements MethodChannel.MethodCallHandler {
    public static final String CHANNEL_ID = "RadioAmorisServiceChannel";

    public  static final String TOSERVICE_STATION_UID = "Audio.station.name";
    public  static final String TOSERVICE_AVAILABLE_STATIONS = "Audio.station.list";

    private final static String TAG = MainActivity.class.getSimpleName();

    private MethodChannel channel;
    private static Context context;

    public static Context getAppContext() {
        return MainActivity.context;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        createNotificationChannel();
        MainActivity.context = getApplicationContext();
        channel = new MethodChannel(getFlutterView(), "com.zindolla.radio_amoris/audio");
        channel.setMethodCallHandler(this);
    }

    @Override
    protected void onDestroy(){
        super.onDestroy();
        Intent intent = new Intent( getApplicationContext(), RadioAmorisService.class );
        intent.setAction(RadioAmorisService.EXIT_SERVICE);
        ContextCompat.startForegroundService(this, intent);
    }


    @Override
    public void onMethodCall(MethodCall call, MethodChannel.Result response) {
        Intent intent = new Intent( getApplicationContext(), RadioAmorisService.class );
        String action = null;
        switch (call.method) {
            case "create":
                int mediaId = call.argument("selection");
                intent.putExtra(TOSERVICE_STATION_UID, mediaId);
                List<Map<String,String>> rawFavs = call.argument("stations");
                ArrayList<Station> stations = new ArrayList<>();
                for (Map<String,String> el: rawFavs){
                    stations.add(new Station(Integer.parseInt(el.get("id")), el.get("descr"), el.get("url")));
                }
                intent.putParcelableArrayListExtra(TOSERVICE_AVAILABLE_STATIONS, stations);
                action = RadioAmorisService.AUDIO_CREATE;
                break;
            case "pause":
                action = RadioAmorisService.AUDIO_PAUSE;
                // response.success(null);
                break;
            case "resume":
                action = RadioAmorisService.AUDIO_RESUME;
                break;
            case "destroy":
                action = RadioAmorisService.AUDIO_DESTROY;
                break;
            default:
                response.notImplemented();
        }
        if(action != null){
            intent.setAction(action);
            intent.putExtra(RadioAmorisService.BUNDLED_LISTENER, createReceiver(action));
            ContextCompat.startForegroundService(this, intent);
        }
    }

    private ResultReceiver createReceiver(final String action){
        return new ResultReceiver(new Handler()) {
            @Override
            protected void onReceiveResult(int resultCode, Bundle resultData) {
                super.onReceiveResult(resultCode, resultData);
                channel.invokeMethod((resultCode == Activity.RESULT_OK) ? action :
                        RadioAmorisService.AUDIO_ERROR, 0);
            }
        };
    }

    private void createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel serviceChannel = new NotificationChannel(
                    CHANNEL_ID,
                    "Radio Amoris",
                    IMPORTANCE_LOW
            );

            NotificationManager manager = getSystemService(NotificationManager.class);
            if (manager != null) {
                manager.createNotificationChannel(serviceChannel);
            }else{
                Log.e(TAG, "cannot obtain NotificationManager");
            }
        }
    }
}
