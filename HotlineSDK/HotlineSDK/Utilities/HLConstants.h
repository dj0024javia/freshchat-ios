//
//  HLConstants.h
//  HotlineSDK
//
//  Created by Aravinth Chandran on 24/09/15.
//  Copyright © 2015 Freshdesk. All rights reserved.
//
#include "HLVersionConstants.h"

#ifndef HLConstants_h
#define HLConstants_h

#ifdef DEBUG
#define SOLUTIONS_FETCH_INTERVAL 5
#define CHANNELS_FETCH_INTERVAL 5
#else
#define SOLUTIONS_FETCH_INTERVAL 300
#define CHANNELS_FETCH_INTERVAL 150
#endif

#define KONOTOR_REFRESHINDICATOR_TAG 80
#define KONOTOR_MESSAGESPERPAGE 25

#endif