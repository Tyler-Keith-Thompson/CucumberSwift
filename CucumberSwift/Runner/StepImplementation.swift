//
//  StepImplementation.swift
//  CucumberSwift
//
//  Created by Tyler Thompson on 8/25/18.
//  Copyright © 2018 Tyler Thompson. All rights reserved.
//

import Foundation

@objc public protocol StepImplementation {
    func setupSteps()
    var bundle:Bundle { get }
    @objc optional func shouldRunWith(tags:[String]) -> Bool
    @objc optional var continueTestingAfterFailure:Bool { get }
}
