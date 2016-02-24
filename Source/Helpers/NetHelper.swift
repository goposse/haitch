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

public class NetHelper {
  
  // MARK: - Query string helpers
  public class func queryString(paramsDictionary params: RequestParams) -> String {
    return queryString(prefix: nil, params: params, multiValueSuffix: nil)
  }

  public class func queryString(prefix prefix: String?, params: RequestParams, multiValueSuffix: String?) -> String {
    var queryStringVal: String = ""
    let parts: [HttpKeyPair] = params.allParams()
    for keyPair: HttpKeyPair in parts {
      queryStringVal += "\(keyPair.toPartString())&"
    }
    if queryStringVal.characters.count > 0 {
      queryStringVal = queryStringVal.chop()    // remove trailing '&' before returning
    }
    return queryStringVal
  }
  
  
  /**
    takes an array or a dictionary of query string parameter key / values and converts it to an
    array of properly formatted query string parts. The strings in the returned array 
    will be one of *two* formats:
  
    1. if prefix IS NOT nil, "keyPrefix[key]=url encoded value"
    2. if IS nil, "key=url encoded value"
  
    - parameter keyPrefix:  if passing an array or set, this will be used as the key, if passing a dictionary the
        prefix will be used in the form of prefix[key] (optional)
    - parameter params:  the parameter values that will be used to construct the query string parts
    - parameter multiValueSuffix:  the multi-value suffix to apply to array/multi-value values
  
    - returns: an array of HttpKeyPair
  */
  public class func queryStringPartsArray(keyPrefix keyPrefix: String?, value: AnyObject, multiValueSuffix: String? = "[]") -> [HttpKeyPair] {

    var partsArray: Array<HttpKeyPair> = Array<HttpKeyPair>()       // the query string parts
    
    if let paramsDict = value as? Dictionary<String, AnyObject> {
    
      // it is important that we sort the keys each time to preserve some sort consistency in
      // the reproducability of the code
      let sortedKeys = Array(paramsDict.keys).sort(<)
      for paramKey in sortedKeys {
        if let nestedValue: AnyObject = paramsDict[paramKey] {
          var key = paramKey
          if (keyPrefix != nil) {
            key = "\(keyPrefix!)[\(key)]"
          }
          partsArray.appendContentsOf(queryStringPartsArray(keyPrefix: key, value: nestedValue, multiValueSuffix: nil))
        }
      }
    
    } else if let paramsArray = value as? Array<AnyObject> {
      
      if keyPrefix != nil {
        let key: String = "\(keyPrefix)\(multiValueSuffix)"
        for nestedValue in paramsArray {
          partsArray.appendContentsOf(queryStringPartsArray(keyPrefix: key, value: nestedValue, multiValueSuffix: nil))
        }
      }
      
    } else {

      // at this point of execution the keyPrefix will be the actual key so we should just pass it through
      // we will still check to make sure it isn't nil incase someone does something stupid
      if let key: String = keyPrefix {
        partsArray.append(HttpKeyPair(key: key, value: value))
      }
    }
    
    return partsArray
  }
  
  
  //MARK: - Path / URL helpers
  public class func pathWithParams(path: String, params: RequestParams?) -> String {
    var outPath = path
    if let qsParams: RequestParams = params {
      let queryString: String = self.queryString(paramsDictionary: qsParams)
      outPath = "\(path)?\(queryString)"
    }
    return outPath
  }
  
  
  public class func urlWithParams(urlString: String, params: RequestParams?) -> String {
    return urlWithParams(urlString, paramPrefix: nil, params: params)
  }
  
  public class func urlWithParams(urlString: String, paramPrefix: String?, params: RequestParams?) -> String {
    var fullPath = urlString
    var inParams: RequestParams = RequestParams()
    if params != nil {
      inParams = params!
    }
    let queryStringValue: String? = queryString(prefix: paramPrefix, params: inParams, multiValueSuffix: nil)
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
