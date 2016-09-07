//
//  Response.swift
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
 Base response class for a response received from an an HTTP request.
 */
open class Response {
  
  /// The request that was sent that resulted in this response.
  fileprivate (set) open var request: Request
  
  /// The data block of the response.
  fileprivate (set) open var data: Data? = nil
  
  /// The header values of the response.
  fileprivate (set) open var headers: [AnyHashable : Any]? = nil
  
  /// The HTTP status code of the response
  fileprivate (set) open var statusCode: Int = 0
  
  /// If there was an error while creatuing this Response object, it is set.
  fileprivate (set) open var error: Error? = nil
  
  /**
   Initializes a Response with another Response.  All values from the passed in Response
     are set as the values in this Response.
   
   - parameter response: The response to initialize with.
   */
  required public init(response: Response) {
    self.request = response.request
    self.data = response.data
    self.headers = response.headers
    self.statusCode = response.statusCode
    self.error = response.error
  }
  
  /**
   Initializer for the Response class.
   
   - parameter request: The request that resulted in this Response being created.
   - parameter data: The data block of the HTTP response.
   - parameter headers:  The headers of the HTTP response.
   - parameter statusCode: The status code of the HTTP response.
   - parameter error: Optional error value if an error has occured.
   */
  public init(request: Request, data: Data?, headers: [AnyHashable : Any]?, statusCode: Int, error: Error?) {
    self.request = request
    self.data = data
    self.headers = headers
    self.statusCode = statusCode
    self.error = error
  }
  
}
