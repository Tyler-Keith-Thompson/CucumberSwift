//
//  XCTestCaseGenerator.m
//  CucumberSwift
//
//  Created by Tyler Thompson on 8/23/18.
//  Copyright © 2018 Tyler Thompson. All rights reserved.
//

#import "XCTestCaseGenerator.h"
#import "XCTestCaseMethod.h"
#import "XCTest/XCTest.h"
#import <objc/runtime.h>

@interface JRInvocationGrabber : NSProxy {
        id              target;
        NSInvocation    *invocation;
    }
    @property (retain) id target;
    @property (retain) NSInvocation *invocation;
@end

@implementation JRInvocationGrabber
    @synthesize target, invocation;
    
    - (id)initWithTarget:(id)target_ {
        self.target = target_;
        return self;
    }
    
    - (NSMethodSignature*)methodSignatureForSelector:(SEL)selector_ {
        return [self.target methodSignatureForSelector:selector_];
    }
    
    - (void)forwardInvocation:(NSInvocation*)invocation_ {
        [invocation_ setTarget:self.target];
        self.invocation = invocation_;
    }
    
    #if !__has_feature(objc_arc)
    - (void)dealloc {
        self.target = nil;
        self.invocation = nil;
        [super dealloc];
    }
    #endif
    
@end

@implementation NSInvocation (jr_block)
    
    + (id)jr_invocationWithTarget:(id)target_ block:(void (^)(id target))block_ {
        JRInvocationGrabber *grabber = [[JRInvocationGrabber alloc] initWithTarget:target_];
    #if !__has_feature(objc_arc)
        [grabber autorelease];
    #endif
        block_(grabber);
        return grabber.invocation;
    }
    
@end
void sayHello ( id self, SEL _cmd,... )
{
    NSLog (@"Hello");
}

@implementation XCTestCaseGenerator
    struct objc_method {
        SEL method_name;
        char *method_types;
        IMP method_imp;
    };
    
    + (XCTestCase *)initWithClassName:(NSString *)className :(XCTestCaseMethod *)method {
        Class testCase =  objc_allocateClassPair([XCTestCase class], [className UTF8String], 0);
//        objc_registerClassPair(testCase);
        struct objc_method myMethod;
        myMethod.method_name = sel_registerName([method.name UTF8String]);
        myMethod.method_imp  = imp_implementationWithBlock(method.closure);
        myMethod.method_types = "v@:";
        
        // add method to the class
        class_addMethod(testCase, myMethod.method_name, myMethod.method_imp, myMethod.method_types);
        return [[testCase alloc] initWithSelector:myMethod.method_name];
    }
@end
