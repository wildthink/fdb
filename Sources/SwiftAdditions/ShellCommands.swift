//
//  File.swift
//  
//
//  Created by Jason Jobe on 9/21/20.
//

import Foundation
import FeistyDB
import FeistyExtensions
import ArgumentParser

let ShellCommands: [String:ParsableCommand.Type] = [
    "repeat": Repeat.self
]

struct Repeat: ParsableCommand {

    @Flag(help: "Include a counter with each repetition.")
    var includeCounter = false
    
    @Option(name: .shortAndLong, help: "The number of times to repeat 'phrase'.")
    var count: Int?
    
    @Argument(help: "The phrase to repeat.")
    var phrase: String
    
    mutating func run() throws {
        let repeatCount = count ?? 10
        
        for i in 1...repeatCount {
            if includeCounter {
                print("\(i): \(phrase)")
            } else {
                print(phrase)
            }
        }
    }
}

