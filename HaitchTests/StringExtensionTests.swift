//
//  StringExtensionTests.swift
//  Haitch
//
//  Created by Kevin Gray on 7/21/16.
//  Copyright © 2016 Posse Productions LLC. All rights reserved.
//

import XCTest
@testable import Haitch

class StringExtensionTests: XCTestCase {
  
  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  func testChopWithAverageString() {
    let testString = "heresastringtotest=andchop&"
    let choppedString = testString.chop()
    XCTAssertEqual("heresastringtotest=andchop", choppedString)
  }
  
  func testChopWithOneCharacterString() {
    let testString = "a"
    let choppedString = testString.chop()
    XCTAssertEqual("", choppedString)
  }
  
  func testChopWithEmojis() {
    let testString = "👋🍾🎉👍💣"
    let getThatBombOutOfHere = testString.chop()
    XCTAssertEqual("👋🍾🎉👍", getThatBombOutOfHere)
  }
  
  func testChopWithEmptyString() {
    let testString = ""
    let choppedString = testString.chop()
    XCTAssertEqual("", choppedString)
  }
  
  func testIsNotEmptyWithSingleCharacterString() {
    let testString = "a"
    XCTAssertTrue(String.isNotEmpty(testString))
  }
  
  func testIsNotEmptyWithMultipleCharacterString() {
    let testString = "abc123"
    XCTAssertTrue(String.isNotEmpty(testString))
  }
  
  func testIsNotEmptyWithEmptyString() {
    let testString = ""
    XCTAssertFalse(String.isNotEmpty(testString))
  }
  
  func testIsNotEmptyWithNilString() {
    let testString: String? = nil
    XCTAssertFalse(String.isNotEmpty(testString))
  }
  
  func testQueryParametersWithNoParams() {
    let link: String = "https://www.google.com"
    let queryParams: [HttpKeyPair] = link.queryParameters()
    XCTAssertTrue(queryParams.count == 0, "There should be no values in queryParams")
  }
  
  func testQueryParametersWithSingleParam() {
    let vidLink: String = "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
    let queryParams: [HttpKeyPair] = vidLink.queryParameters()
    XCTAssertTrue(queryParams.count == 1, "There should only be one key pair in here")
    for param in queryParams {
      XCTAssertEqual("v", param.key)
      XCTAssertEqual("dQw4w9WgXcQ", param.value.description)
    }
  }
  
  func testQueryParametersWithMultipleUniqueParams() {
    let vidLink: String = "https://www.youtube.com/watch?v=dQw4w9WgXcQ&time=9920&color=red"
    let queryParams: [HttpKeyPair] = vidLink.queryParameters()
    XCTAssertTrue(queryParams.count == 3, "There should be 3 key pairs in here")
    let expectedVals = [("v", "dQw4w9WgXcQ"), ("time", "9920"), ("color", "red")]
    for (index, param) in queryParams.enumerate() {
      XCTAssertEqual(expectedVals[index].0, param.key)
      XCTAssertEqual(expectedVals[index].1, param.value.description)
    }
  }
  
  func testQueryParametersWithMultipleNonUniqueParams() {
    let vidLink: String = "https://www.youtube.com/watch?v=dQw4w9WgXcQ&v=abc123&color=red&v=12345"
    let queryParams: [HttpKeyPair] = vidLink.queryParameters()
    XCTAssertTrue(queryParams.count == 4, "There should be 4 key pairs in here")
    let expectedVals = [("v", "dQw4w9WgXcQ"), ("v", "abc123"), ("color", "red"), ("v", "12345")]
    for (index, param) in queryParams.enumerate() {
      XCTAssertEqual(expectedVals[index].0, param.key)
      XCTAssertEqual(expectedVals[index].1, param.value.description)
    }
  }
  
}
