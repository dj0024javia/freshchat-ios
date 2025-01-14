//
//  AppDelegate.m
//  ObjectiveCSample
//
//  Created by user on 18/09/17.
//  Copyright © 2017 Sanjith J K. All rights reserved.
//

#import "AppDelegate.h"
#import "FreshchatSDK/FreshchatSDK.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [self initFreshchatSDK];
    return YES;
}

-(void) initFreshchatSDK {
    FreshchatConfig *fchatConfig = [[FreshchatConfig alloc] initWithAppID:@"" andAppKey:@""]; //Enter your AppID and AppKey here
    fchatConfig.themeName = @"CustomThemeFile";//Your Custom Theme File
    fchatConfig.domain = @"msdk.eu.freshchat.com";
    [[Freshchat sharedInstance] initWithConfig:fchatConfig];
    // Create a user object
    FreshchatUser *user = [FreshchatUser sharedInstance];
    // To set an identifiable first name for the user
    user.firstName = @"John";
    // To set an identifiable last name for the user
    user.lastName = @"Doe";
    //To set user's email id
    user.email = @"john.doe.1982@mail.com";
    //To set user's phone number
    user.phoneCountryCode=@"00";
    user.phoneNumber = @"9999999999";
    [[Freshchat sharedInstance] setUser:user];
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
