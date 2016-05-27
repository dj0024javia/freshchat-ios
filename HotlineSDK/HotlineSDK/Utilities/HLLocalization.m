//
//  HLLocalization.m
//  HotlineSDK
//
//  Created by Hrishikesh on 27/05/16.
//  Copyright © 2016 Freshdesk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HLLocalization.h"
#import "FDSecureStore.h"

@interface HLLocalization ()

@end

@implementation HLLocalization

static NSString *DEFAULT_BUNDLE_NAME = @"HLLocalization";
static NSString *DEFAULT_LOCALIZATION_TABLE = @"HLLocalizable";

+(void)load {
    [self getBundlePriorityArray]; // initialize this early.
}

+(NSArray *) getBundlePriorityArray{
    static NSArray *bundleArray ;
    if(!bundleArray){
        NSMutableArray *priorityArray = [NSMutableArray new];
        NSString *lookupBundleName = [[FDSecureStore sharedInstance]objectForKey:HOTLINE_DEFAULTS_STRINGS_BUNDLE];
        lookupBundleName = lookupBundleName ? lookupBundleName : DEFAULT_BUNDLE_NAME;
        
        NSBundle *overrideBundle = [self bundleWithName:lookupBundleName andLang:[self getPreferredLang]];
        NSBundle *projectLevelBundle = [self bundleWithName:lookupBundleName andLang:DEFAULT_LANG];
        NSBundle *defaultPodBundle = [self bundleWithName:DEFAULT_BUNDLE_NAME andLang:DEFAULT_LANG];
        
        if(overrideBundle) [priorityArray addObject:overrideBundle];
        if(projectLevelBundle) [priorityArray addObject:projectLevelBundle];
        if(defaultPodBundle) [priorityArray addObject:defaultPodBundle];
        
        bundleArray = [[NSArray alloc] initWithArray:priorityArray];
    }
    return bundleArray;
}

+(NSString *)localize:(NSString *)key{
    NSString *localizedString;
    //Lookup string in the right order
    for(NSBundle *bundle in [self getBundlePriorityArray]){
        localizedString = NSLocalizedStringWithDefaultValue(key, DEFAULT_LOCALIZATION_TABLE, bundle, nil, nil);
        if([self isLocalizedString:localizedString forKey:key]){
            return localizedString;
        }
    }
    //no match found so return key : This can never happen unless some one deleted the bundle from pod
    return key;
}

+(NSBundle *)bundleWithName:(NSString *)bundleName andLang:(NSString *)langCode{
    NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:bundleName ofType:@"bundle"]];
    return [NSBundle bundleWithPath:[bundle pathForResource:langCode ofType:@"lproj"]];
}

+(NSString *)getPreferredLang{
    NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0]; //sample "en-US"
    NSDictionary *languageDic = [NSLocale componentsFromLocaleIdentifier:language];
    return [languageDic objectForKey:@"kCFLocaleLanguageCodeKey"]; //sample "en"
}

+(BOOL)isLocalizedString:(NSString *)value forKey:(NSString *)key{
    if (value) {
        return ![key isEqualToString:value];
    }else{
        return NO;
    }
}

@end