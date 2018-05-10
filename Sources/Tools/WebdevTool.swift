//
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
//

import Foundation
import Utility
import Swifter
import Dispatch

public final class WebdevTool {

  public static let DEFAULT_PORT = 3000

  public init(arguments: [String] = CommandLine.arguments) {
    self.arguments = Array(arguments.dropFirst())
  }

  public func run() throws {
    let (folder, port) = try self.parseArgs()
    let lock = DispatchSemaphore(value: 0)
    let server = self.newServer(folder)

    do {
      NSLog("Serving web content in '\(folder)' on port \(port).")
      try server.start(in_port_t(port), forceIPv4: true)
      lock.wait()
    } catch {
      NSLog("Server error: \(error).")
      lock.signal()
    }
  }

  // MARK: Internal

  private let arguments: Array<String>

  private func parseArgs() throws -> (String, Int) {

    let parser = ArgumentParser(
      usage: "OPTIONS",
      overview: "Serve simple web content simply")

    let port: OptionArgument<Int> = parser.add(
      option: "--port",
      shortName: "-p",
      kind: Int.self,
      usage: "The port (default \(WebdevTool.DEFAULT_PORT)).")

    let folder: OptionArgument<String> = parser.add(
      option: "--folder",
      shortName: "-f",
      kind: String.self,
      usage: "The folder to serve (default is CWD).")

    let options = try parser.parse(self.arguments)
    let cwd = FileManager.default.currentDirectoryPath

    let p = options.get(port) ?? WebdevTool.DEFAULT_PORT
    let f = options.get(folder) ?? cwd

    return (f, p)
  }

  private func newServer(_ folder: String) -> HttpServer {
    let server = HttpServer()
    let fm = FileManager.default
    let mw = { (r: HttpRequest) -> HttpResponse? in
      // Allow JS routers to work....
      NSLog("\(r.method) \(r.path)")
      if !fm.fileExists(atPath: folder + r.path) {
        r.path = "/"
      }
      return nil
    }

    let defaults = ["index.html", "index.htm", "default.html"]
    server["/:path"] = shareFilesFromDirectory(folder, defaults: defaults)
    server.middleware = [mw]

    return server
  }
}
