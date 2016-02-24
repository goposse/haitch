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

public class NetLoggerCallProtocol : HttpCallProtocol {
  
  var dateFormatter: NSDateFormatter
  
  public init() {
    self.dateFormatter = NSDateFormatter()
    self.dateFormatter.dateStyle = .ShortStyle
  }
  
  
  // capture the request, log the destination with any relevant information, then act as a pass-thru
  public func handleRequest(request: Request) -> (gotoNext: Bool, request: Request, response: Response?) {
    let date: NSDate = NSDate()
    let wrappedMethod: String = "[\(request.method)]"
    let logString = "\(dateFormatter.stringFromDate(date)) \(wrappedMethod) \(request.fullUrlString())\n"
    print(logString)
    return (gotoNext: true, request: request, response: nil)
  }

  // ignore the response for now, pass on the callback
  public func handleResponse(response: Response) -> (gotoNext: Bool, response: Response) {
    return (gotoNext: true, response: response)
  }
  
}