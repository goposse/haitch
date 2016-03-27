//
//  HttpClient.swift
//  Haitch
//
//  Created by Posse in NYC
//  http://goposse.com
//
//  Copyright (c) 2016 Posse Productions LLC.
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  * Redistributions of source code must retain the above copyright notice, this
//    list of conditions and the following disclaimer.
//  * Redistributions in binary form must reproduce the above copyright notice,
//    this list of conditions and the following disclaimer in the documentation
//    and/or other materials provided with the distribution.
//  * Neither the name of the Posse Productions LLC, Posse nor the
//    names of its contributors may be used to endorse or promote products
//    derived from this software without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL POSSE PRODUCTIONS LLC (POSSE) BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

import Foundation

// MARK: - Http method definitions

public struct Method {
  public static let OPTIONS: String = "OPTIONS"
  public static let GET: String     = "GET"
  public static let HEAD: String    = "HEAD"
  public static let POST: String    = "POST"
  public static let PUT: String     = "PUT"
  public static let PATCH: String   = "PATCH"
  public static let DELETE: String  = "DELETE"
  public static let TRACE: String   = "TRACE"
  public static let CONNECT: String = "CONNECT"
}

// MARK: - Callbacks
public typealias HttpClientCallback = (response: Response?, error: NSError?) -> Void


public class HttpClient {

  // MARK: - Error configuration
  public struct ErrorConfig {
    public static let Domain: String = "com.goposse.errors.net"
    public static let InfoKeyErrorCode: String = "errorCode"
    public static let InfoKeyStatusCode: String = "statusCode"
    public static let InfoKeyMessage: String = "message"
  }
  
  // MARK: - Error codes
  public struct ErrorCodes {
    public static let NonSuccessHTTPStatus: Int = 905531
    public static let BadUrl: Int = 905532
  }

  private(set) public var urlSession: NSURLSession!
  
  // your http client configuration, or the default
  private(set) public var configuration: HttpClientConfiguration!

  // Your NSURLSession configuration, or the system default
  public var sessionConfiguration: NSURLSessionConfiguration!
  
  // Any registered call protocols - see HttpCallProtocol.swift
  private (set) public var callProtocols = [HttpCallProtocol]()
  
  
  // MARK: - Initialization
  public init() {
    let configuration: HttpClientConfiguration = HttpClientConfiguration()
    self.configuration = configuration
    self.sessionConfiguration = self.sessionConfiguration(clientConfiguration: configuration)
    self.urlSession = NSURLSession(configuration: self.sessionConfiguration)
  }
  
  public init(configuration: HttpClientConfiguration) {
    self.configuration = configuration
    self.sessionConfiguration = self.sessionConfiguration(clientConfiguration: configuration)
    self.urlSession = NSURLSession(configuration: self.sessionConfiguration)
  }
  
  
  // MARK: - Call Protocol Management
  public func addCallProtocol(callProtocol: HttpCallProtocol) {
    callProtocols.append(callProtocol)
  }
  
  public func removeCallProtocol(atIndex index: Int) {
    callProtocols.removeAtIndex(index)
  }

  public func insertCallProtocol(atIndex index: Int, callProtocol: HttpCallProtocol) {
    callProtocols.insert(callProtocol, atIndex: index)
  }

  
  // MARK: - Session / Client Configuration
  private func sessionConfiguration(clientConfiguration clientConfiguration: HttpClientConfiguration) -> NSURLSessionConfiguration {
    let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
    sessionConfig.timeoutIntervalForRequest = clientConfiguration.timeoutInterval
    sessionConfig.timeoutIntervalForResource = clientConfiguration.timeoutInterval
    sessionConfig.HTTPShouldSetCookies = clientConfiguration.shouldSetCookies
    return sessionConfig
  }
  
  
  // MARK: - Network Execution
  public func execute(request request: Request, callback: HttpClientCallback?) -> NSURLSessionDataTask? {
    return execute(request: request, responseKind: nil, callback: callback)
  }
  
