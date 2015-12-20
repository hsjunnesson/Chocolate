//
//  ViewController.swift
//  Chocolate
//
//  Created by Hans Sjunnesson on 20/12/15.
//  Copyright © 2015 Hans Sjunnesson. All rights reserved.
//

import UIKit
import Render


class ViewController: UIViewController {
    
    @IBOutlet weak var renderView: UIImageView!
    
    override func viewDidLayoutSubviews() {
        let width = Int(self.renderView.bounds.width - self.renderView.bounds.width % 8)
        let height = Int(self.renderView.bounds.height - self.renderView.bounds.height % 8)
        let scale = UIScreen.mainScreen().scale
        
        guard
            let renderer = Renderer(),
            let cgImage = try? renderer.render(width: width * Int(scale), height: height * Int(scale)) as CGImage! else {
                return
        }
        
        let uiImage = UIImage(CGImage: cgImage, scale: scale, orientation: .Up)
        
        self.renderView.image = uiImage
    }
}
