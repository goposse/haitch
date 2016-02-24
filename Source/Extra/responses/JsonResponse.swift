//
//  JsonResponse.swift
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

public class JsonResponse: Response {

  private (set) public var json: AnyObject?
  private (set) public var jsonError: AnyObject?
  
  public convenience required init(response: Response) {
    self.init(request: response.request, data: response.data, statusCode: response.statusCode, error: response.error)
  }
  
  public override init(request: Request, data: NSData?, statusCode: Int, error: NSError?) {
    super.init(request: request, data: data, statusCode: statusCode, error: error)
    self.populateFromResponseData(data)
  }

  private func populateFromResponseData(data: NSData?) {
    if data != nil {
      var jsonError: NSError? = nil
      var jsonObj: AnyObject?
      do {
        jsonObj = try NSJSONSerialization.JSONObjectWithData(data!,
                options: [NSJSONReadingOptions.AllowFragments, NSJSONReadingOptions.MutableContainers, NSJSONReadingOptions.MutableLeaves])
      } catch let error as NSError {
        jsonError = error
        jsonObj = nil
      }
      self.jsonError = jsonError
      self.json = jsonObj
    }
  }
  
}
