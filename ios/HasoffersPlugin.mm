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
		// NOTE: Should not need this since we inject it into the Info.plist
		NSDictionary *ios = [manifest valueForKey:@"ios"];
		NSString * const MAT_ADVERTISER_ID = [ios valueForKey:@"MAT_ADVERTISER_ID"];
		NSString * const MAT_CONVERSION_KEY = [ios valueForKey:@"MAT_CONVERSION_KEY"];
		
		if (MAT_ADVERTISER_ID && MAT_CONVERSION_KEY) {
			[[MobileAppTracker sharedManager] startTrackerWithMATAdvertiserId:MAT_ADVERTISER_ID
		                                                 MATConversionKey:MAT_CONVERSION_KEY];
		}
	}
	@catch (NSException *exception) {
		NSLog(@"{facebook} Exception while initializing: %@", exception);
	}
}

- (void) trackInstall:(NSDictionary *)jsonObject {
    if([jsonObject objectForKey:@"userType"]){
    	if([jsonObject valueForKey:@"userType"]!="old"){
    		[[MobileAppTracker sharedManager] trackUpdate];
    	} else {
    		[[MobileAppTracker sharedManager] trackInstall];
    	}
    }
}

- (void) trackPurchase:(NSDictionary *)jsonObject {
	[[MobileAppTracker sharedManager] trackActionForEventIdOrName:@"purchase"
                                                    eventIsId:NO
                                                   eventItems:  [MATEventItem eventItemWithName:[jsonObject valueForKey:@"purchaseData"]
                                                   							  unitPrice:[jsonObject valueForKey:@"price"]
                                                   							  quantity:1
                                                   							  revenue:[jsonObject valueForKey:@"price"]
                                                   							  attribute1:@"attr1" 
                                                   							  attribute2:@"attr2" 
                                                   							  attribute3:@"attr3" 
                                                   							  attribute4:@"attr4" 
                                                   							  attribute5:@"attr5"]
                                                  referenceId:[jsonObject valueForKey:@"token"]
                                                revenueAmount:[jsonObject valueForKey:@"price"]
                                                 currencyCode:@"USD"
                                             transactionState:@"SKPaymentTransactionStatePurchased"
                                                      receipt:[jsonObject valueForKey:@"dataSignature"];
}

- (void) trackOpen:(NSDictionary *)dummy {
	[[MobileAppTracker sharedManager] trackActionForEventIdOrName:@"open" eventIsId:NO];
}
@end