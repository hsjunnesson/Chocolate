//
//  RenderViewController.swift
//  Chocolate
//
//  Created by Hans Sjunnesson on 20/12/15.
//  Copyright © 2015 Hans Sjunnesson. All rights reserved.
//

import UIKit


class RenderViewController: UIViewController {
    
    @IBOutlet weak var renderView: UIImageView!
    
    var renderer: Renderer?
    var didRender = false
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        let bounds = self.renderView.bounds
        let dim = UInt32(min(bounds.width, bounds.height) * UIScreen.main.scale) / 64 * 64
        let bucket = Renderer.Bucket(x: 0, y: 0, width: dim, height: dim)
        self.renderer = Renderer(bucket: bucket)
        render()
    }
    
    fileprivate func render() {
        if didRender {
            return
        }
        
        didRender = true
        
        DispatchQueue.global().async {
            let now = self.getTimestamp()
            
            let scale = UIScreen.main.scale
            
            guard
                let renderer = self.renderer,
                let cgImage = try? renderer.render() as CGImage! else {
                    print("ERROR")
                    return
            }
            
            let uiImage = UIImage(cgImage: cgImage, scale: scale, orientation: .up)

            let renderTime = Int(self.getTimestamp() - now)
            print("Rendered: \(renderTime) ms")

            DispatchQueue.main.async {
                self.renderView.image = uiImage
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "\(renderTime) ms", style: .plain, target: nil, action: nil)
            }
        }
    }
    
    fileprivate func getTimestamp() -> Double {
        var tv = timeval()
        gettimeofday(&tv, nil)
        return (Double(tv.tv_sec) * 1e3 + Double(tv.tv_usec) * 1e-3)
    }
}
