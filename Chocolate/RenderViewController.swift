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
        self.renderer = Renderer()
        
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        render()
    }
    
    private func render() {
        if didRender {
            return
        }
        
        didRender = true
        
        dispatch_async(dispatch_get_global_queue(0, 0)) {
            let now = self.getTimestamp()
            
            let width = Int(self.renderView.bounds.width - self.renderView.bounds.width % 8)
            let height = Int(self.renderView.bounds.height - self.renderView.bounds.height % 8)
            let scale = UIScreen.mainScreen().scale
            
            guard
                let renderer = self.renderer,
                let cgImage = try? renderer.render(width: width * Int(scale), height: height * Int(scale)) as CGImage! else {
                    print("ERROR")
                    return
            }
            
            let uiImage = UIImage(CGImage: cgImage, scale: scale, orientation: .Up)

            let renderTime = Int(self.getTimestamp() - now)
            print("Rendered: \(renderTime) ms")

            dispatch_async(dispatch_get_main_queue()) {
                self.renderView.image = uiImage
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "\(renderTime) ms", style: .Plain, target: nil, action: nil)
            }
        }
    }
    
    private func getTimestamp() -> Double {
        var tv = timeval()
        gettimeofday(&tv, nil)
        return (Double(tv.tv_sec) * 1e3 + Double(tv.tv_usec) * 1e-3)
    }
}