  public func execute(request request: Request, responseKind: Response.Type?, callback: HttpClientCallback?) -> NSURLSessionDataTask? {
    
    var modRequest: Request = request
    var response: Response? = nil
    
    // pass the cummulatively modified (starting with original) request through the call protocols for any 
    // alteration. check for halt.
    for callProtocol: HttpCallProtocol in self.callProtocols {
      let cont: (gotoNext: Bool, request: Request, response: Response?) = callProtocol.handleRequest(modRequest)
      modRequest = cont.request
      if cont.response != nil {
        response = cont.response
      }
      if cont.gotoNext == false {
        if self.configuration.shouldHaltOnProtocolSkip == true {
          // call protocol says stop
          if callback != nil {
            callback!(response: response, error: nil)
          }
          return nil
        }
        break       // exit the loop
      }
    }
    
    // make the network call
    let fullUrl: String = modRequest.fullUrlString()
    
    if let url: NSURL = NSURL(string: fullUrl) {
      let urlRequest: NSMutableURLRequest = NSMutableURLRequest(URL: url)
      urlRequest.HTTPMethod = request.method
      
      if modRequest.headers.count > 0 {
        for (key, value): (String, String) in modRequest.headers {
          urlRequest.addValue(value, forHTTPHeaderField: key)
        }
      }
      
      if modRequest.body != nil {
        urlRequest.HTTPBody = modRequest.body?.bodyData()
        urlRequest.setValue(modRequest.body?.contentType, forHTTPHeaderField: "Content-Type")
        if let bodyHeaders = modRequest.body?.bodyHeaders() {
          for (key, value): (String, String) in bodyHeaders {
            urlRequest.setValue(value, forHTTPHeaderField: key)
          }
        }
      }
      
      var httpSession: NSURLSession = self.urlSession
      if request.httpClientConfiguration != nil {
        httpSession = NSURLSession(configuration: sessionConfiguration(clientConfiguration: request.httpClientConfiguration!))
      }
      
      var dataTask: NSURLSessionDataTask!
      dataTask = httpSession.dataTaskWithRequest(urlRequest,
        completionHandler: { (data: NSData?, urlResponse: NSURLResponse?, error: NSError?) in
          
          var responseError: NSError? = error
          var response: Response? = nil
          if let httpResponse: NSHTTPURLResponse = urlResponse as? NSHTTPURLResponse {
            if response?.statusCode >= 400 && self.configuration.treatStatusesAsErrors {
              responseError = NSError(domain: ErrorConfig.Domain, code: httpResponse.statusCode,
                userInfo: [
                  NSLocalizedDescriptionKey : "The server returned with an error status code"
                ])
            }
            response = Response(request: modRequest, data: data, statusCode: httpResponse.statusCode,
              error: responseError)
            if responseKind != nil {
              response = responseKind!.init(response: response!)
            }

            // NOTE: The response with the modified Response type (if any) will be passed into the call protocols
            //       and not the orignal (generic) Response
            for callProtocol: HttpCallProtocol in self.callProtocols {
              let cont: (gotoNext: Bool, response: Response) = callProtocol.handleResponse(response!)
              response = cont.response
              if cont.gotoNext == false {
                break
              }
            }
          }
          if callback != nil {
            callback!(response: response, error: responseError)
          }
        })
      
      dataTask.resume()
      return dataTask
    } else {
      if callback != nil {
        let error: NSError = standardNetError(HttpClient.ErrorCodes.BadUrl,
          statusCode: 0, message: "The specified URL was invalid. Check and try again.",
          userInfo: nil)
        callback!(response: nil, error: error)
      }
    }
    
    return nil
  }
  
  
  // MARK: - Error management
  private func standardNetError(errorCode: Int, statusCode: Int, message: String, userInfo: [NSObject : AnyObject]?) -> NSError {
    var errorInfo: [NSObject : AnyObject] = [NSObject : AnyObject]()
    if userInfo != nil {
      errorInfo = userInfo!
    }
    
    // append the error information to the error object
    errorInfo[HttpClient.ErrorConfig.InfoKeyMessage] = message
    errorInfo[HttpClient.ErrorConfig.InfoKeyStatusCode] = statusCode
    errorInfo[HttpClient.ErrorConfig.InfoKeyErrorCode] = errorCode
    
    return NSError(domain: HttpClient.ErrorConfig.Domain, code: errorCode, userInfo: userInfo)
  }
  
  
}
