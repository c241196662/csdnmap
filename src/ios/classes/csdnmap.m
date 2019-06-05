/********* csdnmap.m Cordova Plugin Implementation *******/

#import <Cordova/CDV.h>
#import "MapViewController.h"
#import "MapBaseNavigationViewController.h"

@interface csdnmap : CDVPlugin {
  // Member variables go here.
}

- (void)launch:(CDVInvokedUrlCommand*)command;
@end

@implementation csdnmap

- (void)launch:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    NSString* echo = [command.arguments objectAtIndex:0];
	
    [self open];

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)open{
    MapViewController * vc = [[MapViewController alloc] init];
    vc.returnValueBlock = ^(NSDictionary *data){
        NSLog(@"qqqqqqqqqqqqqqqqqqqqq%@",data);
    };
    MapBaseNavigationViewController * nvc = [[MapBaseNavigationViewController alloc] initWithRootViewController:vc];
    [self presentViewController:nvc animated:YES completion:nil];
}

@end
