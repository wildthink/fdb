# fdb

Have you ever wanted your own easily customized SQLite command line tool using Swift? Well, with FeistyDB and a little bit glue, now you can!

FDB links the SQLite command line `shell.c` with the Swift FeistyDB SQLite framework making it easy to extend the SQLite functions and virtual tables using Swift. If you're curious about why you might be interested in SQLite for your applications see the Backstory.

As part of the integration the Swift Argument Parser is included and hooked into the command line dot-commands to process any commands not recognized by the standard SQLite suite.

Included for demonstration is a Swift implementation of the Series Virtual Table.

### Project Setup

Download or clone the project, `cd` to the project directory and execute a `make instll` to download, patch, and install SQLite's `shell.c` as the project's `main.c`. Then just `swift build` and run.

```
git clone https://github.com/wildthink/fdb
cd fdb
make install
swift build
```

### The Glue

Only two C-to-Swift functions are needed for the SQLite shell to call out to. The first gives us the opportunity  to customize the database engine itself. This is where we add our custom functions and/or modules; all implemented in Swift thanks to FeistyDB.

```swift
func fiesty_init(_ db: SQLiteDatabaseConnection)
	...
        try db.addModule("series", type: SeriesModule.self, eponymous: true)
        try db.addFunction("myFunc", arity: 2) { ... }
```
The second simply converts the incoming `char **` C -String array into a Swift `[String]`, using the first argument as a key into the `ShellCommands` dictionary and then runs the `ParsableCommand` if found with the remaining arguments.

```swift
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
```

Add your own Commands to the project remembering to add them to the `ShellCommands` dictionary in `ShellCommands.swift` .

```swift
let ShellCommands: [String:ParsableCommand.Type] = [
    "repeat": Repeat.self
]

struct Repeat: ParsableCommand {
	...
}
```



### SQLite Functions

Comming Soon.

### Series Virtual Table

Comming Soon.

### ArgumentParser

ArgumentParser is the "new open-source library that makes it straightforward — even enjoyable! — to parse command-line arguments in Swift." See the following to learn more and how to write your own.

- https://swift.org/blog/argument-parser/
- https://www.andyibanez.com/posts/writing-commandline-tools-argumentparser-part1/
- https://www.enekoalonso.com/articles/handling-commands-with-swift-package-manager
- https://www.avanderlee.com/swift/command-line-tool-package-manager/



### Backstory

Coming Soon.

### About FeistyDB

Original Project: https://github.com/feistydog/FeistyDB

With WildThink Extensions (used herein): https://github.com/wildthink/FeistyDB

A powerful and performant Swift interface to [SQLite](https://sqlite.org/) featuring:

- Type-safe and type-agnostic database values.
- Thread-safe synchronous and asynchronous database access.
- Full support for [transactions](https://github.com/feistydog/FeistyDB#perform-a-transaction) and savepoints.
- [Custom SQL functions](https://github.com/feistydog/FeistyDB#custom-sql-functions), including aggregate and window functions.
- [Custom collating sequences](https://github.com/feistydog/FeistyDB#custom-collating-sequences).
- Custom commit, rollback, update, and busy handler hooks.
- Custom virtual tables.
- Custom FTS5 tokenizers.
- Optional support for pre-update hooks and [sessions](https://www.sqlite.org/sessionintro.html)

FeistyDB allows fast, easy database access with robust error handling. It is not a general-purpose object-relational mapper.