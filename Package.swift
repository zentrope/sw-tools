// swift-tools-version:4.0
//-----------------------------------------------------------------------------
// Copyright (c) 2018-present Keith Irwin
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published
// by the Free Software Foundation, either version 3 of the License,
// or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see
// <http://www.gnu.org/licenses/>.
//-----------------------------------------------------------------------------

import PackageDescription

let package = Package(
  name: "SwiftTools",
  dependencies: [
    .package(url: "https://github.com/apple/swift-package-manager.git", from: "0.2.0"),
    .package(url: "https://github.com/httpswift/swifter.git", .upToNextMajor(from: "1.4.0")),
  ],
  targets: [
    .target(name: "uuid", dependencies: ["UuidTool"]),
    .target(name: "UuidTool", dependencies: ["Utility"]),
    //
    .target(name: "webdev", dependencies: ["WebDevTool"]),
    .target(name: "WebDevTool", dependencies: ["Swifter", "Utility"]),
    //
    .testTarget(name: "ToolTests", dependencies: ["WebDevTool", "UuidTool"])
  ]
)
