//
//  HttpKeyPairTests.swift
//  Haitch
//
//  Created by Kevin Gray on 7/20/16.
//  Copyright © 2016 Posse Productions LLC. All rights reserved.
//

import XCTest
import Haitch

class HttpKeyPairTests: XCTestCase {
  
  // MARK: - Variables
  var verboseHttpKeyPair: HttpKeyPair!
  var verboseKey: String!
  var verboseValue: String!
  var percentEncodedVerboseKey: String!
  var percentEncodedVerboseValue: String!
  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
    verboseKey = "some weird key"
    verboseValue = "some VALUE!!! making sure it will need to be percent encoded."
    percentEncodedVerboseKey = verboseKey.escapedString()!
    percentEncodedVerboseValue = verboseValue.escapedString()!
    verboseHttpKeyPair = HttpKeyPair(key: verboseKey, value: verboseValue)
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  func testEscapedPropertiesSetOnInitialization() {
    XCTAssertEqual(
      verboseHttpKeyPair.escapedKey, String.escape(verboseKey),
      "escapedKey not set to expected value")
    
    XCTAssertEqual(
      verboseHttpKeyPair.escapedValueString, String.escape(verboseValue),
      "escapedValue not set to expected value")
  }
  
  func testEscapedPropertiesSetWhenPublicPropertiesSet() {
    verboseHttpKeyPair.key = "changing the key up."
    verboseHttpKeyPair.value = "and changing the key to this value!"
    
    XCTAssertEqual(
      verboseHttpKeyPair.escapedKey, String.escape("changing the key up."),
      "escapedKey property not set after key property was set")
    
    XCTAssertEqual(
      verboseHttpKeyPair.escapedValueString,
      String.escape("and changing the key to this value!"),
      "escapedValue property not set after value property was set")
  }
  
  func testToPartStringWithoutPrefixOrSuffix() {
    let partString = verboseHttpKeyPair.toPartString()
    
    XCTAssertEqual(
      "\(percentEncodedVerboseKey)=\(percentEncodedVerboseValue)", partString,
      "toPartString did not return expected value")
  }
  
  func testToPartStringWithPrefixAndNoSuffix() {
    let partString = verboseHttpKeyPair.toPartString(keyPrefix: "abc")
    
    XCTAssertEqual(
      "abc[\(percentEncodedVerboseKey)]=\(percentEncodedVerboseValue)", partString,
      "toPartString did not return expected value")
  }
  
  func testToPartStringWithSuffixAndNoPrefix() {
    let partString = verboseHttpKeyPair.toPartString(keySuffix: "123")
    
    XCTAssertEqual(
      "\(percentEncodedVerboseKey)123=\(percentEncodedVerboseValue)", partString,
      "toPartString did not return expected value")
  }
  
  func testToPartStringWithPrefixAndSuffix() {
    let partString = verboseHttpKeyPair.toPartString(keyPrefix: "abc", keySuffix: "123")
    XCTAssertEqual(
      "abc[\(percentEncodedVerboseKey)]123=\(percentEncodedVerboseValue)", partString,
      "toPartString did not return expected value")
  }
  
}
