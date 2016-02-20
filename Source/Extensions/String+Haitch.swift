//
//  String+Haitch.swift
//  Haitch
//
//  Created by Posse in NYC
//  http://goposse.com
//
//  Copyright (c) 2015 Posse Productions LLC.
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

public extension String {
  
  public static func percentEncodedString(string: String) -> String {
    return percentEncodedString(string, encoding: NSUTF8StringEncoding)
  }
  
  /*
  Converts a string to its URL encoded form
  :returns: a URL encoded string
  Borrowed from Alamofire
  */
  public static func percentEncodedString(string: String, encoding: NSStringEncoding) -> String {
    let generalDelimiters = ":#[]@"       // does not include "?" or "/" due to RFC 3986 - Section 3.4
    let subDelimiters = "!$&'()*+,;="
    let legalURLCharactersToBeEscaped: CFStringRef = generalDelimiters + subDelimiters
    return CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, string as CFStringRef, nil,
      legalURLCharactersToBeEscaped as CFStringRef, CFStringConvertNSStringEncodingToEncoding(encoding)) as String
  }
  
  /**
   Remove the last character from a string
   - returns: The original string with the last character removed
   */
  internal func chop() -> String {
    let index: String.Index = self.endIndex.advancedBy(-1)
    return self.substringToIndex(index)
  }
  
  public static func escape(string: String) -> String {
    let generalDelimiters = ":#[]@"       // does not include "?" or "/" due to RFC 3986 - Section 3.4
    let subDelimiters = "!$&'()*+,;="
    let legalURLCharactersToBeEscaped: CFStringRef = generalDelimiters + subDelimiters
    return CFURLCreateStringByAddingPercentEscapes(nil, string, nil, legalURLCharactersToBeEscaped,
      CFStringBuiltInEncodings.UTF8.rawValue) as String
  }
  
  /**
   Retrieves any query string parameters from the string as a Dictionary of String keys and String values
   - returns: A Dictionary of any found parameters and their values, otherwise, an empty Dictionary
   */
  public func queryParameters() -> [HttpKeyPair] {
    var params: [HttpKeyPair] = []
    let startRange: Range<String.Index>? = self.rangeOfString("?")
    if startRange != nil {
      let queryRange: Range<String.Index> = Range<String.Index>(start: startRange!.startIndex.advancedBy(1),
        end: self.endIndex)
      let queryString: String = self.substringWithRange(queryRange)
      let stringPairs: [String] = queryString.componentsSeparatedByString("&")
      for pair: String in stringPairs {
        let splitPair: [String] = pair.componentsSeparatedByString("=")
        if splitPair.count == 2 {
          params.append(HttpKeyPair(key: splitPair[0], value: splitPair[1]))
        }
      }
    }
    return params
  }
  
  public func queryParametersDictionary() -> [String : String] {
    var params: [String : String] = [:]
    for keyPair: HttpKeyPair in queryParameters() {
      params.updateValue(keyPair.value as! String, forKey: keyPair.key)
    }
    return params
  }
  
  
  public func escapedString() -> String {
    return String.percentEncodedString(self, encoding: NSUTF8StringEncoding)
  }

  
  public static func isNotEmpty(string: String?) -> Bool {
    if string != nil {
      return ((string!).characters.count > 0)
    } else {
      return false
    }
  }
  
}
