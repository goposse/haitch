//
//  HttpCallProtocol.swift
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
 An object that conforms to this protocol can be notified before a request is executed,
   and when a response is received.  It must be added to the HTTPClient that is making 
   requests and receiving responses.
 */
public protocol HttpCallProtocol {
  
  /**
   Called before an HTTP request is executed.
   
   - parameter request: The request that is about to be executed.
   
   - returns: Should return a tuple populated with the following information:
   
       gotoNext: Bool - Depending on the HTTPClientConfiguration, this could have different effects.
         If gotoNext is false, all subsequent protocols are NOT run.  If gotoNext is false AND the configuration
         has shouldHaltOnProtocolSkip set to true, it also will also halt the request, and use the 
         response value of the tuple on the response callback.  If gotoNext is true, the next protocol
         is run and business continues as usual.
   
       request: Request - The request that will be used in all subsequent HttpCallProtocols and as the HTTP request
         if it is not overwritten by another protocol.
   
       response: Response? - See the description of gotoNext, but this can be used for an early
         response without a network call if desired.
   */
  func handleRequest(request: Request) -> (gotoNext: Bool, request: Request, response: Response?)
  
  /**
   Called when an HTTP response has been received.
   
   - parameter response: The response that was received.
   
   - returns: Should return a tuple populated with the following information:
   
       gotoNext: Bool - If false, all subsequent protocols are NOT run.  If true, the next
           the next protocol is run.
   
       response: Response - The response that will be used by all subsequent protocols,
           and if it is not overwritten by a subsequent protocol, the response that will be 
           used in the callback.
   */
  func handleResponse(response: Response) -> (gotoNext: Bool, response: Response)
  
}