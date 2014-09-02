package com.tealeaf.plugin.plugins;

import com.mobileapptracker.MobileAppTracker;
import com.mobileapptracker.MATEventItem;

// Play Services
import com.google.android.gms.ads.identifier.AdvertisingIdClient;
import com.google.android.gms.ads.identifier.AdvertisingIdClient.Info;
import com.google.android.gms.common.GooglePlayServicesRepairableException;
import com.google.android.gms.common.GooglePlayServicesNotAvailableException;
import java.io.IOException;
import android.provider.Settings.Secure;

import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.content.pm.PackageManager.NameNotFoundException;
import com.tealeaf.logger;
import com.tealeaf.TeaLeaf;
import com.tealeaf.plugin.IPlugin;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import com.tealeaf.util.HTTP;
import android.app.Activity;
import android.content.Intent;
import android.content.Context;
import android.os.Bundle;
import java.util.List;
import java.util.ArrayList;

public class HasoffersPlugin implements IPlugin {
  Activity activity;
  MobileAppTracker _mobileapptracker;
  Context  ctx;
  String userId = null, fb_id = null, google_id = null, twitter_id = null;
  private final String TAG = "{{HasOffers}}";

  public HasoffersPlugin() {
  }

  public void onCreateApplication(Context applicationContext) {
    ctx = applicationContext;
  }

  public void onCreate(Activity passedActivity, Bundle savedInstanceState) {
    activity = passedActivity;
    //Below segment gets the hasoffers key
    PackageManager manager = activity.getPackageManager();
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
    MobileAppTracker.init(
      this.ctx,
      hasoffersAdvId,
      hasoffersKey);

    _mobileapptracker = MobileAppTracker.getInstance();

    new Thread(new Runnable() {
      @Override public void run() {
        // See sample code at http://developer.android.com/google/play-services/id.html
        try {
          Info adInfo = AdvertisingIdClient.getAdvertisingIdInfo(ctx);
          _mobileapptracker.setGoogleAdvertisingId(adInfo.getId(), adInfo.isLimitAdTrackingEnabled());
        } catch (IOException e) {
          // Unrecoverable error connecting to Google Play services (e.g.,
          // the old version of the service doesn't support getting AdvertisingId).
          _mobileapptracker.setAndroidId(Secure.getString(activity.getContentResolver(), Secure.ANDROID_ID));
        } catch (GooglePlayServicesNotAvailableException e) {
          // Google Play services is not available entirely.
          _mobileapptracker.setAndroidId(Secure.getString(activity.getContentResolver(), Secure.ANDROID_ID));
        } catch (GooglePlayServicesRepairableException e) {
          // Encountered a recoverable error connecting to Google Play services.
          _mobileapptracker.setAndroidId(Secure.getString(activity.getContentResolver(), Secure.ANDROID_ID));
        } catch (NullPointerException e) {
          // getId() is sometimes null
          _mobileapptracker.setAndroidId(Secure.getString(activity.getContentResolver(), Secure.ANDROID_ID));
        }
      }
    }).start();

    //Disallow these in production build
    //_mobileapptracker.setAllowDuplicates(true);
    //_mobileapptracker.setDebugMode(true);
  }

  public void onResume() {
    logger.log(TAG, "Measuring session now");
    _mobileapptracker.setReferralSources(activity);
    _mobileapptracker.measureSession();
  }

  public void onStart() {
  }
    // TODO: Error Handling code
  public void setUserIds(String json) {
    try {
      JSONObject data = new JSONObject();
      if (data.has("uid")) {
        _mobileapptracker.setUserId(data.getString("uid"));
      }
      if (data.has("fb_id")) {
        _mobileapptracker.setFacebookUserId(data.getString("fb_id"));
      }
      if (data.has("google_id")) {
        _mobileapptracker.setGoogleUserId(data.getString("google_id"));
      }
      if (data.has("twitter_id")) {
        _mobileapptracker.setTwitterUserId(data.getString("twitter_id"));
      }
    } catch (JSONException ex) {
      ex.printStackTrace();
    }
  }

  public void trackLevel (String json) {
    try {
      JSONObject data = new JSONObject(json);
      if (data.has("level")) {
        _mobileapptracker.setEventLevel(data.getInt("level"));
      } else {
        throw new Exception("No Level data found while setting a level");
      }
      if (data.has("attr")) {
        _mobileapptracker.setEventAttribute1(data.getString("attr"));
      }
      _mobileapptracker.measureAction("level_achieved");
    } catch (Exception e) {
      e.printStackTrace();
    }

  }

  public void trackPurchase(String json) {
    try {
      JSONObject data = new JSONObject(json);
      String receiptId = data.getString("receipt");
      String sku = data.getString("sku");
      int quantity = data.getInt("quantity");
      double revenue = data.getDouble("revenue");
      double unitPrice = data.getDouble("unitPrice");
      List<MATEventItem> events = new ArrayList();
      events.add(new MATEventItem(sku, quantity, unitPrice, revenue));
      String currency = data.getString("currency");
      _mobileapptracker.measureAction("purchase", events, revenue, currency, receiptId);
      logger.log(TAG, "Sent payment events", receiptId, sku, quantity, revenue, unitPrice);
    } catch (JSONException ex) {
      ex.printStackTrace();
    }
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
