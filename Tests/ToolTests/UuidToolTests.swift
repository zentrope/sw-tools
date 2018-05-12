import Foundation
import XCTest
import UuidTool

class UidToolTests: XCTestCase {
  // I'm not super interested in testing this kind of thing,
  // but these are useful reminder/examples about how to set
  // up tests like this.

  private func runTool(args: [String]) throws -> Array<String> {
    return try UuidTool(arguments: ["_"] + args).run()
  }

  func testRepetitions() throws {
    let data = [22, 44, 1, 13, 6]
    for num in data {
      let count = try runTool(args: ["-n", String(num)]).count
      XCTAssertEqual(count, num)
    }
  }

  func testUpperCaseUuids() throws {
    let upperCasedUuid = try runTool(args: ["-u"])[0]
    XCTAssertEqual(upperCasedUuid, upperCasedUuid.uppercased())
    XCTAssertNotEqual(upperCasedUuid, upperCasedUuid.lowercased())

    let lcUuid = try runTool(args: [])[0]
    XCTAssertEqual(lcUuid, lcUuid.lowercased())
    XCTAssertNotEqual(lcUuid, lcUuid.uppercased())
  }

  func testToLowResetsToZero() throws {
    XCTAssertEqual(try runTool(args: ["-n", "0"]).count, UuidTool.MIN_UUIDS)
    XCTAssertEqual(try runTool(args: ["-n", "-2"]).count, UuidTool.MIN_UUIDS)
  }

  func testToHighResetsBounds() throws {
    XCTAssertEqual(try runTool(args: ["-n", "1025"]).count, UuidTool.MAX_UUIDS)
    XCTAssertEqual(try runTool(args: ["-n", "200000"]).count, UuidTool.MAX_UUIDS)
  }

  //
  // Revive these when the arg parse lib I use doesn't force
  // a process exit.
  //
  //  func testBadParams() throws {
  //    let tool = UuidTool(arguments: ["app", "-x", "foo"])
  //    XCTAssertThrowsError(try tool.run())
  //  }
  //
  //  func testBadNumberParam() throws {
  //    let tool = UuidTool(arguments: ["app", "-n", "foo"])
  //    XCTAssertThrowsError(try tool.run())
  //  }
}
