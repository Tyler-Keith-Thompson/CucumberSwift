//
//  BundleExtensions.swift
//  CucumberSwift
//
//  Created by Tyler Thompson on 1/10/21.
//  Copyright © 2021 Tyler Thompson. All rights reserved.
//

import Foundation

extension Bundle {
    var resolvedForSPM:Bundle {
        #if canImport(CucumberSwift_ObjC)
        return Bundle.module
        #else
        return self
        #endif
    }
}
