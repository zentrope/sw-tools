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

  private func serveTree(_ root: String) -> ((HttpRequest) -> HttpResponse) {
    let defaults = ["index.html", "index.htm", "default.html"]

    return { r in
      let fpath = root + r.path.split("?")[0]
      let status = FileStat.exists(atPath: fpath)

      switch status {
      case .file :
        if let file = try? fpath.openForReading() {
          return .raw(200, "OK", [:], { writer in
            try? writer.write(file)
            file.close()
          })
        }
      case .directory:
        for page in defaults {
          let newPath = fpath + page
          if let file = try? newPath.openForReading() {
            return .raw(200, "OK", [:], { writer in
              try? writer.write(file)
              file.close()
            })
          }
        }
      case .notFound:
        return .notFound
      }
      return .notFound
    }
  }

  enum FileStat {
    // Maybe move this to some shared code area between all the tools

    case file
    case directory
    case notFound

    public static func exists(atPath: String) -> FileStat {
      var isDirectory = ObjCBool(true)
      let exists = FileManager.default.fileExists(atPath: atPath, isDirectory: &isDirectory)

      if !exists {
        return .notFound
      }
      if isDirectory.boolValue {
        return .directory
      }
      return .file
    }
  }

  private func newServer(_ folder: String) -> HttpServer {
    let server = HttpServer()
    let fm = FileManager.default

    // Allow JS routers to work....
    let mw = { (r: HttpRequest) -> HttpResponse? in

      let fpath = r.path.split("?")[0]
      NSLog("\(r.method) \(fpath)")

      if !fm.fileExists(atPath: folder + fpath) {
        r.path = "/"
      }
      return nil
    }

    server["/:path"] = serveTree(folder)
    server.middleware = [mw]

    return server
  }
}
