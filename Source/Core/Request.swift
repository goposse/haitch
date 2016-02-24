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


public class RequestParams {
  
  private var params: [HttpKeyPair]!
  
  public init() {
    self.params = []
  }
  
  public init(dictionary: [String : String]) {
    self.params = []
    for (key, val) in dictionary {
      self.params.append(HttpKeyPair(key: key, value: val))
    }
  }
  
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

  public func append(name key: String, value: String) {
    self.params.append(HttpKeyPair(key: key, value: value))
  }
  
  public func allParams() -> [HttpKeyPair] {
    return self.params
  }
  
  
}



public class Request {
  
  private(set) public var url: String = String()
  private(set) public var params: RequestParams!      // any query string params.
                                                      // NB: these will NOT be passed to the request body
  private(set) public var method: String = String()
  private(set) public var headers: [String : String] = [String : String]()
  private(set) public var body: RequestBody?                 // the post body
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
