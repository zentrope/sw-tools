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
import HTTP

public struct WebdevTool {

  public static let DEFAULT_PORT = 3000

  public init(arguments: [String] = CommandLine.arguments) {
    self.arguments = Array(arguments.dropFirst())
  }

  public func run() throws {
    let config = try self.parseArgs()
    let server = HTTPServer()
    NSLog("Serving web content in '\(config.folder)' on port \(config.port).")
    try server.start(port: config.port, handler: makeHandler(folder: config.folder));
    RunLoop.current.run()
  }

  // MARK: Internal

  private let arguments: Array<String>

  fileprivate struct Config {
    let folder: String
    let port: Int
  }

  private func parseArgs() throws -> Config {

    let parser = ArgumentParser(
      commandName: "webdev",
      usage: "<options>",
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
    var f = options.get(folder) ?? cwd // TODO: expand tilde
    if f.hasSuffix("/") {
      f.removeLast()
    }

    return Config(folder: f, port: p)
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

  private func makeHandler(folder: String) -> (HTTPRequest, HTTPResponseWriter) -> HTTPBodyProcessing {
    let defaults = ["index.html", "index.htm", "default.html"]

    return { (request: HTTPRequest, response: HTTPResponseWriter) -> HTTPBodyProcessing in

      let target = request.target
      NSLog("\(request.method) \(target)")
      let fpath = folder + target.split(around: "?").0
      let status = FileStat.exists(atPath: fpath)

      let headers = HTTPHeaders(dictionaryLiteral:
        (HTTPHeaders.Name.server, "webdev"),
        (HTTPHeaders.Name.cacheControl, "no-cache"))

      let tryAlternatives = { (root: String) -> Bool in
        for page in defaults {
          let path = root + page;
          if FileStat.exists(atPath: path) == .file {
            response.writeHeader(status: .ok, headers: headers)
            response.writeBody(path)
            response.done()
            return true
          }
        }
        return false
      }

      // TODO: What about the mime-type?
      switch status {
      case .file:
        response.writeHeader(status: .ok, headers: headers)
        response.writeBody(fpath)
        response.done()

      case .directory:
        let _ = tryAlternatives(fpath)

      case .notFound:
        if !tryAlternatives(folder + "/") {
          response.writeHeader(status: .notFound, headers: headers)
          response.done()
        }
      }
      return HTTPBodyProcessing.discardBody
    }
  }
}

extension HTTPResponseWriter {

  // Fragile, but, basically, writes the contents of the path to the
  // response.
  public func writeBody(_ path: String) {
    do {
      let data = try Data(contentsOf: URL(fileURLWithPath: path))
      return writeBody(data)
    } catch {
      NSLog("data error \(error)")
      return writeBody("data error \(error)")
    }
  }
}
