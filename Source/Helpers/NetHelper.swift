//
//  NetHelper.swift
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
 Helper class for common network related tasks such as building query strings, 
   URL paths, etc.
 */
public class NetHelper {
  
  // MARK: - Query string helpers
  
  /**
   Build a query string from a RequestParams object.  For each HttpKeyPair in the object, 
     generates a part of the query and appends an ampersand.  The final ampersand is chopped off.
   
   - parameter params: A RequestParams object that will ne used to generated
       the query string.
   
   - returns: A query string built from the params parameter.
   */
  public class func queryString(params params: RequestParams) -> String {
    var queryStringVal: String = ""
    let parts: [HttpKeyPair] = params.allParams()
    for keyPair: HttpKeyPair in parts {
      let isMultiVal = params.isKeyMultiValue(key: keyPair.key)
      let prefix = keyPair.escapedKeyPrefix ?? ""
      var suffix = ""
      if isMultiVal {
        suffix = keyPair.escapedKeySuffix ?? ""
      }
      queryStringVal += "\(keyPair.toPartString(keyPrefix: prefix, keySuffix: suffix))&"
    }
    if queryStringVal.characters.count > 0 {
      queryStringVal = queryStringVal.chop()    // remove trailing '&' before returning
    }
    return queryStringVal
  }
  
  
  //MARK: - Path / URL helpers
  
  /**
   Creates a path by taking a given path and attaching url encoded params to it.
   
   - parameter path:  The path that will have the parameters attached to it.
   - parameter params: The RequestParams object that will be used to generate the query string
       that will be attached to the path.
   
   - returns: The path parameter appended with a '?' and the url encoded parameters
       from the params parameter.
   */
  public class func pathWithParams(path: String, params: RequestParams?) -> String {
    var outPath = path
    if let qsParams: RequestParams = params {
      let queryString: String = self.queryString(params: qsParams)
      outPath = "\(path)?\(queryString)"
    }
    return outPath
  }
  
  /**
   Creates a URL with parameters by taking a given URL and attaching url encodes parameters to it.
   
   - parameter urlString: The URL string to append the params parameter to.
   - parameter paramPrefix: The String to prefix the parameters with.
   - parameter params: The RequestParams that will be used to generate a query string
       that will be appened to the URL.
   
   - returns: The urlString parameter appended with the query string generated from the params
       parameter.
   */
  public class func urlWithParams(urlString: String, paramPrefix: String = "", params: RequestParams?) -> String {
    var fullPath = urlString
    var inParams: RequestParams = RequestParams()
    if params != nil {
      inParams = params!
    }
    let queryStringValue: String? = queryString(params: inParams)
    if String.isNotEmpty(queryStringValue) {
      // Check if the path already contains a query delimiter, if so, use the ampersand instead
      var appendChar: String = "?"
      if fullPath.rangeOfString("?") != nil {
        appendChar = "&"
      }
      fullPath = fullPath.stringByAppendingString("\(appendChar)\(queryStringValue!)")
    }
    return fullPath
  }
  
  /**
   Generates a path from an existing path appended by some number of parts that are passed in.
   
   - parameter path: The path that will be joined by the Strings in the parts parameter.
   - parameter parts: Some number of Strings that will be appened to the path parameter, 
       each separated by a '/'.
   
   - returns: The joined path built from the path parameter and the parts parameter,
       i.e. path/part[0]/part[1]/...
   */
  public static func joinedPath(path path: String, parts: String...) -> String {
    var finalPath: String = path
    if parts.count > 0 {
      if path.hasSuffix("/") {
        finalPath = finalPath.chop()
      }
      for part: String in parts {
        finalPath += "/\(part)"
      }
    }
    return finalPath
  }

}
