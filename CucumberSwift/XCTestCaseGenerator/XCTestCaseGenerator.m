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

@implementation XCTestCaseGenerator
    struct objc_method {
        SEL method_name;
        char *method_types;
        IMP method_imp;
    };
    
    + (XCTestCase *)initWithClassName:(NSString *)className :(XCTestCaseMethod *)method {
        Class testCase =  objc_allocateClassPair([XCTestCase class], [className UTF8String], 0);
        struct objc_method myMethod;
        myMethod.method_name = sel_registerName([method.name UTF8String]);
        myMethod.method_imp  = imp_implementationWithBlock(method.closure);
        myMethod.method_types = "v@:";
        
        // add method to the class
        class_addMethod(testCase, myMethod.method_name, myMethod.method_imp, myMethod.method_types);
        return [[testCase alloc] initWithSelector:myMethod.method_name];
    }
@end
