//
//  ImageHandler.swift
//  Onormes
//
//  Created by gonzalo on 20/11/2022.
//

import Foundation
import SwiftUI
import AVFoundation

enum FileErrorType: Error {
    case custom(reason: String) // no data caught
}


func resizeImage(image: UIImage, maxSize: CGSize) -> UIImage {
    // by default the generated image is 1920 by 1080
    
    let availableRect = AVFoundation.AVMakeRect(aspectRatio: image.size, insideRect: .init(origin: .zero, size: maxSize))
    let targetSize = availableRect.size

    let format = UIGraphicsImageRendererFormat()
    format.scale = 1
    let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)

    let resized = renderer.image { (context) in
        image.draw(in: CGRect(origin: .zero, size: targetSize))
    }
    
    return resized
}


/**
 
    Function which save an image into PNG format and return its filename
 
 */

func saveImage(image: UIImage) -> String {
    let idImage = UUID().uuidString
    let imageName = idImage + ".png"
    
    
    let data = image.pngData()
    let resizedData = resizeImage(image: image, maxSize: CGSize(width: 100, height: 100)).pngData()
    
    do {
        
        guard data != nil else {
            throw FileErrorType.custom(reason: "Fail to encode file in png file format")
        }
        
        let userDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let pathToImages = userDirectory!.path + "/temporaryImages"

        // if directory doesn't exists, create it
        if FileManager.default.fileExists(atPath: pathToImages) == false {
            try FileManager.default.createDirectory(atPath: pathToImages, withIntermediateDirectories: true, attributes: nil)
        }

        let fullPath = pathToImages + "/" + imageName

        // rare case where the UUID is the same generated as before
        if FileManager.default.fileExists(atPath: fullPath) == true {
            // erase existing file with the same name
            try FileManager.default.removeItem(atPath: fullPath)
        }

        // save resized Image
        let success = FileManager.default.createFile(atPath: fullPath, contents: resizedData)
        
        // save normal image
        FileManager.default.createFile(atPath: pathToImages + "/" + idImage + "_2.png", contents: data)

        if success {
            print("image saved created")
        } else {
            print("fail to save image")
        }
    } catch {
        print(error)
    }
    return imageName
}

/**
    Read image and return the encoded png image into base64 string
 
 */

func readImage(filename: String) throws -> String {
    let userDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    let pathToSavedAudit = userDirectory!.path + "/temporaryImages"
    let fileUrl = URL(string: "file://" + formatPath(pathFile: pathToSavedAudit + "/" + filename))

    let imageString = try Data(contentsOf: fileUrl!)

    // convert data to base64
    return imageString.base64EncodedString()
}

