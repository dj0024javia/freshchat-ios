//
//  FCHybridMessageController.h
//  HotlineSDK
//
//  Created by Sanjith Kanagavel on 03/03/20.
//  Copyright © 2020 Freshdesk. All rights reserved.
//

#import "FCBaseMessageController.h"
#import "FCProtocols.h"

@interface FCHybridMessageController : FCBaseMessageController<FCHybridMessageControllerProtocol>
-(id)initWithURL:(nonnull NSURL *) url;
@end