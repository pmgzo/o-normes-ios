//
//  PicturesViewer.swift
//  Onormes
//
//  Created by gonzalo on 05/12/2022.
//

import Foundation
import SwiftUI
import UIKit


/*
    
    UIImage extension to deal with the rotated UIImage once read

*/

extension UIImage {
    func rotate(radians: Float) -> UIImage? {
        var newSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: CGFloat(radians))).size
        // Trim off the extremely small float value to prevent core graphics from rounding it up
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        let context = UIGraphicsGetCurrentContext()!

        // Move origin to middle
        context.translateBy(x: newSize.width/2, y: newSize.height/2)
        // Rotate around middle
        context.rotate(by: CGFloat(radians))
        // Draw the image at its center
        self.draw(in: CGRect(x: -self.size.width/2, y: -self.size.height/2, width: self.size.width, height: self.size.height))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
}

struct PicturesViewer: View {
    
    @State var currentPicture: UIImage;
    @State var index: Int = 0;
    let paths: [String];

    init(paths: [String]) {
        let userDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let pathImage = userDirectory!.path + "/temporaryImages/";
        var list: [String] = []
        for path in paths {
            list.append(path[0...35] + "_2.png") // get the non resized version
        }
        self.paths = list
        self.currentPicture = UIImage.init(contentsOfFile: pathImage + self.paths.first!)!.rotate(radians: .pi/2)!
    }
    
    var body: some View {
        ReturnButtonWrapper {
            ZStack {
                Image(uiImage: currentPicture)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                
                VStack {
                    Spacer()
                    HStack {
                        Button(action: {
                            index -= 1
                            
                            let userDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
                            let pathImage = userDirectory!.path + "/temporaryImages/" + paths[index]
                            
                            currentPicture = UIImage.init(contentsOfFile: pathImage)!.rotate(radians: .pi/2)!
                        }, label: {
                            VStack {
                                Image("LeftArrow")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 50)
                            }
                            .frame(width: 145, height: 38)
                            .background(Color(hex: "29245A"))
                            .cornerRadius(70)
                        })
                        .disabled(index == 0)
                        .transition(.slide)
                        
                        Spacer().frame(width: 50)
                        
                        Button(action: {
                            index += 1
                            
                            let userDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
                            let pathImage = userDirectory!.path + "/temporaryImages/" + paths[index]
                            
                            currentPicture = UIImage.init(contentsOfFile: pathImage)!.rotate(radians: .pi/2)!
                        }, label: {
                            VStack {
                                Image("RightArrow")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 50)
                            }
                            .frame(width: 145, height: 38)
                            .background(Color(hex: "29245A"))
                            .cornerRadius(70)
                        })
                        .disabled(index == (paths.count - 1))
                        .transition(.slide)
                    }
                    Spacer().frame(height: 100)
                }
            }
        }
    }

}
