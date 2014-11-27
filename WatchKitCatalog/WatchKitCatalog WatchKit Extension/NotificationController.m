//
//  NotificationController.m
//  WatchKitCatalog WatchKit Extension
//
//  Created by Xiangjian Meng on 14/11/25.
//  Copyright (c) 2014年 cn.com.modernmedia. All rights reserved.
//

#import "NotificationController.h"


@interface NotificationController()

@property (weak, nonatomic) IBOutlet WKInterfaceLabel *contentlabel;

@end


@implementation NotificationController

- (instancetype)init {
    self = [super init];
    if (self){
        // Initialize variables here.
        // Configure interface objects here.
        NSLog(@"%@ init", self);
        
    }
    return self;
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    NSLog(@"%@ will activate", self);
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    NSLog(@"%@ did deactivate", self);
}

/*
- (void)didReceiveLocalNotification:(UILocalNotification *)localNotification withCompletion:(void (^)(WKUserNotificationInterfaceType))completionHandler {
    // This method is called when a local notification needs to be presented.
    // Implement it if you use a dynamic notification interface.
    // Populate your dynamic notification inteface as quickly as possible.
    //
    // After populating your dynamic notification interface call the completion block.
    completionHandler(WKUserNotificationInterfaceTypeCustom);
}
*/


- (void)didReceiveRemoteNotification:(NSDictionary *)remoteNotification withCompletion:(void (^)(WKUserNotificationInterfaceType))completionHandler {
    // This method is called when a remote notification needs to be presented.
    // Implement it if you use a dynamic notification interface.
    // Populate your dynamic notification inteface as quickly as possible.
    //
    // After populating your dynamic notification interface call the completion block.
    
    NSString *customString = remoteNotification[@"customKey"];
    [self.contentlabel setText:customString];
    
    completionHandler(WKUserNotificationInterfaceTypeCustom);
}



@end



