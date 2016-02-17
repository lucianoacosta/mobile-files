//
//  QRCodeLB.swift
//
//  Created by Luciano Acosta on 11/12/15.
//

import UIKit


/*

    With this class, its possible to generate a qrcode and change its background color and the tint color.
    With also the possibility to make the background transparent

    Example of usage

    let qrCode = QRCodeLB()
    qrCode.text            = "My QRCode Content"
    qrCode.correctionLevel = "L"
    qrCode.scale = 5.0
    qrCode.hideBackground  = false
    imgQRCode = qrCode.generateQRCode(imgQRCode)


*/

class QRCodeLB: NSObject {
    
    
    var text            : String!
    var correctionLevel : String!
    var scale           : CGFloat! = 5
    var qrColor         : UIColor! = UIColor.blackColor()
    var backgroundColor : UIColor!
    var hideBackground  = false

    func generateQRCode(qrView : UIImageView) -> UIImageView{
        
        let data = text.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        let filter = CIFilter(name: "CIQRCodeGenerator")
        
        filter!.setValue(data, forKey: "inputMessage")
        filter!.setValue(correctionLevel, forKey: "inputCorrectionLevel")
        
        // Render the image into a CoreGraphics image
        let cgImage = CIContext(options: nil).createCGImage((filter?.outputImage)!, fromRect: (filter?.outputImage?.extent)!)
        
        //Scale the image usign CoreGraphics
        UIGraphicsBeginImageContext(CGSizeMake((filter?.outputImage?.extent.size.width)! * scale, (filter?.outputImage?.extent.size.width)! * scale))
        let context = UIGraphicsGetCurrentContext()
        CGContextSetInterpolationQuality(context, .None)
        CGContextDrawImage(context, CGContextGetClipBoundingBox(context), cgImage)
        let preImage = UIGraphicsGetImageFromCurrentImageContext()
        
        //Cleaning up .
        UIGraphicsEndImageContext();
        
        // Rotate the image
        var qrImage = UIImage(CGImage: preImage.CGImage!, scale: preImage.scale, orientation: .DownMirrored)
        
        if(hideBackground == true){
            qrImage = qrImage.removeBackgroundWhite()
        }
        
        if(backgroundColor != nil && hideBackground == false){
            if(hideBackground == false){
                qrImage = qrImage.removeBackgroundWhite()
            }
            
            qrView.backgroundColor = self.backgroundColor
        }
        
        qrView.image = qrImage.colorizeWith(self.qrColor)
        
        return qrView
    }
}

extension UIImage {
    
    func colorizeWith(color: UIColor) -> UIImage {
        
        // 0.0 for scale means "scale for device's main screen".
        UIGraphicsBeginImageContextWithOptions(self.size, false, 0.0);
    
        var rect = CGRectZero
        rect.size = self.size
        
        //tint the image
        self.drawInRect(rect)
        color.set()
        
        UIRectFillUsingBlendMode(rect, .Screen);
        self.drawInRect(rect, blendMode: .DestinationIn, alpha: 1.0)
        
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return image
    }
    
    func removeBackgroundWhite() -> UIImage{
        let image = UIImage(data: UIImageJPEGRepresentation(self, 1.0)!)

        let rawImageRef = image!.CGImage
        let colorMasking : [CGFloat] = [222, 255, 222, 255, 222, 255]

        UIGraphicsBeginImageContext(image!.size);
        let maskedImageRef = CGImageCreateWithMaskingColors(rawImageRef, colorMasking)
        
        //if in iphone
        CGContextTranslateCTM(UIGraphicsGetCurrentContext(), 0.0, image!.size.height);
        CGContextScaleCTM(UIGraphicsGetCurrentContext(), 1.0, -1.0);
        CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, image!.size.width, image!.size.height), maskedImageRef);
        let result = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return result;
    }
}
