//
//  RequestBody.swift
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

public class RequestBody {
  
  // MARK: - body value storage
  public class BodyValue {
    
    public var name: String
    public var value: AnyObject
    
    public init(name: String, value: AnyObject) {
      self.name = name
      self.value = value
    }
  }
  

  // MARK: - Properties
  public var contentType: String!
  
  private (set) public var contentLength: Int = -1
  internal (set) public var data: NSData! {
    didSet {
      self.contentLength = data.length
    }
  }
  
  internal (set) public var values: [BodyValue] = []
  
  
  // MARK: - Initialization
  public init() {
    values = []
    contentType = "application/x-www-form-urlencoded"
    data = NSData()
  }
  
  
  // MARK: - Value management  
  public func addValue(name: String, value: AnyObject) {
    values.append(BodyValue(name: name, value: value))
  }
  
  public func removeValue(atIndex index: Int) {
    values.removeAtIndex(index)
  }
  
  public func bodyData() -> NSData {
    return self.data
  }
  
  public func bodyHeaders() -> [String : String] {
    return [:]
  }

  
  // MARK: - Params conversion
  internal func bodyValuesToParams(values: [BodyValue]) -> RequestParams {
    let params: RequestParams = RequestParams()
    for bodyValue: BodyValue in values {
      params.append(name: bodyValue.name, value: "\(bodyValue.value)")
    }
    return params
  }
  
  
  // MARK: - Body build
  public func build() {
    self.data = generateData()
    self.contentLength = data.length
  }

  internal func generateData() -> NSMutableData {
    var data: NSMutableData = NSMutableData()
    let queryString: String = NetHelper.queryString(paramsDictionary: self.bodyValuesToParams(self.values))
    if let stringData = queryString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
      data = stringData.mutableCopy() as! NSMutableData
    }
    return data
  }
  
}