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
  
  func testChopWithUnicodeCharacters() {
    let testString = "👋🍾🎉👍💣"
    let getThatBombOutOfHere = testString.chop()
    XCTAssertEqual("👋🍾🎉👍", getThatBombOutOfHere)
  }
  
  func testChopWithEmptyString() {
    let testString = ""
    let choppedString = testString.chop()
    XCTAssertEqual("", choppedString)
  }
  
  
    
  
}
