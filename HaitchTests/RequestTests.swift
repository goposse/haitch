//
//  RequestTests.swift
//  Haitch
//
//  Created by Kevin Gray on 7/25/16.
//  Copyright © 2016 Posse Productions LLC. All rights reserved.
//

import XCTest
@testable import Haitch


class RequestTests: XCTestCase {
  
  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  // MARK: - RequestParams tests
  func testRequestParamsDefaultInitHasZeroParams() {
    let requestParams = RequestParams()
    XCTAssertEqual(requestParams.allParams().count, 0)
  }
  
  func testRequestParamsDictionaryInit() {
    var params: [String : String] = [:]
    params["abc"] = "123"
    params["haitch"] = "httpLibrary"
    params["bulba"] = "saur"
    params["uke"] = "lele"
    params["four score"] = "and seven years ago"
    
    let requestParams = RequestParams(dictionary: params)
    XCTAssertEqual(5, requestParams.allParams().count)
    let allParams = requestParams.allParams()
    for httpKeyPairParam in allParams {
      XCTAssertEqual("\(httpKeyPairParam.value)", params[httpKeyPairParam.key])
    }
  }
  
  func testRequestParamsSubscriptWithUniqueValue() {
    var params: [String : String] = [:]
    params["abc"] = "123"
    params["haitch"] = "httpLibrary"
    params["bulba"] = "saur"
    
    let requestParams = RequestParams(dictionary: params)
    XCTAssertFalse(requestParams.isKeyMultiValue(key: "bulba"))
    
    let values = requestParams["haitch"]
    if values.count == 1 {
      XCTAssertEqual(values[0], "httpLibrary")
    } else {
      XCTFail("There should be 1 parameter in the values array.")
    }
  }
  
  func testRequestParamsSubscriptWithUniqueValueButTheParamsHaveMultipleNonUniqueValues() {
    var params: [String : String] = [:]
    params["abc"] = "123"
    params["haitch"] = "httpLibrary"
    params["bulba"] = "saur"
    
    let requestParams = RequestParams(dictionary: params)
    requestParams.append(name: "bulba", value: "bulb")
    requestParams.append(name: "bulba", value: "bulllll")
    
    let values = requestParams["haitch"]
    if values.count == 1 {
      XCTAssertEqual(values[0], "httpLibrary")
    } else {
      XCTFail("There should be 1 parameter in the values array.")
    }
  }
  
  func testRequestParamsSubscriptWithMultipleValues() {
    var params: [String : String] = [:]
    params["abc"] = "123"
    params["haitch"] = "httpLibrary"
    params["bulba"] = "saur"
    
    let requestParams = RequestParams(dictionary: params)
    requestParams.append(name: "bulba", value: "bulb")
    requestParams.append(name: "bulba", value: "saur")
    requestParams.append(name: "bulba", value: "saur")
    requestParams.append(name: "bulba", value: "bulllll")
    
    XCTAssertTrue(requestParams.isKeyMultiValue(key: "bulba"))
    
    let values = requestParams["bulba"]
    if values.count == 5 {
      XCTAssertEqual(values[0], "saur")
      XCTAssertEqual(values[1], "bulb")
      XCTAssertEqual(values[2], "saur")
      XCTAssertEqual(values[3], "saur")
      XCTAssertEqual(values[4], "bulllll")
    } else {
      XCTFail("There should be 4 parameter in the values array.")
    }
  }
  
  func testRequestParamsSubscriptWithNoMatches() {
    var params: [String : String] = [:]
    params["abc"] = "123"
    params["haitch"] = "httpLibrary"
    params["bulba"] = "saur"
    
    let requestParams = RequestParams(dictionary: params)
    
    XCTAssertFalse(requestParams.isKeyMultiValue(key: "chaaar"))
    
    let values = requestParams["chaaar"]
    XCTAssertEqual(0, values.count)
  }
  
  
  
}
