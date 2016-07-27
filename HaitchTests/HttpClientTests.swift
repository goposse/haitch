//
//  HttpClientTests.swift
//  Haitch
//
//  Created by Kevin Gray on 7/25/16.
//  Copyright © 2016 Posse Productions LLC. All rights reserved.
//

import XCTest
import Haitch

class HttpClientTests: XCTestCase {
  
  var readyExpectation: XCTestExpectation!
  
  override func setUp() {
    super.setUp()
    readyExpectation = expectationWithDescription("ready")
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  // MARK: - Helper functions
  func getJSONDictionaryFromResponse(response: Response?) -> [String : AnyObject]? {
    if let jsonResponse = response as? JsonResponse {
      guard let jsonDict = jsonResponse.json as? [String : AnyObject]
          where jsonResponse.jsonError == nil else {
        return nil
      }
      return jsonDict
    }
    return nil
  }
  
  // MARK: - Tests
  func testSimpleRequestWithBaseResponseType() {
    let client: HttpClient = HttpClient()
    let timeoutInterval = client.configuration.timeoutInterval
    let url: String = "http://httpbin.org/"
    
    let request: Request = Request.Builder()
      .method(Haitch.Method.GET)
      .url(url)
      .build()
    
    client.execute(request: request) { (response, error) in
      self.readyExpectation.fulfill()
      
      XCTAssertNotNil(response?.data, "This data should not be nil")
      XCTAssertNil(error, "This error should be nil")
      XCTAssertEqual(response?.statusCode, 200)
      
      let headers = response?.headers as? [String : String]
      XCTAssertNotNil(headers)
      if headers != nil {
        // Test the headers have at least some values that we expect.  This could probably change,
        // So if these tests fail, we may need to find another way to test headers.
        XCTAssertEqual(headers!["Content-Type"], "text/html; charset=utf-8")
        if response?.data != nil {
          XCTAssertEqual(headers!["Content-Length"], "\(response!.data!.length)")
          XCTAssertEqual(headers!["Server"], "nginx")
        }
      }
    }
    
    waitForExpectationsWithTimeout(timeoutInterval) { (error: NSError?) in
      XCTAssertNil(error, "This error should be nil")
    }
  }
  
  func testSimpleJSONRequestWithNoQueryParameters() {
    let client: HttpClient = HttpClient()
    let timeoutInterval = client.configuration.timeoutInterval
    let url: String = "http://httpbin.org/get"
    
    let request: Request = Request.Builder()
      .method(Haitch.Method.GET)
      .url(url)
      .build()
    
    client.execute(request: request, responseKind: JsonResponse.self) { (response, error) in
      self.readyExpectation.fulfill()
    
      let jsonData: [String : AnyObject]? = self.getJSONDictionaryFromResponse(response)
      XCTAssertNotNil(jsonData, "This data should not be nil")
      if jsonData != nil {
        XCTAssert(jsonData!.keys.count > 0)
      }
    }
    
    waitForExpectationsWithTimeout(timeoutInterval) { (error: NSError?) in
      XCTAssertNil(error, "This error should be nil")
    }
  }
  
  func testSimpleJSONRequestWithMultipleUniqueQueryParameters() {
    let client: HttpClient = HttpClient()
    let timeoutInterval = client.configuration.timeoutInterval
    let url: String = "http://httpbin.org/get"
    let params: RequestParams = RequestParams(dictionary: ["a" : "bc", "1" : "23",
      "this is a key with spaces" : "?and a value with spaces and 😎?"])
    
    let request: Request = Request.Builder()
      .method(Haitch.Method.GET)
      .url(url)
      .params(params: params)
      .build()
    
    client.execute(request: request, responseKind: JsonResponse.self) { (response, error) in
      self.readyExpectation.fulfill()
      
      let jsonData: [String : AnyObject]? = self.getJSONDictionaryFromResponse(response)
      XCTAssertNotNil(jsonData, "This data should not be nil")
      if jsonData != nil {
        let argsDict = jsonData!["args"] as? [String : String]
        XCTAssertNotNil(argsDict)
        if argsDict != nil {
          XCTAssertEqual(argsDict!["a"], "bc")
          XCTAssertEqual(argsDict!["1"], "23")
          XCTAssertEqual(argsDict!["this is a key with spaces"], "?and a value with spaces and 😎?")
        }
      }
    }
    
    waitForExpectationsWithTimeout(timeoutInterval) { (error: NSError?) in
      XCTAssertNil(error, "This error should be nil")
      
    }
  }
  
  func testSimpleJSONRequestWithHodgePodgeOfUniqueAndNonUniqueQueryParameters() {
    let client: HttpClient = HttpClient()
    let timeoutInterval = client.configuration.timeoutInterval
    let url: String = "http://httpbin.org/get"
    let params: RequestParams = RequestParams(dictionary: ["Come on" : "and take a free ride",
      "abc" : "123", "😎" : "👹", "gotta catch" : "em all"])
    params.append(name: "Come on", value: "Eileen")
    params.append(name: "Come on", value: "over baby")
    params.append(name: "Come on", value: "and SLAM!")
    params.append(name: "😎", value: "👍")
    params.append(name: "gotta catch", value: "em all")
    
    let request: Request = Request.Builder()
      .method(Haitch.Method.GET)
      .url(url)
      .params(params: params)
      .build()
    
    client.execute(request: request, responseKind: JsonResponse.self) { (response, error) in
      self.readyExpectation.fulfill()
      
      let jsonData: [String : AnyObject]? = self.getJSONDictionaryFromResponse(response)
      XCTAssertNotNil(jsonData, "This data should not be nil")
      
      if jsonData != nil {
        let argsDict = jsonData!["args"] as? [String : AnyObject]
        XCTAssertNotNil(argsDict)
        if argsDict != nil {
          guard let comeOnArgs = argsDict!["Come on"] as? [String],
            let 😎args = argsDict!["😎"] as? [String],
            let catchEmArgs = argsDict!["gotta catch"] as? [String],
            let abc123String = argsDict!["abc"] as? String else {
              XCTFail("This guard statement should not fail")
              return
          }
          XCTAssertTrue(comeOnArgs.contains("and take a free ride") && comeOnArgs.contains("Eileen")
            && comeOnArgs.contains("over baby") && comeOnArgs.contains("and SLAM!"))
          XCTAssertTrue(😎args.contains("👍") && 😎args.contains("👹"))
          XCTAssertEqual(abc123String, "123")
          XCTAssertEqual(2, catchEmArgs.count)
          if catchEmArgs.count >= 2 {
            XCTAssertEqual("em all", catchEmArgs[0])
            XCTAssertEqual("em all", catchEmArgs[1])
          }
        }
      }
    }
    
    waitForExpectationsWithTimeout(timeoutInterval) { (error: NSError?) in
      XCTAssertNil(error, "This error should be nil")
    }
  }
  
  func testJSONRequestWithMultipleHeaders() {
    let client: HttpClient = HttpClient()
    let timeoutInterval = client.configuration.timeoutInterval
    let url: String = "http://httpbin.org/get"
    let headers: [String : String] = ["hello" : "world", "hola" : "mundo", "👋".escapedString()! : "🌎".escapedString()!]
    let request: Request = Request.Builder()
      .method(Haitch.Method.GET)
      .url(url)
      .headers(headers)
      .build()
    
    client.execute(request: request, responseKind: JsonResponse.self) { (response, error) in
      self.readyExpectation.fulfill()
      
      let jsonData: [String : AnyObject]? = self.getJSONDictionaryFromResponse(response)
      XCTAssertNotNil(jsonData, "This data should not be nil")
      
      if jsonData != nil {
        guard let responseHeaders = jsonData!["headers"] as? [String : String] else {
          XCTFail("Headers is nil, it shouldn't be")
          return
        }
        // For some reason, the headers come backw ith the first letter uppercased on the key
        XCTAssertEqual(responseHeaders["Hello"], "world")
        XCTAssertEqual(responseHeaders["Hola"], "mundo")
        XCTAssertEqual(responseHeaders["👋".escapedString()!], "🌎".escapedString())
      }
    }
    
    waitForExpectationsWithTimeout(timeoutInterval) { (error: NSError?) in
      XCTAssertNil(error, "This error should be nil")
    }
    
  }
  
  func testJSONRequestWithMultipleHeadersInWhichSomeWereUpdatedBeforeTheRequestWasSent() {
    let client: HttpClient = HttpClient()
    let timeoutInterval = client.configuration.timeoutInterval
    let url: String = "http://httpbin.org/get"
    var headers: [String : String] = ["hello" : "world", "hola" : "mundo"]
    headers.updateValue("solarsystem", forKey: "hello")
    let request: Request = Request.Builder()
      .method(Haitch.Method.GET)
      .url(url)
      .headers(headers)
      .updateHeader(key: "whatsup", value: "woild")
      .build()
    
    client.execute(request: request, responseKind: JsonResponse.self) { (response, error) in
      self.readyExpectation.fulfill()
      
      let jsonData: [String : AnyObject]? = self.getJSONDictionaryFromResponse(response)
      XCTAssertNotNil(jsonData, "This data should not be nil")
      
      if jsonData != nil {
        guard let responseHeaders = jsonData!["headers"] as? [String : String] else {
          XCTFail("Headers is nil, it shouldn't be")
          return
        }
        XCTAssertEqual(responseHeaders["Hello"], "solarsystem")
        XCTAssertEqual(responseHeaders["Hola"], "mundo")
        XCTAssertEqual(responseHeaders["Whatsup"], "woild")
      }
    }
    
    waitForExpectationsWithTimeout(timeoutInterval) { (error: NSError?) in
      XCTAssertNil(error, "This error should be nil")
    }
  }
  
  // More things to test...Test normal response, Call protocols, time outs, configurations, body parameters, headers
  // expected errors, behavior with certain configurations, & symbols in parameters
  
}
