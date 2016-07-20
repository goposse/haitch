//
//  JsonRequestBody.swift
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
 Overrides the RequestBody class to build a RequestBody with JSON values.
 
 - important: It is critically important to call build() on your JsonRequestBody before
     using it in an Http Request. Failing to do so will almost always result in a crash.
 */
public class JsonRequestBody : RequestBody {
  
  /// The json object to be used when building the request body.  Default value is nil.
  public var json: AnyObject? = nil
  
  /**
   Default initializer for the JsonRequestBody.  Sets the contentType property to 
     "application/json".
   */
  public override init() {
    super.init()
    contentType = "application/json"
  }
  
  
  // MARK: - Request body data generation override
  
  /**
   Override of the generateData function.  Serializes the json property and creates
     an NSMutableData object from it, which is returned.
   
   - returns: The json property converted into an NSMutableData object.  If the json property is
       nil, it will just return NSMutableData().
   */
  public override func generateData() -> NSMutableData {
    var jsonData: NSMutableData = NSMutableData()
    if self.json != nil {
      if let conversionData: NSData = try? NSJSONSerialization.dataWithJSONObject(self.json!, options: NSJSONWritingOptions()) {
        jsonData = conversionData.mutableCopy() as! NSMutableData
      }
    }
    return jsonData
  }
  
  
}