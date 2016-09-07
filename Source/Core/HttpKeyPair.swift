//
//  HttpKeyPair.swift
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
 Wraps HTTP key pair values into a struct, and maintains the escaped versions
   of the key and value.
 - seealso: String+Haitch.swift
 */
public struct HttpKeyPair {
  
  /// The key of the key value pair.  When set, the escapedKey is also set as
  /// the escaped string of the key.
  public var key: String = "" {
    didSet {
      self.escapedKey = String.escape(key)
    }
  }
  
  /// The value of the key value pair.  When set, the escapedValueString key is also
  /// set as the escaped string of the value.
  public var value: Any = "" {
    didSet {
      self.escapedValueString = String.escape("\(value)")
    }
  }
  /// The prefix for the key when it is converted to a part String. Defaults to an empty String.
  /// The escapedKeyPrefix property is set to the escaped version when this property is set.
  public var keyPrefix: String = "" {
    didSet {
      self.escapedKeyPrefix = String.escape(keyPrefix)
    }
  }
  
  /// The suffix for the key when it is converted to a part String. Defaults to an empty String.
  /// The escapedKeySuffix property is set to the escaped version when this property is set.
  public var keySuffix: String = "" {
    didSet {
      self.escapedKeySuffix = String.escape(keySuffix)
    }
  }
  
  /// The escapedKey is the key, but with all characters that are not permitted in
  /// a URL query replaced with percent encoding.
  fileprivate (set) public var escapedKey: String = ""
  
  /// The escapedValueString is the value, but with all characters that are not permitted in
  /// a URL query replaced with percent encoding.
  fileprivate (set) public var escapedValueString: String = ""
  
  /// The escapedKeyPrefix is the keyPrefix, but with all characters that are not permitted in
  /// a URL query replaced with percent encoding.
  fileprivate (set) public var escapedKeyPrefix: String = ""
  
  /// The escapedKeySuffix is the keySuffix, but with all characters that are not permitted in
  /// a URL query replaced with percent encoding.
  fileprivate (set) public var escapedKeySuffix: String = ""
  
  // MARK: - Initialization
  /**
   Initialier for HttpKeyPair
   
   - parameter key: The key of the HttpKeyPair.
   - parameter value: The value of the HttpKeyPair.
   */
  public init(key: String, value: Any, keySuffix: String = "", keyPrefix: String = "") {
    self.key = key
    self.value = value
    
    // These need to be set explicitly here.  didSet will not be called on variables 
    // until a set occurrs AFTER initialization.
    self.escapedKey = String.escape(key)
    self.escapedValueString = String.escape("\(value)")
    self.escapedKeyPrefix = String.escape(keyPrefix)
    self.escapedKeySuffix = String.escape(keySuffix)
  }
  
  // MARK: - Standard functions
  /**
   Returns a string that could be used to build a query from the HttpKeyPair.
   
   - parameter keyPrefix: Prefix for the key pair key value.
   - parameter keySuffix: Suffix for the key pair key value.
  
   - returns: Percent encoded query string part with format *({keyPrefix}[{key}]||{key}){keySuffix}={value}*
   */
  public func toPartString(keyPrefix: String = "", keySuffix: String = "") -> String {
		var key: String = self.escapedKey
    if keyPrefix != "" {
      key = "\(keyPrefix)[\(key)]"
    }
    return "\(key)\(keySuffix)=\(self.escapedValueString)"
  }
  
}

