//
//  Render.swift
//  Chocolate
//
//  Created by Hans Sjunnesson on 20/12/15.
//  Copyright © 2015 Hans Sjunnesson. All rights reserved.
//

import Foundation
import Metal
import MetalKit

public enum RenderErrorType: ErrorType {
    case InvalidResolution
    case InvalidImage
    case InvalidProgram
}

public func localShaderPath() -> String {
    let documentDirectoryUrl = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).last!
    let shaderPath = documentDirectoryUrl.URLByAppendingPathComponent("Library.metal").path!
    
    return shaderPath
}

public struct Renderer {
    
    private struct Bucket {
        let x: UInt32
        let y: UInt32
        let width: UInt32
        let height: UInt32
    }
    
    private let device: MTLDevice
    private let commandQueue: MTLCommandQueue
    private let library: MTLLibrary
    private let renderBucketFunction: MTLFunction
    private let computePipelineState: MTLComputePipelineState
    
    public init?() {
        guard
            let device = MTLCreateSystemDefaultDevice(),
            let library = loadLibrary(device),
            let renderBucketFunction = library.newFunctionWithName("renderBucket"),
            let computePipelineState = try? device.newComputePipelineStateWithFunction(renderBucketFunction)
            else {
            return nil
        }
        
        self.device = device
        self.commandQueue = device.newCommandQueue()
        self.library = library
        self.renderBucketFunction = renderBucketFunction
        self.computePipelineState = computePipelineState
    }
    
    public func render(width width: Int, height: Int) throws -> CGImage {
        // Preconditions
        if width % 8 != 0 || height % 8 != 0 {
            throw RenderErrorType.InvalidResolution
        }
        
        // Setup
        let commandBuffer = commandQueue.commandBuffer()
        let commandEncoder = commandBuffer.computeCommandEncoder()
        commandEncoder.setComputePipelineState(computePipelineState)
        
        // Texture
        let outTexture = device.newTextureWithDescriptor(MTLTextureDescriptor.texture2DDescriptorWithPixelFormat(.RGBA8Unorm, width: width, height: height, mipmapped: false))
        commandEncoder.setTexture(outTexture, atIndex: 0)
        
        // Bucket
        var bucket = Bucket(x: 0, y: 0, width: UInt32(width), height: UInt32(height))
        let bucketBuffer = device.newBufferWithBytes(&bucket, length: sizeof(Bucket), options: .CPUCacheModeDefaultCache)
        commandEncoder.setBuffer(bucketBuffer, offset: 0, atIndex: 0)
        
        // Thread group
        let threadGroupCount = MTLSizeMake(8, 8, 1)
        let threadGroups = MTLSizeMake(width / threadGroupCount.width, height / threadGroupCount.height, 1)
        commandEncoder.dispatchThreadgroups(threadGroups, threadsPerThreadgroup: threadGroupCount)
        
        // Execute
        commandEncoder.endEncoding()
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
        
        // Return the created image
        if let image = makeImage(outTexture) {
            return image
        } else {
            throw RenderErrorType.InvalidImage
        }
    }
    
    private func makeImage(texture: MTLTexture) -> CGImage? {
        let imageSize = CGSize(width: texture.width, height: texture.height)
        let imageByteCount = Int(imageSize.width * imageSize.height * 4)
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * Int(imageSize.width)
        var imageBytes = [UInt8](count: imageByteCount, repeatedValue: 0)
        let region = MTLRegionMake2D(0, 0, Int(imageSize.width), Int(imageSize.height))
        texture.getBytes(&imageBytes, bytesPerRow: Int(bytesPerRow), fromRegion: region, mipmapLevel: 0)

        let providerRef = CGDataProviderCreateWithCFData(NSData(bytes: &imageBytes, length: imageBytes.count * sizeof(UInt8)))
        let bitmapInfo = CGBitmapInfo(rawValue: CGBitmapInfo.ByteOrder32Big.rawValue | CGImageAlphaInfo.PremultipliedLast.rawValue)
        let renderingIntent: CGColorRenderingIntent = .RenderingIntentDefault
        let colorSpaceRef = CGColorSpaceCreateDeviceRGB()
        
        let imageRef = CGImageCreate(Int(imageSize.width), Int(imageSize.height), 8, 32, bytesPerRow, colorSpaceRef, bitmapInfo, providerRef, nil, false, renderingIntent)
        
        return imageRef
    }
}

private func loadLibrary(device: MTLDevice) -> MTLLibrary? {
    guard
        let source = try? NSString(contentsOfFile: localShaderPath(), encoding: NSUTF8StringEncoding) as String,
        let library = try? device.newLibraryWithSource(source, options: nil) else {
            return device.newDefaultLibrary()
    }
    
    return library
}
