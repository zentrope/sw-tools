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

import Foundation
//import Utility
import ArgParse

public struct UuidTool {

  public static let MIN_UUIDS = 1
  public static let MAX_UUIDS = 1024

  public init(arguments: [String] = CommandLine.arguments) {
    self.arguments = Array(arguments.dropFirst())
  }

  public func run() throws -> Array<String> {
    let option = try self.parseArgs()

    return stride(from: 0, to: option.reps, by: 1)
      .map({ _ in NSUUID().uuidString })
      .map({ option.uppercase ? $0 : $0.lowercased() })
  }

  // MARK: Internal

  private let arguments: Array<String>

  private func setBounds(n: Int) -> Int {
    if n < UuidTool.MIN_UUIDS {
      return UuidTool.MIN_UUIDS
    }
    if n > UuidTool.MAX_UUIDS {
      return UuidTool.MAX_UUIDS
    }
    return n
  }

  fileprivate struct Opts {
    // overkill: Trying this out just to learn.
    let reps: Int
    let uppercase: Bool
  }

  private let helptext = """
Generate UUID(s).

USAGE:

  uuid <options>

OPTIONS:
  --number, -n       The number of UUIDs to generate.
  --uppercased, -u   Uppercase the UUID(s).
  --help, -h         Display available options
"""

  private func parseArgs() throws -> Opts {
    let parser = ArgParser(helptext: helptext)
    parser.newFlag("uppercase u")
    parser.newInt("number n", fallback: 1)
    parser.parse(self.arguments)

    let reps = self.setBounds(n: parser.getInt("number"))
    let uc = parser.getFlag("uppercase")
    return Opts(reps: reps, uppercase: uc)
  }
}
