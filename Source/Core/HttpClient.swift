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

/**
 A list of common HTTP methods that can be used when generating an HTTP request.
 */
public struct Method {
  /// The OPTIONS HTTP method.
  public static let OPTIONS: String = "OPTIONS"
  
  /// The GET HTTP method.
  public static let GET: String     = "GET"
  
  /// The HEAD HTTP method.
  public static let HEAD: String    = "HEAD"
  
  /// The POST HTTP method.
  public static let POST: String    = "POST"
  
  /// The PUT HTTP method.
  public static let PUT: String     = "PUT"
  
  /// The PATCH HTTP method.
  public static let PATCH: String   = "PATCH"
  
  /// The DELETE HTTP method.
  public static let DELETE: String  = "DELETE"
  
  /// The TRACE HTTP method.
  public static let TRACE: String   = "TRACE"
  
  /// The CONNECT HTTP method.
  public static let CONNECT: String = "CONNECT"
}

// MARK: - Callbacks

/// A callback used by the HTTPClient after a request has been executed.
public typealias HttpClientCallback = (_ response: Response?, _ error: Error?) -> Void

/**
 A class that is used to execute HTTP requests.  Can optionally add HttpCallProtocols to it,
   and configure it with an HttpClientConfiguration.
 */
open class HttpClient {

  // MARK: - Error configuration
  
  /**
     Various keys used for creating and configuring errors.
   */
  public struct ErrorConfig {
    /// The domain of the error codes generated from the HttpClient
    public static let Domain: String = "com.goposse.errors.net"
    /// A key used when populating the userInfo of an NSError that is generated.
    /// Corresponds to the eror code of the error.
    public static let InfoKeyErrorCode: String = "errorCode"
    /// A key used when populating the userInfo of an NSError that is generated. 
    /// Corresponds to the status code of the response
    public static let InfoKeyStatusCode: String = "statusCode"
    /// A key used when populating the userInfo of an NSError that is generated.
    /// Corresponds to the error message of the error.
    public static let InfoKeyMessage: String = "message"
  }
  
  // MARK: - Error codes
  
  /**
   Error codes that could be returned when executing an HttpClient request.
   
   - note: Other errors can also be returned from a request execution, such as a 
       time out, etc., but those are usually received from Foundation.  These error codes
       are just for local and other errors that are not be handled by Foundation.
   */
  public struct ErrorCodes {
    /// A response was received with a status code greater than 400.
    /// - note: If the HttpClientConfiguration has treatStatusesAsErrors set to true, this error will
    ///     be set in the execution callback for >400 HTTP statuses.
    public static let NonSuccessHTTPStatus: Int = 905531
    
    /// The URL to make a request was invalid.
    public static let BadUrl: Int = 905532
  }

  /// The NSURLSession used to make requests.
  fileprivate(set) open var urlSession: URLSession!
  
  /// The HTTP client configuration, uses the default if none is set.
  fileprivate(set) open var configuration: HttpClientConfiguration!

  /// The NSURLSession configuration, configured with the configuration property.
  /// If the configuration property is not set, the default HttpClientConfiguration is used.
  public var sessionConfiguration: URLSessionConfiguration!
  
  /// An array of registered call protocols.  Protocols are ran in order from the lowest index and
  /// upwards to the last index.
  /// - seealso: HttpCallProtocol.swift
  fileprivate (set) open var callProtocols = [HttpCallProtocol]()
  
  
  // MARK: - Initialization
  
  /**
   Intializes an HttpClient with a default cofiguration.
   */
  public init() {
    let configuration: HttpClientConfiguration = HttpClientConfiguration()
    self.configuration = configuration
    self.sessionConfiguration = self.sessionConfiguration(clientConfiguration: configuration)
    self.urlSession = URLSession(configuration: self.sessionConfiguration)
  }
  
  /**
   Intializes an HttpClient with the configuration that is passed in.
   
   - parameter configuration:  The HttpClientConfiguration to configure this HttpClient with.
   */
  public init(configuration: HttpClientConfiguration) {
    self.configuration = configuration
    self.sessionConfiguration = self.sessionConfiguration(clientConfiguration: configuration)
    self.urlSession = URLSession(configuration: self.sessionConfiguration)
  }
  
  
  // MARK: - Call Protocol Management
  
  /**
   Appends an HttpCallProtocol to the end of the callProtocols property.
   
   - parameter callProtocol: The HttpCallProtocol to append to the callProtocols property.
   */
  public func addCallProtocol(_ callProtocol: HttpCallProtocol) {
    callProtocols.append(callProtocol)
  }
  
  /**
   Removes an HttpCallProtocol from the callProtocols property at the index specified.
   
   - parameter atIndex: The index of the HttpCallProtocol to remove from the callProtocols property.
   */
  public func removeCallProtocol(atIndex index: Int) {
    callProtocols.remove(at: index)
  }

  /**
   Inserts a protocol to the callProtocols property at the index specified.
   
   - parameter atIndex: The index at wich to insert the HttpCallProtocol to the callProtocols property.
   - parameter callProtocol: The HttpCallProtocol to insert.
   */
  public func insertCallProtocol(atIndex index: Int, callProtocol: HttpCallProtocol) {
    callProtocols.insert(callProtocol, at: index)
  }

  
  // MARK: - Session / Client Configuration
  
