//
//  ViewController.swift
//  SmoothCropp-Swift
//
//  Created by Nitin Gohel on 14/03/16.
//  Copyright © 2016 Olbuz. All rights reserved.
//

import UIKit


class ViewController: UIViewController {

    @IBOutlet var image: JBCroppableImageView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func ActionUndo(sender: AnyObject) {
        
        self.image.reverseCrop()
    }

    @IBAction func actionAdd(sender: AnyObject) {
        
        self.image.addPoint()
        
    }
    @IBAction func actionSub(sender: AnyObject) {
        
         self.image.removePoint()
        
    }
    @IBAction func actionCrop(sender: AnyObject) {
        
        self.image.crop()
    }
    @IBAction func actionSave(_ sender: Any) {
        guard let resultImageRef = image.getCroppedImage(withTransparentBorders: true)
            else { return }
        let resultImage = resultImageRef.cropImageByAlpha()
        UIImageWriteToSavedPhotosAlbum(resultImage, nil, nil, nil)
        let controller = UIAlertController(title: "Success", message: "the photo is saved", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        controller.addAction(okAction)
        present(controller, animated: true, completion: nil)
    }
}


extension UIImage {

    func cropImageByAlpha() -> UIImage {
        let cgImage = self.cgImage
        let context = createARGBBitmapContextFromImage(inImage: cgImage!)
        let height = cgImage!.height
        let width = cgImage!.width
        
        var rect: CGRect = CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height))
        context?.draw(cgImage!, in: rect)
        
        let pixelData = self.cgImage!.dataProvider!.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        
        var minX = width
        var minY = height
        var maxX: Int = 0
        var maxY: Int = 0
        
        //Filter through data and look for non-transparent pixels.
        for y in 0..<height {
            for x in 0..<width {
                let pixelIndex = (width * y + x) * 4 /* 4 for A, R, G, B */
                
                if data[Int(pixelIndex)] != 0 { //Alpha value is not zero pixel is not transparent.
                    if (x < minX) {
                        minX = x
                    }
                    if (x > maxX) {
                        maxX = x
                    }
                    if (y < minY) {
                        minY = y
                    }
                    if (y > maxY) {
                        maxY = y
                    }
                }
            }
        }
        
        rect = CGRect( x: CGFloat(minX), y: CGFloat(minY), width: CGFloat(maxX-minX), height: CGFloat(maxY-minY))
        let imageScale:CGFloat = self.scale
        let cgiImage = self.cgImage?.cropping(to: rect)
        return UIImage(cgImage: cgiImage!, scale: imageScale, orientation: self.imageOrientation)
    }

     func createARGBBitmapContextFromImage(inImage: CGImage) -> CGContext? {
        
        let width = cgImage!.width
        let height = cgImage!.height
        
        let bitmapBytesPerRow = width * 4
        let bitmapByteCount = bitmapBytesPerRow * height
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapData = malloc(bitmapByteCount)
        if bitmapData == nil {
            return nil
        }
        
        let context = CGContext (data: bitmapData, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bitmapBytesPerRow, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue)
        
        return context
    }
}
