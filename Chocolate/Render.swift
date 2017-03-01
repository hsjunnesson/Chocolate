//
//  Render.swift
//  Chocolate
//
//  Created by Hans Sjunnesson on 20/12/15.
//  Copyright © 2015 Hans Sjunnesson. All rights reserved.
//

import Foundation
import Metal
import CoreGraphics


public enum RenderErrorType: Error {
    case invalidResolution
    case invalidImage
    case invalidProgram
}

public func localShaderPath() -> String {
    let documentDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
    let shaderPath = documentDirectoryUrl.appendingPathComponent("Library.metal").path
    
    return shaderPath
}

public struct Renderer {
    
    public struct Bucket {
        let x: UInt32
        let y: UInt32
        let width: UInt32
        let height: UInt32
    }
    
    fileprivate let device: MTLDevice
    fileprivate let commandQueue: MTLCommandQueue
    fileprivate let library: MTLLibrary
    fileprivate let renderBucketFunction: MTLFunction
    fileprivate let computePipelineState: MTLComputePipelineState
    fileprivate let bucket: Bucket
    
    public init?(bucket: Bucket) {
        guard
            let device = MTLCreateSystemDefaultDevice(),
            let library = loadLibrary(device),
            let renderBucketFunction = library.makeFunction(name: "renderBucket"),
            let computePipelineState = try? device.makeComputePipelineState(function: renderBucketFunction)
            else {
            return nil
        }
        
        self.bucket = bucket
        self.device = device
        self.commandQueue = device.makeCommandQueue()
        self.library = library
        self.renderBucketFunction = renderBucketFunction
        self.computePipelineState = computePipelineState
    }
    
    public func render() throws -> CGImage {
        // Preconditions
        if self.bucket.width % 8 != 0 || self.bucket.height % 8 != 0 {
            throw RenderErrorType.invalidResolution
        }
        
        let width = Int(self.bucket.width)
        let height = Int(self.bucket.height)
        
        // Setup
        let commandBuffer = commandQueue.makeCommandBuffer()
        let commandEncoder = commandBuffer.makeComputeCommandEncoder()
        commandEncoder.setComputePipelineState(computePipelineState)
        
        // Texture
        let outTexture = device.makeTexture(descriptor: MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8Unorm, width: width, height: height, mipmapped: false))
        commandEncoder.setTexture(outTexture, at: 0)
        
        // Bucket
        var bucket = self.bucket
        let bucketBuffer = device.makeBuffer(bytes: &bucket, length: MemoryLayout<Bucket>.size, options: MTLResourceOptions())
        commandEncoder.setBuffer(bucketBuffer, offset: 0, at: 0)
        
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
            throw RenderErrorType.invalidImage
        }
    }
    
    fileprivate func makeImage(_ texture: MTLTexture) -> CGImage? {
        let imageSize = CGSize(width: texture.width, height: texture.height)
        let imageByteCount = Int(imageSize.width * imageSize.height * 4)
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * Int(imageSize.width)
        var imageBytes = [UInt8](repeating: 0, count: imageByteCount)
        let region = MTLRegionMake2D(0, 0, Int(imageSize.width), Int(imageSize.height))
        texture.getBytes(&imageBytes, bytesPerRow: Int(bytesPerRow), from: region, mipmapLevel: 0)

//        let providerRef = CGDataProvider(data: Data(bytes: UnsafePointer<UInt8>(&imageBytes), count: imageBytes.count * sizeof(UInt8)))
        guard let providerRef = CGDataProvider(data: Data(bytes: &imageBytes, count: imageBytes.count * MemoryLayout<UInt8>.size) as CFData) else {
            return nil
        }

        let bitmapInfo = CGBitmapInfo(rawValue: CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue)
        let renderingIntent: CGColorRenderingIntent = .defaultIntent
        let colorSpaceRef = CGColorSpaceCreateDeviceRGB()
        
        let imageRef = CGImage(width: Int(imageSize.width), height: Int(imageSize.height), bitsPerComponent: 8, bitsPerPixel: 32, bytesPerRow: bytesPerRow, space: colorSpaceRef, bitmapInfo: bitmapInfo, provider: providerRef, decode: nil, shouldInterpolate: false, intent: renderingIntent)
        
        return imageRef
    }
}

private func loadLibrary(_ device: MTLDevice) -> MTLLibrary? {
    guard
        let source = try? NSString(contentsOfFile: localShaderPath(), encoding: String.Encoding.utf8.rawValue) as String,
        let library = try? device.makeLibrary(source: source, options: nil) else {
            return device.newDefaultLibrary()
    }
    
    return library
}
