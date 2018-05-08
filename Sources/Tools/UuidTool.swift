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

public final class UuidTool {

  public static let MIN_UUIDS = 1
  public static let MAX_UUIDS = 1024

  private let arguments: Array<String>
  
  public init(arguments: [String] = CommandLine.arguments) {
    self.arguments = Array(arguments.dropFirst())
  }

  private func setBounds(n: Int) -> Int {
    if n < UuidTool.MIN_UUIDS {
      return UuidTool.MIN_UUIDS
    }
    if n > UuidTool.MAX_UUIDS {
      return UuidTool.MAX_UUIDS
    }
    return n
  }

  public func run() throws -> Array<String> {
    
    let parser = ArgumentParser(
      usage: "<options>",
      overview: "Generate a UUID.")
    
    let number: OptionArgument<Int> = parser.add(
      option: "--number",
      shortName: "-n",
      kind: Int.self,
      usage: "The number of UUIDs to generate.")
    
    let uppercased: OptionArgument<Bool> = parser.add(
      option: "--uppercased",
      shortName: "-u",
      kind: Bool.self,
      usage: "Uppercase the UUID(s).")
    
    let options = try parser.parse(self.arguments)
    
    let reps = self.setBounds(n: options.get(number) ?? UuidTool.MIN_UUIDS)
    let uc = options.get(uppercased) == true

    return stride(from: 0, to: reps, by: 1)
      .map({ _ in NSUUID().uuidString })
      .map({ uc ? $0.uppercased() : $0 })
  }
}
