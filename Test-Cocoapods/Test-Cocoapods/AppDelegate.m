//
//  AppDelegate.m
//  Test-Cocoapods
//
//  Created by Nts on 8.09.2019.
//  Copyright © 2019 Ribbon. All rights reserved.
//

#import "AppDelegate.h"
#import <PushKit/PushKit.h>
#import <MobileSDK/MobileSDK.h>

@interface AppDelegate ()<PKPushRegistryDelegate>

@end

@implementation AppDelegate
UIBackgroundTaskIdentifier backgroundTaskID;

#pragma mark PushKitDelegate
- (void) pushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(PKPushPayload *)payload forType:(PKPushType)type
{
    [self handlePushPayload:payload forType:type withCompletionHandler:nil];
}

- (void)pushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(PKPushPayload *)payload forType:(PKPushType)type withCompletionHandler:(void (^)(void))completion {
    [self handlePushPayload:payload forType:type withCompletionHandler:completion];
}

- (void)handlePushPayload:(PKPushPayload *)pushPayload forType:(PKPushType )type withCompletionHandler:(void (^)(void))completion{
    
    backgroundTaskID = [UIApplication.sharedApplication beginBackgroundTaskWithName:@"BackgroundTask" expirationHandler:^{
        [UIApplication.sharedApplication endBackgroundTask:backgroundTaskID];
        backgroundTaskID = UIBackgroundTaskInvalid;
    }];
    
    NSDictionary *pushData = pushPayload.dictionaryPayload;
    
    NSLog(@"received notification: %@", pushData);
    
    if (type == PKPushTypeVoIP && [pushData objectForKey:@"notificationMessage"]) {
        
        SMPushService *pushService = [[SMServiceProvider getInstance] getPushService];
        
        id notificationCompletion = ^(SMMobileError * _Nullable error) {
            if (error)
                NSLog(@"injecting push notification failed. error: %@", error.description);
            
            [UIApplication.sharedApplication endBackgroundTask:backgroundTaskID];
            if (completion)
                completion();
            backgroundTaskID = UIBackgroundTaskInvalid;
        };
        
        if ([[[SMServiceProvider getInstance] getRegistrationService] getRegistrationState] == REGISTERED) {
            [pushService injectPushMessage:pushData completionHandler:notificationCompletion];
        }
        else {
            NSInteger selectedUserIndex = 15;
            NSLog(@"Unregistered");
        }
        
    } else {
        NSLog(@"received notification is not related with the MobileSDK");
    }
    
}

- (void) pushRegistry:(PKPushRegistry *)registry didUpdatePushCredentials:(PKPushCredentials *)credentials forType:(PKPushType)type
{
    NSLog(@"Token : %@", credentials.token);
    
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    if ([[[SMServiceProvider getInstance] getRegistrationService] getRegistrationState] == REGISTERED) {
        NSLog(@"Registered");
    }
    else {
        NSInteger selectedUserIndex = 15;
        NSLog(@"Unregistered");
    }
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
