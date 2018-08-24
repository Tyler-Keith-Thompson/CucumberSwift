//
//  XCTestCaseMethod.h
//  CucumberSwift
//
//  Created by Tyler Thompson on 8/23/18.
//  Copyright © 2018 Tyler Thompson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XCTestCaseMethod : NSObject
    @property (nonatomic, retain) NSString* name;
    @property (nonatomic, copy) void (^closure)(void);

    - (id)initWithName:(NSString *)name closure:(void (^)(void))closure;
@end
