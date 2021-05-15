//
//  CucumberTestObservable.swift
//  CucumberSwift
//
//  Created by Tyler Thompson on 5/14/21.
//  Copyright © 2021 Tyler Thompson. All rights reserved.
//

import Foundation

public protocol CucumberTestObservable {
    var observers: [CucumberTestObserver] { get }
}
