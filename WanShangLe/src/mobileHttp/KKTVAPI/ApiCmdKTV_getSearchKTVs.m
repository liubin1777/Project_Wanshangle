//
//  ApiCmdBindingHuiShowAccount.m
//  mobileapi
//
//  Created by doujingxuan on 10/30/12.
//
//

#import "ApiCmdKTV_getSearchKTVs.h"
#import "common.h"

@implementation ApiCmdKTV_getSearchKTVs

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void) dealloc {
    self.searchString = nil;
	[super dealloc];
}

- (ASIHTTPRequest*)prepareExecuteApiCmd{
    [super prepareExecuteApiCmd];
    
    // prepare http request
    NSURL *url = [NSURL URLWithString:@"https://raw.github.com/zyallday/HelloWorld/master/mobileapidemo/ktv-list-request.json"];
    
    [self.httpRequest setURL:url];
    
    return self.httpRequest;
}

//http://api.wanshangle.com:10000/api? appId=000001&api=ktv.list&sign=sign&time=1371988912&v=1.0&cityid=0755
- (NSMutableDictionary*)getParamDict {
    NSMutableDictionary* paramDict = [[[NSMutableDictionary alloc] init] autorelease];
    
    [paramDict setObject:@"ktv.search" forKey:@"api"];
    NSString *city_id = [[LocationManager defaultLocationManager] getUserCityId];
    [paramDict setObject:city_id forKey:@"cityid"];
    [paramDict setObject:[NSString stringWithFormat:@"%d",self.offset] forKey:@"offset"];
    [paramDict setObject:[NSString stringWithFormat:@"%d",self.limit] forKey:@"limit"];
//    [paramDict setObject:_searchString forKey:@"search"];
    
    return paramDict;
}


- (void) parseResultData:(NSDictionary*) dictionary {

    // get the data
    ABLoggerDebug(@"1111 responseJSONObject ======== %@",self.responseJSONObject);
}

-(void) notifyDelegate:(NSDictionary*) dictionary{
    

}

@end
