//
//  GherkinDSL.swift
//  CucumberSwift
//
//  Created by thompsty on 7/23/20.
//  Copyright © 2020 Tyler Thompson. All rights reserved.
//

import Foundation
public protocol GherkinDSL {
    init()
}

public extension GherkinDSL {
    @discardableResult fileprivate init(handler: () -> Void) {
        self.init()
        #warning("Should not immediately execute")
        handler()
    }

    @discardableResult init(I handler: @autoclosure () -> Void,
                            line:Int = #line,
                            column:Int = #column,
                            file:StaticString = #file,
                            function: StaticString = #function) {
        //insane idea, find the #line, and the #filepath. Read that line from the file
        //find the name of the closure, set that as the name of the step
        //create a concrete step object in the parser from all this crazy
        //if no scenario found use the #function name to create one
        //if no feature found use the #file name to create one
        print(file)
        print(function)
        self.init(handler: handler)
        readStepName(lineNumber: line, column: column, filePath: file)
    }
    
    @discardableResult init(my handler: @autoclosure () -> Void) {
        self.init(handler: handler)
    }

    @discardableResult init(some handler: @autoclosure () -> Void) {
        self.init(handler: handler)
    }

    @discardableResult init(a handler: @autoclosure () -> Void) {
        self.init(handler: handler)
    }

    @discardableResult init(the handler: @autoclosure () -> Void) {
        self.init(handler: handler)
    }
    
    func readStepName(lineNumber:Int, column:Int, filePath:StaticString) {
        guard let fileContents = try? String(contentsOfFile: String(filePath), encoding: .utf8) else { return }

        let lines = fileContents.components(separatedBy: .newlines)
        guard lines.indices.contains(lineNumber-1) else { return }

        var line = lines[lineNumber-1]
        guard column+1 < line.count else { return }

        line.removeFirst(column)
        line.removeLast()

        print(line)
    }

}
