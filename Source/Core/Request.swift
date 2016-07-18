//
//  Request.swift
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

/**
 Wrapper around an array of HttpKeyPair that could be used to build a URL query or
   a request.
 
 - seealso: HttpKeyPair
 */
public class RequestParams {
  
  /// An array of HttpKeyPair values.
  private var params: [HttpKeyPair]!
  
  /**
   Default initializer for RequestParams.  Defaults the params property to an empty array.
   */
  public init() {
    self.params = []
  }
  
  /**
   Initializer that creates a RequestParams object with the passed in dictionary.  
     Fills the params property with the dictionary values and keys.
   
   - parameter dictionary: The dictionary of values to fill the params property 
       with.
   */
  public init(dictionary: [String : String]) {
    self.params = []
    for (key, val) in dictionary {
      self.params.append(HttpKeyPair(key: key, value: val))
    }
  }
  
  /**
   Subscript operator to access the params property and get the values associated
     with a certain key.
   
   - parameter name: The key of the HttpKeyPair values within the params property that
       you are interested in.  
   
   - returns: An array of Strings, populated from any value property of an HttpKeyPair
       that has a key peoperty that matches the name parameter passed in.  If there are
       no matches, an empty array is returned.
   */
  public subscript(name: String) -> [String] {
    get {
      let results: [HttpKeyPair] = self.params.filter { $0.key == name }
      var outArr: [String] = []
      if results.count > 0 {
        for keyValue: HttpKeyPair in results {
          outArr.append("\(keyValue.value)")
        }
      }
      return outArr
    }
  }

  /**
   Appends an HttpKeyPair, built from the passed in parameters, to the params
     property.
   
   - parameter name: The key of the HttpKeyPair that will be built and appended to
       the params property.
   
   - parameter key: The value of the HttpKeyPair that will be built and appended to
       the params property.
   */
  public func append(name key: String, value: String) {
    self.params.append(HttpKeyPair(key: key, value: value))
  }
  
  /**
   Returns the params property of this RequestParams object.
   
   - returns: The params property.
   */
  public func allParams() -> [HttpKeyPair] {
    return self.params
  }
  
}

/**
 A Request object is an object that contains all the information required to make
   an HTTP request, e.g. URL, method, headers, etc.
 */
public class Request {
  
  /// The base URL of the request.
  private(set) public var url: String = String()
  
  /// Query parameters added to the URL.
  ///
  /// - note: These are not passed into the body, they are formatted and appended
  ///   to the URL.
  private(set) public var params: RequestParams!
  
  /// The method used for the request, e.g. GET, POST, etc.
  /// - seealso: The Method struct within HttpClient.swift.
  private(set) public var method: String = String()
  
  /// The headers of the HTTP request.
  private(set) public var headers: [String : String] = [String : String]()
  
  /// The body of the HTTP request.
  private(set) public var body: RequestBody?
  
  /// The HTTP configuration of the request.
  private(set) public var httpClientConfiguration: HttpClientConfiguration?
  
  public init(builder: Request.Builder) {
    self.url = builder.url
    self.params = builder.params
    self.method = builder.method
    self.headers = builder.headers
    self.body = builder.body
    self.httpClientConfiguration = builder.httpClientConfiguration
  }
  
  public func newBuilder() -> Request.Builder {
    return Request.Builder()
      .url(url: self.url, params: self.params)
      .method(self.method)
      .headers(self.headers)
      .body(self.body)
      .httpClientConfiguration(self.httpClientConfiguration)
  }
  
  public func fullUrlString() -> String {
    return NetHelper.urlWithParams(self.url, params: self.params)
  }

  // MARK: - Request builder object
  public class Builder {
    
    internal var url: String!
    internal var params: RequestParams = RequestParams()
    internal var method: String = "GET"
    internal var headers: [String : String] = [String : String]()
    internal var body: RequestBody?
    internal var httpClientConfiguration: HttpClientConfiguration?
    
    public init() {
    }
    
    public func url(url: String) -> Request.Builder {
      self.url = url
      return self
    }

    public func url(url url: String, params: RequestParams) -> Request.Builder {
      self.url = url
      self.params = params
      return self
    }

    public func params(params params: RequestParams) -> Request.Builder {
      self.params = params
      return self
    }
    
    public func addParam(name name: String, value: String) -> Request.Builder {
      self.params.append(name: name, value: value)
      return self
    }
    
    public func method(method: String) -> Request.Builder {
      self.method = method
      return self
    }

    public func headers(headers: [String : String]) -> Request.Builder {
      self.headers = headers
      return self
    }
    
    public func updateHeader(key key: String, value: String) -> Request.Builder {
      self.headers.updateValue(value, forKey: key)
      return self
    }

    public func body(body: RequestBody?) -> Request.Builder {
      self.body = body
      return self
    }

    public func httpClientConfiguration(clientConfig: HttpClientConfiguration?) -> Request.Builder {
      self.httpClientConfiguration = clientConfig
      return self
    }

    public func build() -> Request {
      return Request(builder: self)
    }

  }
}
