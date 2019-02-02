//
//  YFMessageCenter.m
//  YFMessageCenter
//
//  Created by laizw on 2019/1/31.
//  Copyright © 2019 laizw. All rights reserved.
//

#import "YFMessageCenter.h"
#import <objc/runtime.h>

@interface YFMessageObserver : NSObject
@property (nonatomic, weak) NSObject *target;
+ (instancetype)weakTarget:(NSObject *)observer;
@end

@implementation YFMessageObserver
+ (instancetype)weakTarget:(NSObject *)target {
    YFMessageObserver *observer = [[YFMessageObserver alloc] init];
    observer.target = target;
    return observer;
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[YFMessageObserver class]]) {
        return NO;
    }
    YFMessageObserver *observer = (YFMessageObserver *)object;
    if (!self.target || !observer.target) {
        return NO;
    }
    return [self.target isEqual:observer.target];
}
@end

@interface YFMessageDispatcher : NSObject
@property (nonatomic, strong) dispatch_semaphore_t semaphore;
@property (nonatomic, strong) NSMutableSet<YFMessageObserver *> *observers;

+ (instancetype)dispatcherWithProtocol:(Protocol *)protocol;
- (void)addObserver:(NSObject *)observer;
- (void)removeObserver:(NSObject *)observer;
@end

@implementation YFMessageDispatcher

+ (instancetype)dispatcherWithProtocol:(Protocol *)protocol {
    YFMessageDispatcher *dispatcher = [[YFMessageDispatcher alloc] init];
    dispatcher.observers = @[].mutableCopy;
    dispatcher.semaphore = dispatch_semaphore_create(1);
    return dispatcher;
}

- (void)addObserver:(NSObject *)observer {
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    YFMessageObserver *object = [YFMessageObserver weakTarget:observer];
    [self.observers addObject:object];
    dispatch_semaphore_signal(self.semaphore);
}

- (void)removeObserver:(NSObject *)observer {
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    YFMessageObserver *object = [YFMessageObserver weakTarget:observer];
    [self.observers removeObject:object];
    dispatch_semaphore_signal(self.semaphore);
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    NSArray<YFMessageObserver *> *array = [self.observers copy];
    dispatch_semaphore_signal(self.semaphore);
    for (YFMessageObserver *observer in array) {
        if (observer.target) {
            if ([observer.target respondsToSelector:invocation.selector]) {
                [invocation invokeWithTarget:observer.target];
            }
        } else {
            [self removeObserver:observer.target];
        }
    }
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    NSArray<YFMessageObserver *> *array = [self.observers copy];
    dispatch_semaphore_signal(self.semaphore);
    
    for (YFMessageObserver *observer in array) {
        if ([observer.target respondsToSelector:sel]) {
            return [observer.target methodSignatureForSelector:sel];
        }
    }
    return [super methodSignatureForSelector:@selector(foo)];
}

- (void)foo {
    // ...
}

@end

@interface YFMessageCenter ()
@property (nonatomic, strong) NSMutableDictionary<NSString *, YFMessageDispatcher *> *dispatchers;
@property (nonatomic, strong) dispatch_semaphore_t semaphore;
@end

@implementation YFMessageCenter

+ (YFMessageCenter *)defaultCenter {
    static YFMessageCenter *instance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance = [[YFMessageCenter alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        self.dispatchers = @{}.mutableCopy;
        self.semaphore = dispatch_semaphore_create(1);
    }
    return self;
}

- (void)addObserver:(NSObject *)observer forProtocol:(Protocol *)protocol {
    [self _addObserver:observer forProtocol:protocol];
    unsigned int count = 0;
    Protocol * __unsafe_unretained *list = protocol_copyProtocolList(protocol, &count);
    for (int i = 0; i < count; i++) {
        Protocol *proto = list[i];
        if (protocol_isEqual(proto, @protocol(NSObject))) {
            break;
        }
        [self _addObserver:observer forProtocol:proto];
    }
    if (list) {
        free(list);
        list = NULL;
    }
}

- (void)removeObserver:(NSObject *)observer forProtocol:(Protocol *)protocol {
    [self _removeObserver:observer forProtocol:protocol];
    unsigned int count = 0;
    Protocol * __unsafe_unretained *list = protocol_copyProtocolList(protocol, &count);
    for (int i = 0; i < count; i++) {
        Protocol *proto = list[i];
        if (protocol_isEqual(proto, @protocol(NSObject))) {
            break;
        }
        [self _removeObserver:observer forProtocol:proto];
    }
}

- (id)dispatcherForProtocol:(Protocol *)protocol {
    NSString *key = NSStringFromProtocol(protocol);
    YFMessageDispatcher *dispatcher = nil;
    if (key.length > 0) {
        dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
        dispatcher = [self.dispatchers objectForKey:key];
        dispatch_semaphore_signal(self.semaphore);
    }
    return dispatcher;
}

#pragma mark - Private
- (void)_addObserver:(NSObject *)observer forProtocol:(Protocol *)protocol {
    if (![observer conformsToProtocol:protocol]) {
        return;
    }
    NSString *key = NSStringFromProtocol(protocol);
    if (key.length > 0) {
        dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
        YFMessageDispatcher *dispatcher = [self.dispatchers objectForKey:key];
        if (!dispatcher) {
            dispatcher = [YFMessageDispatcher dispatcherWithProtocol:protocol];
        }
        [dispatcher addObserver:observer];
        [self.dispatchers setObject:dispatcher forKey:key];
        dispatch_semaphore_signal(self.semaphore);
    }
}

- (void)_removeObserver:(NSObject *)observer forProtocol:(Protocol *)protocol {
    NSString *key = NSStringFromProtocol(protocol);
    if (key.length > 0) {
        dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
        YFMessageDispatcher *dispatcher = [self.dispatchers objectForKey:key];
        if (dispatcher) {
            [dispatcher removeObserver:observer];
            if (dispatcher.observers.count == 0) {
                [self.dispatchers removeObjectForKey:key];
            }
        }
        dispatch_semaphore_signal(self.semaphore);
    }
}

@end

