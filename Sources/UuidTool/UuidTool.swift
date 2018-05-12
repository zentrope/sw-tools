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
import Utility

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
      .map({ option.ucase ? $0 : $0.lowercased() })
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
    let ucase: Bool
  }

  private func parseArgs() throws -> Opts {
    let parser = ArgumentParser(
      commandName: "uuid",
      usage: "<options>",
      overview: "Generate UUIDs")

    let number: OptionArgument<Int> = parser.add(
      option: "--number",
      shortName: "-n",
      kind: Int.self,
      usage: "The number of UUID(s) to print.")

    let upperc: OptionArgument<Bool> = parser.add(
      option: "--uppercase",
      shortName: "-u",
      kind: Bool.self,
      usage: "Uppercase UUIDs.")

    let options = try parser.parse(self.arguments)
    return Opts(
      reps: self.setBounds(n: options.get(number) ?? 1),
      ucase: options.get(upperc) ?? false
    )
  }
}
