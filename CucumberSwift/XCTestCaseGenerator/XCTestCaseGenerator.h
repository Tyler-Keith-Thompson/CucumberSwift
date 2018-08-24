//
//  XCTestCaseGenerator.h
//  CucumberSwift
//
//  Created by Tyler Thompson on 8/23/18.
//  Copyright © 2018 Tyler Thompson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
#import "XCTestCaseMethod.h"

@interface XCTestCaseGenerator : NSObject
    + (XCTestCase *)initWithClassName:(NSString *)className :(XCTestCaseMethod *)method;
@end
