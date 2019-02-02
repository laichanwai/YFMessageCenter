//
//  YFMessageCenter.h
//  YFMessageCenter
//
//  Created by laizw on 2019/1/31.
//  Copyright © 2019 laizw. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT double YFMessageCenterVersionNumber;
FOUNDATION_EXPORT const unsigned char YFMessageCenterVersionString[];

NS_ASSUME_NONNULL_BEGIN

@interface YFMessageCenter : NSObject

@property (class, readonly) YFMessageCenter *defaultCenter;

- (instancetype)init NS_DESIGNATED_INITIALIZER;

- (void)addObserver:(NSObject *)observer forProtocol:(Protocol *)protocol;
- (void)removeObserver:(NSObject *)observer forProtocol:(Protocol *)protocol;

- (id)dispatcherForProtocol:(Protocol *)protocol;
@end

NS_ASSUME_NONNULL_END

#ifndef YFMessageCenter_h
#define YFMessageCenter_h

#define OBSERVE_MESSAGE(observer, protocol_name) \
    [[YFMessageCenter defaultCenter] addObserver:observer forProtocol:@protocol(protocol_name)]

#define UN_OBSERVE_MESSAGE(observer, protocol_name) \
    [[YFMessageCenter defaultCenter] removeObserver:observer forProtocol:@protocol(protocol_name)]

#define DISPATCH_MESSAGE(protocol_name) \
    ((id<protocol_name>)[[YFMessageCenter defaultCenter] dispatcherForProtocol:@protocol(protocol_name)])

#endif
