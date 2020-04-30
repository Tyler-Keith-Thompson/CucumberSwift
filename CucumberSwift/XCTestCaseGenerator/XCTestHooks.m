//
//  XCTestHooks.m
//  CucumberSwift
//
//  Created by Tyler Thompson on 4/29/20.
//  Copyright © 2020 Tyler Thompson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CucumberSwift/CucumberSwift-Swift.h>

@interface TestLoader : XCTestSuite
@end

@implementation TestLoader

+ (void)load {
    [Cucumber Load];
}

@end
