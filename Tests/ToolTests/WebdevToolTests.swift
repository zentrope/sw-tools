import Foundation
import XCTest
import WebDevTool

class WebdevToolTests: XCTestCase {

  func testPending() throws {
    // not sure what to test. Maybe create a temp dir,
    // add an index file to it, start the server, create
    // a client, then verify that what should be a 404
    // actually serves "/".
    XCTAssertEqual(1, 1)
  }

  func testServesSubdirectories() {
  }

  func testCliParams() {
    
  }
}
