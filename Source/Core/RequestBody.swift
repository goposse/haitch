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

/**
 The request body of an HTTP Request.  The default is x-www-form-urlencoded, but
   this class can easily be extended for any type, e.g. JsonRequestBody and BinaryRequestBody.
 
 - important: It is critically important to call build() on your RequestBody before 
     using it in an Http Request. Failing to do so will almost always result in a crash.
 */
open class RequestBody {
  
  // MARK: - body value storage
  
  /**
   Stores a key and value for populating a body form.
   */
  open class BodyValue {
    
    /// The key of the BodyValue
    open var name: String
    
    /// The value of the BodyValue
    open var value: AnyObject
    
    /**
     Initializer for a BodyValue
     
     - parameter name: The key of the BodyValue
     - parameter value: The value of the BodyValue
     */
    public init(name: String, value: AnyObject) {
      self.name = name
      self.value = value
    }
  }
  

  // MARK: - Properties
  
  /// The content type of the body, which describes the data contained within it.
  /// The base RequestBody content type is application/x-www-form-urlencoded.
  open var contentType: String!
  
  /// The content length of the data within the body.  It is set when the data
  /// property is set.
  fileprivate (set) open var contentLength: Int = -1
  
  /// The data of the body.  When set, it also sets the contentLength property.
  internal (set) open var data: Data! {
    didSet {
      self.contentLength = data.count
    }
  }
  
  /// An array of BodyValue objects that are used when building the RequestBody.
  internal (set) open var values: [BodyValue] = []
  
  // MARK: - Initialization
  
  /**
   Default initializer for the RequestBody class.  Below is how the properties are
     set:
   - values = []
   - contentType = "application/x-www-form-urlencoded"
   - data = NSData()
   */
  public init() {
    values = []
    contentType = "application/x-www-form-urlencoded"
    data = Data()
  }
  
  
  // MARK: - Value management  
  
  /**
   Appends a BodyValue to the values property.
   
   - parameter name: The key of the BodyValue that will be constructed and added to the
       values property.
   - parameter value: The value of the BodyValue that will be constructed and added to the
       values property.
   */
  open func addValue(_ name: String, value: AnyObject) {
    values.append(BodyValue(name: name, value: value))
  }
  
  /**
   Removes a value from the values property at the passed in index.
   
   - parameter atIndex: The index of the BodyValue to remove from the values property.
   */
  open func removeValue(atIndex index: Int) {
    values.remove(at: index)
  }
  
  /**
   Returns the data property of this RequestBody.
   
   - returns: The data property of this RequestBody.
   */
  open func bodyData() -> Data {
    return self.data
  }
  
  /**
   Returns the body headers of this RequestBody.
   
   - returns: The body headers of this RequestBody, always returns an empty dictionary.
   */
  open func bodyHeaders() -> [String : String] {
    return [:]
  }

  
  // MARK: - Params conversion
  
  /**
   Converts an array of BodyValue objects into a RequestParams object.  Used when building
     the RequestBody.
   
   - parameter values: An array of BodyValue objects that are used to build a RequestParams
       object.
   
   - returns: A RequestParams object built from the values that were passed in.
   */
  internal func bodyValuesToParams(_ values: [BodyValue]) -> RequestParams {
    let params: RequestParams = RequestParams()
    for bodyValue: BodyValue in values {
      params.append(name: bodyValue.name, value: "\(bodyValue.value)")
    }
    return params
  }
  
  
  // MARK: - Body build
  
  /**
   Generates the data for the RequestBody so that it can be used in an HTTP request.
     Also sets the contentLength of the RequestBody to the length of the data that is 
     generated.
   
   - important: It is critically important that you call this function before using
       this RequestBody in an HTTP request.
   */
  open func build() {
    self.data = generateData() as Data!
    self.contentLength = data.count
  }

  /**
   Generates data from the values property of the RequestBody.  First it converts
     the values property into a RequestParams object.  Then it uses that object to
     build a query string.  Then it encodes that string as NSData and returns it.
   
   - returns: The data that has been generated from this RequestBody.
   */
  internal func generateData() -> Data {
		var data = Data()
		let queryString: String = NetHelper.queryString(params: self.bodyValuesToParams(self.values))
		if let requestData = queryString.data(using: String.Encoding.utf8, allowLossyConversion: false) {
			data = requestData
		}
		return data
  }
  
}
