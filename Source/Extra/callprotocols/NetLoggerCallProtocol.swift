//
//  NetLoggerCallProtocol.swift
//  PosseKit
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
 An HttpCallProtocol class that logs out-going network requests.
 */
open class NetLoggerCallProtocol : HttpCallProtocol {
  
  /// A date formatter used when logging requests.  Defaults the dateStyle to .ShortStyle.
  var dateFormatter: DateFormatter
  
  /**
   Default initializer for a NetLoggerCallProtocol.  Creates a default NSDateFormatter,
     and sets its dateStyle to .ShortStyle.
   */
  public init() {
    self.dateFormatter = DateFormatter()
    self.dateFormatter.dateStyle = .short
  }
  
  /**
   One of the protocol functions.  Intercepts the request and logs the date, HTTP method,
     and the string returned from fullUrlString() of the request.  
   
   - returns: A tuple with the following information:
   
       gotoNext: Bool - Always returns true.
   
       request: Request - Always returns the request that was passed in.
   
       response: Response? - Always returns nil.
   */
  open func handleRequest(_ request: Request) -> (gotoNext: Bool, request: Request, response: Response?) {
    let date: Date = Date()
    let wrappedMethod: String = "[\(request.method)]"
    let logString = "\(dateFormatter.string(from: date)) \(wrappedMethod) \(request.fullUrlString())\n"
    print(logString)
    return (gotoNext: true, request: request, response: nil)
  }

  /**
   One of the protocol functions.  Right now it is only here because it is required to be 
     implemented.  Does not modify or do anything.
   
   - returns: A tuple with the following information:
   
     gotoNext: Bool - Always returns true.
   
     response: Response - Always returns the response that was passed in.
   */
  open func handleResponse(_ response: Response) -> (gotoNext: Bool, response: Response) {
    return (gotoNext: true, response: response)
  }
  
}
