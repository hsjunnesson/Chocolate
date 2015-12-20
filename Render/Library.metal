//
//  Library.metal
//  Chocolate
//
//  Created by Hans Sjunnesson on 20/12/15.
//  Copyright © 2015 Hans Sjunnesson. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct Bucket {
    uint x;
    uint y;
    uint width;
    uint height;
};

kernel void render(constant Bucket &bucket       [[buffer(0)]],
                   device   float3 *renderBuffer [[buffer(1)]]) {
    for (uint y = 0; y < bucket.y; y += 1) {
        for (uint x = 0; x < bucket.x; x += 1) {
            uint offset = bucket.height * y + x;
            renderBuffer[offset] = float3(1.0, 0.0, 0.0);
        }
    }
}
