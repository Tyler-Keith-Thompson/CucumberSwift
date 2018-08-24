//
//  XCTestCaseMethod.m
//  CucumberSwift
//
//  Created by Tyler Thompson on 8/23/18.
//  Copyright © 2018 Tyler Thompson. All rights reserved.
//

#import "XCTestCaseMethod.h"

@implementation XCTestCaseMethod
    - (id)initWithName:(NSString *)name closure:(void (^)(void))closure
    {
        self.name = name;
        self.closure = closure;
        return self;
    }
@end
