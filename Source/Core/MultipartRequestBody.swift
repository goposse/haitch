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

/**
 A RequestBody class used for Multipart Requests.
 
 - important: It is critically important to call build() on your RequestBody before
     using it in an Http Request. Failing to do so will almost always result in a crash.
 */
public class MultipartRequestBody : RequestBody {
  
  /**
   An inner struct of the MultipartRequestBody used to help define MIME types for different
     types of files.
   */
  public struct MimeType {
    /// MIME type for a PNG image.
    public static let ImagePng: String   = "image/png"
    
    /// MIME type for a JPEG image
    public static let ImageJpeg: String  = "image/jpeg"
    
    /// MIME type for a progressive JPEG (PJPEG) image
    public static let ImageJpegP: String = "image/pjpeg"
    
    /// MIME type for a GIF image.
    public static let ImageGif: String   = "image/gif"
    
    /// MIME type for a BMP image.
    public static let ImageBmp: String   = "image/bmp"
    
    /// MIME type for a TIFF image.
    public static let ImageTiff: String  = "image/tiff"

    /// A map of extensions for the differnt MIME types.
    private static let defaultExts = [
      ImagePng :   "png",
      ImageJpeg :  "jpeg",
      ImageJpegP : "pjpeg",
      ImageGif :   "gif",
      ImageBmp :   "bmp",
      ImageTiff :  "tiff",
    ]
    
    /**
     Uses the defaultExts property to map a MIME type to an extension.
     
     - parameter mimeType: The MIME type to find the default extension of.
     
     - returns: The default extension of the mimeType that has been passed in.  If
         no match is found, "file" is returned.
     */
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
  
  /**
   A BodyValue type that is used in RequestBody objects of a multipart request.
   */
  private class Part : BodyValue {
    
    /// Static value of the Part class, set to "Content-Disposition"
    static let HeaderContentDisposition = "Content-Disposition"
    
    /// Static value of the Part class, set to "Content-Type"
    static let HeaderContentType = "Content-Type"
    
    /// The name of the file if there is one. Used when creating the contentDisposition.
    var fileName: String?
    /// The MIME type of the file if there is one. Used when creating the headers for the 
    /// this Part.
    var mimeType: String?
    
    /**
     Initializes a Part object with given values.
     
     - parameter name: The key of the BodyValue.
     - parameter data: The data of the BodyValue.
     - parameter fileName: The file name of the data being used.
     - parameter mimeType: The MIME type of the data being used.
     */
    init(name: String, data: NSData, fileName: String?, mimeType: String?) {
      super.init(name: name, value: data)
      self.fileName = fileName
      self.mimeType = mimeType
    }
    
    /**
     Creates a content disposition for this Part object.
     
     - returns: The content dispoition, which looks like it uses the name property
         and the fileName property to create a string like "form-data; name=\\(name); fileName=\\(fileName)".
         If there is no name, it uses untitled.  If there is no fileName, the fileName part is not included.
     */
    func contentDisposition() -> String {
      let name: String = self.name ?? "untitled"
      var dispositionValue: String = "form-data; name=\"\(name)\""
      if self.fileName != nil && self.fileName?.characters.count >= 0 {
        let fileName: String = self.fileName ?? "untitled.\(MimeType.defaultExtension(self.mimeType))"
        dispositionValue += "; fileName=\"\(fileName)\""
      }
      return dispositionValue
    }
    
    /**
     Generates headers for this Part object.
     
     - returns: A dictionary with the content disposition and the MIME type of it is 
         available.  Uses Part.HeaderContentDisposition and Part.HeaderContentType as key values.
     */
    func partHeaders() -> [String : String] {
      var headers: [String : String] = [String : String]()
      headers[Part.HeaderContentDisposition] = contentDisposition()
      if self.mimeType != nil {
        headers[Part.HeaderContentType] = self.mimeType
      }
      return headers
    }
  }
  
  /// The boundary value of the MultipartRequestBody.  Defaulted in the initializer to
  /// "Boundary+\(arc4random())\(arc4random())"
  public var boundary: String!
  /// The boundary carriage returns and line feed value. Defaults to "\r\n"
  public var boundaryCRLF = "\r\n"
  
  // MARK: - Initialization
  
  /**
   Initializes a MultipartRequestBody with the default initializer of RequestBody and also
     sets the boundary property to "Boundary+\(arc4random())\(arc4random())".
   */
  public override init() {
    super.init()
    self.boundary = "Boundary+\(arc4random())\(arc4random())"
  }
  
  /**
   Adds a Part object to the values property.  The Part object is created with the given data.
   
   - parameter fileData: The data to create the Part object with.
   - parameter name: The key of the Part, which is a BodyValue, that will be created.
   - parameter fileName: The fileName of the Part object that will be created. Defaults to "form_file".
   - parameter mimeType: The mimeType of the Part object that will be created.  Defaults to nil
   */
  public func addFilePart(fileData: NSData, name: String, fileName: String = "form_file", mimeType: String? = nil) {
    self.values.append(Part(name: name, data: fileData, fileName: fileName, mimeType: mimeType))
  }
  
  
  // MARK: - Multipart boundaries
  
  /**
   Helper function that generates the initial boundary String.
   
   - parameter boundaryString: The boundary String expected, should generally be the
       boundary parameter
   
   - returns: The initial boundary string, i.e. "--\\(boundaryString)\\(boundaryCRLF)"
   */
  private func boundaryInitial(boundaryString: String) -> String {
    return "--\(boundaryString)\(boundaryCRLF)"
  }

  /**
   Helper function that generates an inner boundary String.
   
   - parameter boundaryString: The boundary String expected, should generally be the 
       boundary parameter
   
   - returns: The inner boundary string, i.e. "\\(boundaryCRLF)--\\(boundaryString)\\(boundaryCRLF)"
   */
  private func boundaryInner(boundaryString: String) -> String {
    return "\(boundaryCRLF)--\(boundaryString)\(boundaryCRLF)"
  }

  /**
   Helper function that generates the final boundary String.
   
   - parameter boundaryString: The boundary String expected, should generally be the
       boundary parameter
   
   - returns: The final boundary string, i.e. "\\(boundaryCRLF)--\\(boundaryString)--\\(boundaryCRLF)"
   */
  private func boundaryFinal(boundaryString: String) -> String {
    return "\(boundaryCRLF)--\(boundaryString)--\(boundaryCRLF)"
  }

  
  // MARK: - Convert to data
  
  /**
   Override of the generateData function.  Builds the data that can be used in an HTTP request.
   
   - returns: The data generated for the MultipartRequestBody.  A whole lot of delimited boundaries and 
       and data.  I recommend checking out the source directly if you have any questions.
   */
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
  
  /**
   Override of the bodyHeaders function.  Check the return description for more information.
   
   - returns: A dictionary of the Content-Type and the Content-Length of the MultipartRequestBody,
       I.e. following dictionary values:
       - "Content-Type" : "multipart/form-data; boundary=\(self.boundary)"
       - "Content-Length" : "\(self.contentLength)"
   */
  public override func bodyHeaders() -> [String : String] {
    return [
      "Content-Type" : "multipart/form-data; boundary=\(self.boundary)",
      "Content-Length" : "\(self.contentLength)"
    ]
  }
  
}