//
//  MultipartRequestBody.swift
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

public class MultipartRequestBody : RequestBody {
  
  public struct MimeType {
    public static let ImagePng: String   = "image/png"
    public static let ImageJpeg: String  = "image/jpeg"
    public static let ImageJpegP: String = "image/pjpeg"
    public static let ImageGif: String   = "image/gif"
    public static let ImageBmp: String   = "image/bmp"
    public static let ImageTiff: String  = "image/tiff"

    private static let defaultExts = [
      ImagePng :   "png",
      ImageJpeg :  "jpeg",
      ImageJpegP : "pjpeg",
      ImageGif :   "gif",
      ImageBmp :   "bmp",
      ImageTiff :  "tiff",
    ]
    
    public static func defaultExtension(mimeType: String?) -> String {
      var ext: String = "file"
      if mimeType != nil {
        if let matchExt = defaultExts[mimeType!] {
          ext = matchExt
        }
      }
      return ext
    }
  }
  
  private class Part : BodyValue {
    static let HeaderContentDisposition = "Content-Disposition"
    static let HeaderContentType = "Content-Type"
    
    var fileName: String?
    var mimeType: String?
    
    init(name: String, data: NSData, fileName: String?, mimeType: String?) {
      super.init(name: name, value: data)
      self.fileName = fileName
      self.mimeType = mimeType
    }
    
    func contentDisposition() -> String {
      let name: String = self.name ?? "untitled"
      var dispositionValue: String = "form-data; name=\"\(name)\""
      if self.fileName != nil && self.fileName?.characters.count >= 0 {
        let fileName: String = self.fileName ?? "untitled.\(MimeType.defaultExtension(self.mimeType))"
        dispositionValue += "; fileName=\"\(fileName)\""
      }
      return dispositionValue
    }
    
    func partHeaders() -> [String : String] {
      var headers: [String : String] = [String : String]()
      headers[Part.HeaderContentDisposition] = contentDisposition()
      if self.mimeType != nil {
        headers[Part.HeaderContentType] = self.mimeType
      }
      return headers
    }
  }
  
  public var boundary: String!
  public var boundaryCRLF = "\r\n"
  
  // MARK: - Initialization
  public override init() {
    super.init()
    self.boundary = "Boundary+\(arc4random())\(arc4random())"
  }

  public func addFilePart(fileData: NSData, name: String) {
    self.values.append(Part(name: name, data: fileData, fileName: "form_file", mimeType: nil))
  }
  
  public func addFilePart(fileData: NSData, name: String, fileName: String, mimeType: String) {
    self.values.append(Part(name: name, data: fileData, fileName: fileName, mimeType: mimeType))
  }
  
  
  // MARK: - Multipart boundaries
  private func boundaryInitial(boundaryString: String) -> String {
    return "--\(boundaryString)\(boundaryCRLF)"
  }

  private func boundaryInner(boundaryString: String) -> String {
    return "\(boundaryCRLF)--\(boundaryString)\(boundaryCRLF)"
  }

  private func boundaryFinal(boundaryString: String) -> String {
    return "\(boundaryCRLF)--\(boundaryString)--\(boundaryCRLF)"
  }

  
  // MARK: - Convert to data
  public override func generateData() -> NSMutableData {

    let initialBoundary: String = boundaryInitial(self.boundary)
    let innerBoundary: String = boundaryInner(self.boundary)
    let finalBoundary: String = boundaryFinal(self.boundary)
    let data: NSMutableData = NSMutableData()
    
    data.appendData(initialBoundary.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!)
    
    for (idx, bodyValue) in self.values.enumerate() {
      if idx > 0 && idx < self.values.count {
        // append the inner boundary but skip the last value
        data.appendData(innerBoundary.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!)
      }
      
      if let part: Part = bodyValue as? Part {
        for (key, value): (String, String) in part.partHeaders() {
          let valString: String = "\(key): \(value)\(boundaryCRLF)"
          data.appendData(valString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!)
        }
        
        // add a line feed and then add the data
        data.appendData(boundaryCRLF.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!)
        data.appendData(part.value as! NSData)
      } else {
        // append the content disposition header to the request body data
        let dispositionValue: String = "form-data; name=\"\(bodyValue.name)\""
        let headerString: String = "\(Part.HeaderContentDisposition): \(dispositionValue)\(boundaryCRLF)"
        data.appendData(headerString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!)
        
        // add a line feed and then add the value as data
        data.appendData(boundaryCRLF.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!)
        data.appendData("\(bodyValue.value)".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!)
      }
    }
    
    data.appendData(finalBoundary.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!)
    
    return data
  }
  
  // MARK: - Multipart headers
  public override func bodyHeaders() -> [String : String] {
    return [
      "Content-Type" : "multipart/form-data; boundary=\(self.boundary)",
      "Content-Length" : "\(self.contentLength)"
    ]
  }
  
}