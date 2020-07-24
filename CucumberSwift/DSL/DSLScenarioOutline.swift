//
//  DSLScenarioOutline.swift
//  CucumberSwift
//
//  Created by thompsty on 7/23/20.
//  Copyright © 2020 Tyler Thompson. All rights reserved.
//

import Foundation

class ScenarioOutline {
    @discardableResult init<T>(_ title:String, tags:[String] = [], headers: T.Type, @StepBuilder steps: (T) -> [DSLStep], examples: () -> [T]) {
        
    }
    
    @discardableResult init<T>(_ title:String, tags:[String] = [], headers: T.Type, @StepBuilder steps: (T) -> DSLStep, examples: () -> [T]) {
        
    }
}
