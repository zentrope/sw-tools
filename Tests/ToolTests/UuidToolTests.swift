import Foundation
import XCTest
import Tools

class UidToolTests: XCTestCase {
  // I'm not super interested in testing this kind of thing,
  // but these are useful reminder/examples about how to set
  // up tests like this.

  func testRepetitions() throws {
    let data = [22, 44, 1, 13, 6]
    for num in data {
      let tool = UuidTool(arguments: ["app", "-n", String(num)])
      let uuids = try tool.run()
      XCTAssertEqual(uuids.count, num)
    }
  }

  func testUpperCaseUuids() throws {
    let tool = UuidTool(arguments: ["app", "-u", "-n", "1"])
    let uuids = try tool.run()
    XCTAssertEqual(uuids.count, 1)

    let uuid = uuids[0]
    XCTAssertEqual(uuid, uuid.uppercased())
    XCTAssertNotEqual(uuid, uuid.lowercased())
  }

  func testBadParams() throws {
    let tool = UuidTool(arguments: ["app", "-x", "foo"])
    XCTAssertThrowsError(try tool.run())
  }

  func testBadNumberParam() throws {
    let tool = UuidTool(arguments: ["app", "-n", "foo"])
    XCTAssertThrowsError(try tool.run())
  }
}
