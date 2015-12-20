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

kernel void render(         texture2d<float, access::write> outTexture [[texture(0)]],
                   constant Bucket                          &bucket    [[buffer(0)]],
                            uint2                           gid        [[thread_position_in_grid]]) {
    float2 p = float2(gid.x / float(bucket.width), gid.y / float(bucket.height));
    float3 col = float3(1.0, p.y, 1.0);
    outTexture.write(float4(col, 1.0), gid);
}
