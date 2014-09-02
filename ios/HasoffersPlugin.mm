#import "HasoffersPlugin.h"
#import "StoreKit/SKPaymentTransaction.h" //to get SKPaymentTransactionStatePurchased

@implementation HasoffersPlugin

// The plugin must call super dealloc.
- (void) dealloc {
  [super dealloc];
}

// The plugin must call super init.
- (id) init {
  self = [super init];
  if (!self) {
    return nil;
  }

  return self;
}

- (void) initializeWithManifest:(NSDictionary *)manifest appDelegate:(TeaLeafAppDelegate *)appDelegate {
  @try {

    NSDictionary *ios = [manifest valueForKey:@"ios"];
    NSString * const MAT_ADVERTISER_ID = [ios valueForKey:@"hasoffersadvid"];
    NSString * const MAT_CONVERSION_KEY = [ios valueForKey:@"hasofferskey"];

    if (MAT_ADVERTISER_ID && MAT_CONVERSION_KEY) {
      [MobileAppTracker initializeWithMATAdvertiserId:MAT_ADVERTISER_ID
                                     MATConversionKey:MAT_CONVERSION_KEY];
    }

    [MobileAppTracker setAppleAdvertisingIdentifier:[[ASIdentifierManager sharedManager] advertisingIdentifier]
                         advertisingTrackingEnabled:[[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled]];

    // FOR DEBUG ONLY: TURN THIS ON TO SEE DEBUG MESSAGES
    //[MobileAppTracker setDebugMode:YES];

    // FOR DEBUG ONLY: TURN THIS ON TO SEE DUPLICATE REQUESTS
    //[MobileAppTracker setAllowDuplicateRequests:YES];

  }
  @catch (NSException *exception) {
    NSLog(@"{facebook} Exception while initializing: %@", exception);
  }
}


- (void) setUserIds:(NSDictionary *)jsonObject {
  NSString *uid = nil;

  if([jsonObject objectForKey:@"uid"]) {
    uid = [NSString stringWithFormat:@"%@",[jsonObject valueForKey:@"uid"]];
    [MobileAppTracker setUserId:uid];
  }
  if([jsonObject objectForKey:@"fb_id"]) {
    uid = [NSString stringWithFormat:@"%@",[jsonObject valueForKey:@"fb_id"]];
    [MobileAppTracker setFacebookUserId:uid];
  }
  if([jsonObject objectForKey:@"google_id"]) {
    uid = [NSString stringWithFormat:@"%@",[jsonObject valueForKey:@"google_id"]];
    [MobileAppTracker setGoogleUserId:uid];
  }
  if([jsonObject objectForKey:@"twitter_id"]) {
    uid = [NSString stringWithFormat:@"%@",[jsonObject valueForKey:@"twitter_id"]];
    [MobileAppTracker setTwitterUserId:uid];
  }
}

- (void) trackLevel:(NSDictionary *)jsonObject {
  NSInteger level = nil;
  NSString *attr = nil;

  if([jsonObject objectForKey:@"level"]) {
    level = [[jsonObject objectForKey:@"level"] integerValue];
    [MobileAppTracker setEventLevel:level];
  }
  if([jsonObject objectForKey:@"attr"]) {
    attr = [jsonObject objectForKey:@"attr"];
    [MobileAppTracker setEventAttribute1:attr];
  }
  [MobileAppTracker measureAction:@"level_achieved"];
}

- (void) trackPurchase:(NSDictionary *)jsonObject {
  NSString *receiptString = [jsonObject valueForKey:@"receipt"];
  NSData *data = [receiptString dataUsingEncoding:NSUTF8StringEncoding];

  [MobileAppTracker measureAction:@"purchase"
                       eventItems:@[[MATEventItem eventItemWithName:[NSString stringWithFormat:@"%@",[jsonObject valueForKey:@"sku"]]
                                                          unitPrice:[[jsonObject valueForKey:@"price"] floatValue]
                                                           quantity:[[jsonObject valueForKey:@"quantity"] intValue]
                                                            revenue:[[jsonObject valueForKey:@"revenue"] floatValue]]]
                      referenceId:[NSString stringWithFormat:@"%@", [jsonObject valueForKey:@"token"]]
                    revenueAmount:0
                     currencyCode:[jsonObject valueForKey:@"currency"]
                 transactionState:SKPaymentTransactionStatePurchased
                          receipt:data];
}

- (void) applicationWillTerminate:(UIApplication *)app {
}

- (void) applicationDidBecomeActive:(UIApplication *)app {
  // MAT will not function without the measureSession call included
  [MobileAppTracker measureSession];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  return true;
}

- (void) handleOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication {
  [MobileAppTracker applicationDidOpenURL:[url absoluteString] sourceApplication:sourceApplication];
}

- (void) didBecomeActive:(NSDictionary *)jsonObject {
}

@end
