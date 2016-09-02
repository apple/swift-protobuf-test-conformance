import PackageDescription

let package = Package(
        name: "Conformance",
        dependencies: [
          .Package(url: "git@gitlab.sd.apple.com:tkientzle/SwiftProtobufRuntime.git",
                   Version(0,9,13))
        ]
)
