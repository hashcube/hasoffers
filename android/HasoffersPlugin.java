package com.tealeaf.plugin.plugins;

import com.mobileapptracker.*;

import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.content.pm.PackageManager.NameNotFoundException;
import com.tealeaf.logger;
import com.tealeaf.TeaLeaf;
import com.tealeaf.plugin.IPlugin;
import java.io.*;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import com.tealeaf.util.HTTP;
import android.app.Activity;
import android.content.Intent;
import android.content.Context;
import android.util.Log;
import android.os.Bundle;

public class HasoffersPlugin implements IPlugin {
    Activity activity;
    MobileAppTracker _mobileapptracker;

    public HasoffersPlugin() {

    }

    public void onCreateApplication(Context applicationContext) {

    }

    public void onCreate(Activity activity, Bundle savedInstanceState) {
        this.activity = activity;
        //Below segment gets the hasoffers key
        PackageManager manager = this.activity.getPackageManager();
        String hasoffersKey = "";
        String hasoffersAdvId = "";
        try {
            Bundle meta = manager.getApplicationInfo(this.activity.getPackageName(), PackageManager.GET_META_DATA).metaData;
            if (meta != null) {
                hasoffersKey = meta.getString("HASOFFERS_KEY");
                hasoffersAdvId = meta.getString("HASOFFERS_ADV_ID");
            }
        } catch (Exception e) {
            android.util.Log.d("EXCEPTION", "" + e.getMessage());
        }
        //Init MAT Tracker
        _mobileapptracker = new MobileAppTracker(
                this.activity,
                hasoffersAdvId, 
                hasoffersKey);
        //Disallow these in production build
        //**********************************
        //**********************************
        //**********************************
        //**********************************
        //*********REMEMBER TO DELETE*******
        //**********************************
        //**********************************
        //**********************************
        _mobileapptracker.setAllowDuplicates(true);
        _mobileapptracker.setDebugMode(true);
        //**********************************
        //**********************************
        //*********REMEMBER TO DELETE*******
        //**********************************
        //**********************************
        //**********************************
        //**********************************
    }

    public void onResume() {

    }

    public void onStart() {
    }

    public void trackInstall(String json) {
        //Next we parse the json parameter
        String userType = "unknown";
        try {
            JSONObject obj = new JSONObject(json);
            userType = obj.getString("userType");
            if(userType == "old") {
                _mobileapptracker.trackUpdate();
            } else {
                _mobileapptracker.trackInstall();
            }
        } catch (JSONException e) {
            logger.log("{hasoffers} Init - failure: " + e.getMessage());
        }
    }

    public void trackPurchase(String json) {
        Double price = 0.00;
        String purchaseData = "";
        String dataSignature = "";
        try {
            JSONObject obj = new JSONObject(json);
            price = obj.getDouble("price");
            purchaseData = obj.getString("purchaseData");
            dataSignature = obj.getString("dataSignature");
            _mobileapptracker.trackAction("purchase", price, "USD", purchaseData, dataSignature, "garbage");
        } catch (JSONException e) {
            logger.log("{hasoffers} Purchase Validation - failure: " + e.getMessage());
        }
    }

    public void trackOpen(String dummy) {
        _mobileapptracker.trackAction("open");
    }

    public void onPause() {

    }

    public void onStop() {
    }

    public void onDestroy() {
    }

    public void onNewIntent(Intent intent) {

    }

    public void setInstallReferrer(String referrer) {

    }

    public void onActivityResult(Integer request, Integer result, Intent data) {

    }

    public boolean consumeOnBackPressed() {
        return true;
    }

    public void onBackPressed() {
    }
}