//
//  FeistyDBShell.swift
//  fdb
//
//  Created by Jason Jobe on 7/24/20.
//

import Foundation
import FeistyDB
import FeistyExtensions
import ArgumentParser

// Provide a place to retain the FeistyDB
// FIXME: Add support for multiple/attached databases
var global_db: Database?

@_cdecl("feisty_init")
func fiesty_init(_ db: SQLiteDatabaseConnection) {

    let db = Database(rawSQLiteDatabase: db)
    do {
        try db.addModule("calendar", type: CalendarModule.self)
        try db.addModule("cal", type: CalendarModule.self, eponymous: true)
        try db.addModule("series", type: SeriesModule.self, eponymous: true)
        
        let date_fmt = DateFormatter()
        date_fmt.dateFormat = "yyyy-MM-dd"

        try db.addFunction("datefmt", arity: 2) { values in
            
            guard case let DatabaseValue.text(fmt_s) = values[0] else { return .null }
            guard case let DatabaseValue.text(date_s) = values[1],
                  let date = date_fmt.date(from: date_s)
            else { return .null }

            let fmt = DateFormatter()
            fmt.dateFormat = fmt_s
            return .text(fmt.string(from: date))
        }

    } catch {
        Swift.print (error)
    }
    if global_db != nil {
        Swift.print("WARNING: Overwriting Global Feisty Database Instance")
    }
    global_db = db
}

@_cdecl("feisty_shell_cmd")
func feisty_shell_cmd(_ argv: UnsafePointer<UnsafePointer<Int8>?>?, _ argc: Int) -> Bool {
    
    let args = UnsafeBufferPointer(start: argv, count: Int(argc))
    let arguments = args.map { String(utf8String: $0.unsafelyUnwrapped).unsafelyUnwrapped }
    let options = Array(arguments.dropFirst())

    guard let pcmd = ShellCommands[arguments[0].lowercased()]
    else { return false }
    do {
        var command = try pcmd.parseAsRoot(options)
        try command.run()
    } catch {
        let help = pcmd.helpMessage()
        Swift.print(help)
    }
    return true
}
