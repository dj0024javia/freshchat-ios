//
//  HLAPI.h
//  HotlineSDK
//
//  Created by AravinthChandran on 9/14/15.
//  Copyright (c) 2015 Freshdesk. All rights reserved.
//

#import <Foundation/Foundation.h>

#define HTTP_METHOD_GET @"GET"
#define HTTP_METHOD_PUT @"PUT"

#define HOTLINE_USER_DOMAIN @"https://%@"

#define HOTLINE_REQUEST_PARAMS @"t=%@"

#define HOTLINE_API_CATEGORIES_PATH @"/app/services/app/%@/faq/category"

#define HOTLINE_API_ARTICLES_PATH @"/app/services/app/%@/faq/category/%@/article"

#define HOTLINE_API_ARTICLE_VOTE_PATH @"/app/services/app/%@/faq/category/%@/article/%@"

#define HOTLINE_API_CHANNELS_PATH @"/app/services/app/%@/channel"