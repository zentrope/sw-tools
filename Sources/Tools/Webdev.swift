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

import Basics

public struct Webdev {

    public static let DEFAULT_PORT = 3000

    public init(arguments: [String] = CommandLine.arguments) {
        self.arguments = Array(arguments.dropFirst())
    }

    public func run() throws {
        let config = try self.parseArgs()
        let server = HTTPServer()
        NSLog("Serving web content in '\(config.folder)' on port \(config.port).")
        try server.start(port: config.port,
                         handler: makeHandler(folder: config.folder));
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
            usage: "The port (default \(Webdev.DEFAULT_PORT)).")

        let folder: OptionArgument<String> = parser.add(
            option: "--folder",
            shortName: "-f",
            kind: String.self,
            usage: "The folder to serve (default is CWD).")

        let options = try parser.parse(self.arguments)
        let cwd = FileManager.default.currentDirectoryPath

        let p = options.get(port) ?? Webdev.DEFAULT_PORT
        var f = options.get(folder) ?? cwd // TODO: expand tilde
        if f.hasSuffix("/") {
            f.removeLast()
        }

        return Config(folder: f, port: p)
    }

    private func makeHandler(folder: String) -> HTTPRequestHandler {

        let defaults = ["index.html", "index.htm", "default.html"]

        return { (request: HTTPRequest, response: HTTPResponseWriter) -> HTTPBodyProcessing in

            let target = request.target
            NSLog("\(request.method) \(target)")
            let fpath = folder + target.split(around: "?").0

            let headers = HTTPHeaders(dictionaryLiteral:
                (HTTPHeaders.Name.server, "webdev"),
                (HTTPHeaders.Name.cacheControl, "no-cache"))

            // TODO: What about the mime-type?
            switch FileStat.exists(atPath: fpath) {
            case .existsAndIsFile:
                response.writeFile(fpath, headers: headers)

            case .existsAndIsDirectory:
                response.writeIfFound(fpath, headers: headers, pages: defaults)

            case .notFound:
                response.writeIfFound(folder + "/", headers: headers, pages: defaults)
            }
            return HTTPBodyProcessing.discardBody
        }
    }
}

extension HTTPResponseWriter {
    // Extend the ResponseWriter with some convenience methods.

    public func writeIfFound(_ root: String, headers: HTTPHeaders, pages: [String]) {
        for page in pages {
            let path = root + page;
            if FileStat.isFileAndExists(atPath: path) {
                writeFile(path, headers: headers)
                return
            }
        }
        writeError(.notFound, headers: headers, error: "No index page found.")
    }

    public func writeFile(_ path: String, headers: HTTPHeaders) {
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            writeHeader(status: .ok, headers: headers)
            writeBody(data)
            done()
        } catch {
            writeError(.internalServerError, headers: headers, error: "data error \(error)")
        }
    }

    private func writeError(_ status: HTTPResponseStatus, headers: HTTPHeaders, error: String) {
        writeHeader(status: status, headers: headers)
        writeBody(error)
        done()
    }
}
