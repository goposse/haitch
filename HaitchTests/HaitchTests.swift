//
//  HaitchTests.swift
//  HaitchTests
//
//  Created by Kevin Gray on 7/20/16.
//  Copyright © 2016 Posse Productions LLC. All rights reserved.
//

import XCTest
import Haitch

class HaitchTests: XCTestCase {
  
  static var oneOrMoreRequestParamTestsHaveFailed: Bool = false
  
  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  // MARK: - RequestParams tests
  func testRequestParams() {
    
  }
  
  // MARK: - NetHelper tests
  func testJoinedPathWithBuiltPathWithTrailingForwardSlash() {
    let pathToJoin = "/documents/files/data/"
    let joinedPath = NetHelper.joinedPath(path: pathToJoin, parts: "info", "user")
    XCTAssertEqual("/documents/files/data/info/user", joinedPath, "Result of joinedPath function did not match expected results.")
  }
  
  func testJoinedPathWithBuiltPathWithOutTrailingForwardSlash() {
    let pathToJoin = "/documents/files/data"
    let joinedPath = NetHelper.joinedPath(path: pathToJoin, parts: "info", "user")
    XCTAssertEqual("/documents/files/data/info/user", joinedPath, "Result of joinedPath function did not match expected results.")
  }
  
  func testJoinedPathWithEmptyPath() {
    let pathToJoin = ""
    let joinedPath = NetHelper.joinedPath(path: pathToJoin, parts: "info", "user")
    XCTAssertEqual("/info/user", joinedPath, "Result of joinedPath function did not match expected results.")
  }
  
  func testQueryStringWithNonMultiValRequestParamsAndNoPrefix() {
    XCTAssertFalse(HaitchTests.oneOrMoreRequestParamTestsHaveFailed)
    if HaitchTests.oneOrMoreRequestParamTestsHaveFailed {
      XCTFail("This test relies on the fact that the RequestParam tests have all passed!")
    } else {
      
    }
    
  }
}
