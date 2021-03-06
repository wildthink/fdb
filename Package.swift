// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "fdb",
    platforms: [
        .macOS(.v10_15),    //.v10_10 - .v10_15
    ],
    products: [
         .executable(name: "fdb", targets: ["fdb"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
//        .package(path: "/Users/jason/Development/frameworks/FeistyDB"),
        .package(url: "https://github.com/wildthink/FeistyDB", .branch("master")),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.0.1")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "fdb",
            dependencies: [
                "FeistyDB",
                .target(name: "SwiftAdditions"),
            ],
			cSettings: [
//				.unsafeFlags(["-Wno-ambiguous-macro"]),
				.define("FEISTY_DB_EXTENSION", to: "1"),
				.define("SQLITE_DQS", to: "0"),
				.define("SQLITE_THREADSAFE", to: "0"),
				.define("SQLITE_DEFAULT_MEMSTATUS", to: "0"),
				.define("SQLITE_DEFAULT_WAL_SYNCHRONOUS", to: "1"),
				.define("SQLITE_LIKE_DOESNT_MATCH_BLOBS"),
				.define("SQLITE_MAX_EXPR_DEPTH", to: "0"),
				.define("SQLITE_OMIT_DECLTYPE", to: "1"),
				.define("SQLITE_OMIT_DEPRECATED", to: "1"),
				.define("SQLITE_OMIT_PROGRESS_CALLBACK", to: "1"),
				.define("SQLITE_OMIT_SHARED_CACHE", to: "1"),
				.define("SQLITE_USE_ALLOCA", to: "1"),
				.define("SQLITE_OMIT_DEPRECATED", to: "1"),
				.define("SQLITE_ENABLE_PREUPDATE_HOOK", to: "1"),
				.define("SQLITE_ENABLE_SESSION", to: "1"),
				.define("SQLITE_ENABLE_FTS5", to: "1"),
				.define("SQLITE_ENABLE_RTREE", to: "1"),
				.define("SQLITE_ENABLE_STAT4", to: "1"),
				.define("SQLITE_ENABLE_SNAPSHOT", to: "1"),
				.define("SQLITE_ENABLE_JSON1", to: "1"),
                
				.define("SQLITE_EXTRA_INIT", to: "feisty_db_init"),
                .define("HAVE_READLINE", to: "1"),
            ],
            linkerSettings: [
                .linkedLibrary("readline"),
                .linkedLibrary("ncurses"),
            ]
        ),
        .target(
            name: "SwiftAdditions",
            dependencies: [
                .product(name: "FeistyDB", package: "FeistyDB"),
                .product(name: "FeistyExtensions", package: "FeistyDB"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]),
        .testTarget(
            name: "fdbTests",
            dependencies: ["fdb"]),
    ]
)
