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

public enum FileStat {

    case existsAndIsFile
    case existsAndIsDirectory
    case notFound

    public static func isFileAndExists(atPath: String) -> Bool {
        return exists(atPath: atPath) == .existsAndIsFile
    }

    public static func exists(atPath: String) -> FileStat {
        var isDirectory = ObjCBool(true)
        let exists = FileManager.default.fileExists(atPath: atPath, isDirectory: &isDirectory)

        if !exists {
            return .notFound
        }
        if isDirectory.boolValue {
            return .existsAndIsDirectory
        }
        return .existsAndIsFile
    }
}
