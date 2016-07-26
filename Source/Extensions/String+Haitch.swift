//
//  String+Haitch.swift
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
 Extends the String class to add various HTTP related functionality and other 
 functionality to simplify code within Haitch.
 */
public extension String {
  /**
   Removes the last character from a string.
   
   - returns: The original string with the last character removed.  If there are no characters
       to remove, this string is returned, unmodified.
   */
  internal func chop() -> String {
    if self.characters.count > 0 {
      let index: String.Index = self.endIndex.advancedBy(-1)
      return self.substringToIndex(index)
    }
    return self
  }

  /**
   Checks if the passed in string is empty or not
   
   - parameter string: The string to check for emptiness.
   
   - returns: True if the string passed in is not nil and it has a character
      count that is greater than zero.  Otherwise, it will return false.
  */
  internal static func isNotEmpty(string: String?) -> Bool {
    if string != nil {
      return ((string!).characters.count > 0)
    }
    return false
  }

  /**
   Given the passed string, returns it with percent encoded characters in place
     of characters that are not allowed within a URL query.
   
   - note: This is the same as calling
       string.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
   
   - parameter string: The string to add percent encoding to.
   
   - returns: The passed in string with percent encoding in place of characters
       that are not allowed within a URL query.
   */
  public static func escape(string: String) -> String? {
    return string.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
  }
  
  /**
   If the instance of the String is formatted as a URL query, this function returns
     any query parameters within the query as an array of HttpKeyPair objects.
   
   - returns: An array of HttpKeyPair objects for any found parameters and their 
       values. If none are found, it returns an empty array.
   */
  public func queryParameters() -> [HttpKeyPair] {
    var params: [HttpKeyPair] = []
    let startRange: Range<String.Index>? = self.rangeOfString("?")
    if startRange != nil {
      let queryRange: Range<String.Index> = startRange!.startIndex.advancedBy(1) ..< self.endIndex
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
  
  /**
   Returns the escaped version of the String instance, meaning it returns a String
     with percent encoded characters in place of characters that are not allowed 
     within a URL query.
   
   - note: This is the same as calling String.escape(self)
   
   - returns: The instance of the String with percent encoding in place of characters
     that are not allowed within a URL query.
   */
  public func escapedString() -> String? {
    return String.escape(self)
  }

  /**
   Returns the unescaped version of the String instance, meaning it returns a String
     with all percent encoded parts replaced with the matching UTF-8 characters.
   
   - note: This is the same as calling self.stringByRemovingPercentEncoding
   
   - returns: The instance of the String with all percent encoding replaced by
     the matching UTF-8 characters.
   */
  public func unescapedString() -> String? {
    return self.stringByRemovingPercentEncoding
  }

}
