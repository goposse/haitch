//
//  HttpClientConfiguration.swift
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
 The configuration used by an HttpClient or by a Request while making an HTTP request.
 */
public struct HttpClientConfiguration {
  
  /// The amount of time in seconds before a request is considered to be timed out.
  /// Defaults to 60 seconds.
  public var timeoutInterval: NSTimeInterval = 60.0
  
  /// Suffix used to denote multi-value form parameters.  Defaults to "[]"
  public var multiValueSuffix: String = "[]"
  
  /// Whether or not the client should set cookies.  Defaults to false.
  /// - seealso: NSURLSessionConfiguration.HTTPShouldSetCookies
  public var shouldSetCookies: Bool = false
  
  /// If true, return any request that the call protocols have returned
  /// and halt the network call immediately, if false, dont run any other protocols
  /// but continue execution of the call.  Defaults to false.
  public var shouldHaltOnProtocolSkip: Bool = false
  
  /// Treat non-success statuses as errors (will be anything > 400).  Defaults to false.
  public var treatStatusesAsErrors: Bool = false
  
  /**
   Default initializer for the HttpClientConfiguration.  Listed below are the default values 
     for each property.
     - timeoutInterval: 60.0
     - multiValueSuffix: "[]"
     - shouldSetCookies: false
     - shouldHaltOnProtocolSkip: false
     - treatStatusesAsErrors: false
   */
  public init() {
  }
}