  /**
   Helper function that generates an NSURLSessionConfiguration from the HttpClientConfiguration
     that is passed in.
   
   - parameter clientConfiguration: The HttpClientConfiguration to configure the returned
       NSURLSessionConfiguration with.
   
   - returns: An NSURLSessionConfiguration configured with the passed in HttpClientConfiguration.
   */
  fileprivate func sessionConfiguration(clientConfiguration: HttpClientConfiguration) -> URLSessionConfiguration {
    let sessionConfig = URLSessionConfiguration.default
    sessionConfig.timeoutIntervalForRequest = clientConfiguration.timeoutInterval
    sessionConfig.timeoutIntervalForResource = clientConfiguration.timeoutInterval
    sessionConfig.httpShouldSetCookies = clientConfiguration.shouldSetCookies
    return sessionConfig
  }
  
  
  // MARK: - Network Execution
  
  /**
   Executes an HTTP request with the passed in request.  Runs asynchronously and results
   are posted in the callback.  The passed in responseKind parameter is what is passed into the
   callback.
   
   - parameter request: The Request object that is passed through the protocols.  It is also the request
       executed, granted that a protcol has not modified it.
   - parameter responseKind: The type of Response that will be initialized with the data and passed
       into the callback.  Defaults to nil if not passed in, which will result in a base Response
       object passed into the callback.
   - parameter callback: The HttpClientCallback that will be called when the status of a
       response has been decided, either a successful response or an error.
   
   - returns: The NSURLSessionDataTask that was executef.  Could return nil if there was an error or
       a protocol has halted the request.
   */
  open func execute(request: Request, responseKind: Response.Type? = nil, callback: HttpClientCallback?) -> URLSessionDataTask? {
    
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
            callback!(response, nil)
          }
          return nil
        }
        break       // exit the loop
      }
    }
    
    // make the network call
    let fullUrl: String = modRequest.fullUrlString()
    
    if let url: URL = URL(string: fullUrl) {
      var urlRequest = URLRequest(url: url)
      urlRequest.httpMethod = request.method
      
      if modRequest.headers.count > 0 {
        for (key, value): (String, String) in modRequest.headers {
          urlRequest.addValue(value, forHTTPHeaderField: key)
        }
      }
      
      if modRequest.body != nil {
        urlRequest.httpBody = modRequest.body?.bodyData()
        urlRequest.setValue(modRequest.body?.contentType, forHTTPHeaderField: "Content-Type")
        if let bodyHeaders = modRequest.body?.bodyHeaders() {
          for (key, value): (String, String) in bodyHeaders {
            urlRequest.setValue(value, forHTTPHeaderField: key)
          }
        }
      }
      
      var httpSession: URLSession = self.urlSession
      if request.httpClientConfiguration != nil {
        httpSession = URLSession(configuration: sessionConfiguration(clientConfiguration: request.httpClientConfiguration!))
      }
      
      var dataTask: URLSessionDataTask!
      dataTask = httpSession.dataTask(with: urlRequest,
        completionHandler: { (data: Data?, urlResponse: URLResponse?, error: Error?) in
          
          var responseError = error
          var response: Response? = nil
					guard let httpResponse = urlResponse as? HTTPURLResponse else {
						callback?(nil, error)
						return
					}
					
					if (httpResponse.statusCode >= 400 && httpResponse.statusCode < 600) &&
						self.configuration.treatStatusesAsErrors {
						responseError = NSError(domain: ErrorConfig.Domain, code: httpResponse.statusCode,
								userInfo: [
										NSLocalizedDescriptionKey : "The server returned with an error status code (\(httpResponse.statusCode))"
								])
					}
					
					let headers: [AnyHashable : Any] = httpResponse.allHeaderFields
					response = Response(request: modRequest, data: data, headers: headers, statusCode: httpResponse.statusCode,
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
					callback?(response, responseError)
        })
      
      dataTask.resume()
      return dataTask
    } else {
      if callback != nil {
        let error: NSError = standardNetError(HttpClient.ErrorCodes.BadUrl,
          statusCode: 0, message: "The specified URL was invalid. Check and try again.",
          userInfo: nil)
        callback!(nil, error)
      }
    }
    
    return nil
  }
  
  
  // MARK: - Error management
  
  /**
   Helper function used to generate errors that are results of net errors, such as a bad status code.  
     The domain is always "com.goposse.errors.net"
   
   - parameter errorCode: The error code of the generated error.
   - parameter statusCode: The status code of the response
   - parameter message: The human readable message of the error.
   - parameter userInfo: A dictionary of information that is put into the userInfo of the NSError.
   
   - returns: The NSError generated using the parameters that are passed in.
   */
  fileprivate func standardNetError(_ errorCode: Int, statusCode: Int, message: String, userInfo: [String : Any]?) -> NSError {
		guard var errorInfo = userInfo else {
			return NSError(domain: HttpClient.ErrorConfig.Domain, code: errorCode,
			               userInfo: [String : Any]())
		}
		
    // append the error information to the error object
    errorInfo[HttpClient.ErrorConfig.InfoKeyMessage] = message
    errorInfo[HttpClient.ErrorConfig.InfoKeyStatusCode] = statusCode
    errorInfo[HttpClient.ErrorConfig.InfoKeyErrorCode] = errorCode
    
    return NSError(domain: HttpClient.ErrorConfig.Domain, code: errorCode, userInfo: errorInfo)
  }
  
  
}
