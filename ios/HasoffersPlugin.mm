#import "HasoffersPlugin.h"

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
      [[MobileAppTracker sharedManager] startTrackerWithMATAdvertiserId:MAT_ADVERTISER_ID
                                                       MATConversionKey:MAT_CONVERSION_KEY];
    }

    // FOR DEBUG ONLY: Turn this on to see debug messages
    //[[MobileAppTracker sharedManager] setDebugMode:YES];

    // FOR DEBUG ONLY: Turn this on to allow duplicate events
    //[[MobileAppTracker sharedManager] setAllowDuplicateRequests:YES];

    // set this class as the delegate for MAT callbacks
    //[[MobileAppTracker sharedManager] setDelegate:self];

  }
  @catch (NSException *exception) {
    NSLog(@"{facebook} Exception while initializing: %@", exception);
  }
}

/*
  #pragma mark - MobileAppTrackerDelegate Methods
// MAT tracking request success callback
- (void)mobileAppTracker:(MobileAppTracker *)tracker didSucceedWithData:(id)data
{
NSString *response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
NSLog(@"MAT.success: %@", response);
}

// MAT tracking request failure callback
- (void)mobileAppTracker:(MobileAppTracker *)tracker didFailWithError:(NSError *)error
{
NSLog(@"MAT.failure: %@", error);
}
*/

- (void) setUID:(NSDictionary *)jsonObject {
  if([jsonObject objectForKey:@"uid"]) {
    NSString *uid = [NSString stringWithFormat:@"%@",[jsonObject valueForKey:@"uid"]];
    [[MobileAppTracker sharedManager] setUserId:uid];
  }
}

- (void) trackInstall:(NSDictionary *)jsonObject {
  if([jsonObject objectForKey:@"userType"]) {
    NSString *userType = [NSString stringWithFormat:@"%@",[jsonObject valueForKey:@"userType"]];
    if([userType  isEqual: @"old"]) {
      [[MobileAppTracker sharedManager] trackUpdate];
    } else {
      [[MobileAppTracker sharedManager] trackInstall];
    }
  }
}

- (void) trackPurchase:(NSDictionary *)jsonObject {
  NSData *data=[NSKeyedArchiver archivedDataWithRootObject:[jsonObject valueForKey:@"dataSignature"]];
  [[MobileAppTracker sharedManager] trackActionForEventIdOrName:@"purchase"
                                                      eventIsId:NO
                                                     eventItems:  @[[MATEventItem eventItemWithName:[NSString stringWithFormat:@"%@",[jsonObject valueForKey:@"purchaseData"]]
                                                                                          unitPrice:[[jsonObject valueForKey:@"price"] floatValue]
                                                                                           quantity:1
                                                                                            revenue:[[jsonObject valueForKey:@"price"] floatValue]
                                                                                         attribute1:@"attr1"
                                                                                         attribute2:@"attr2"
                                                                                         attribute3:@"attr3"
                                                                                         attribute4:@"attr4"
                                                                                         attribute5:@"attr5"]]
                                                    referenceId:[NSString stringWithFormat:@"%@", [jsonObject valueForKey:@"token"]]
                                                  revenueAmount:[[jsonObject valueForKey:@"price"] floatValue]
                                                   currencyCode:@"USD"
                                               transactionState:1
                                                        receipt:data];
}

- (void) trackOpen:(NSDictionary *)dummy {
  [[MobileAppTracker sharedManager] trackActionForEventIdOrName:@"open" eventIsId:NO];
}
@end
