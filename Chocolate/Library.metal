//
//  Library.metal
//  Chocolate
//
//  Created by Hans Sjunnesson on 20/12/15.
//  Copyright (c) 2015 Hans Sjunnesson. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#define inf 4000000000.0

typedef struct {
    uint id;
    float distance;
} Hit;

static float sdBox(float3 p, float3 b) {
    float3 d = abs(p) - b;
    return min(max(d.x,max(d.y,d.z)),0.0) + length(max(d,0.0));
}

static float sdCross(float3 p) {
    float da = sdBox(p.xyz,float3(inf,1.0,1.0));
    float db = sdBox(p.yzx,float3(1.0,inf,1.0));
    float dc = sdBox(p.zxy,float3(1.0,1.0,inf));
    return min(da,min(db,dc));
}

static float udBox(float3 p, float3 b) {
    return length(max(abs(p) - b, 0.0));
}

static float sdSphere(float3 p, float s) {
    return length(p)-s;
}

static float3 worldGetBackground(float3 rd) {
    return mix(float3(0.3,0.2,0.1) * 0.5, float3(0.7, 0.9, 1.0), 0.5 + 0.5 * rd.y);
}

static Hit map(float3 p) {
    Hit h;
    h.id = 1;
    
    float d = sdBox(p, float3(1.0));
    
    float s = 1.0;
    
    for (int m = 0; m < 3; m++) {
        float3 x = p * s;
        float3 y = 2.0;
        float3 a = (x - y * floor(x / y));

        s *= 3.0;
        float3 r = 1.0 - 3.0 * abs(a);
        
        float c = sdCross(r) / s;
        d = max(d, -c);
    }
    
    h.distance = d;
    
    return h;
}

static float3 calcNormal(float3 p) {
    float3 eps = float3(0.001, 0.0, 0.0);
    float3 n = float3(map(p + eps.xyy).distance - map(p - eps.xyy).distance,
                      map(p + eps.yxy).distance - map(p - eps.yxy).distance,
                      map(p + eps.yyx).distance - map(p - eps.yyx).distance);
    return normalize(n);
}

static Hit castRay(float3 ro, float3 rd, float maxlen) {
    for (float t = 0.0; t < 10.0;) {
        Hit res = map(ro + rd * t);
        if (res.distance < 0.00001) {
            Hit h = res;
            h.distance = t;
            return h;
        }
        
        t += res.distance;
    }
    
    Hit miss;
    miss.id = 0;
    
    return miss;
}

static float3 worldGetColor(float3 pos, float3 nor, uint id) {
    if (id == 1) {
        return float3(1.0, 0.8, 0.6);
    } else {
        return float3(1.0, 0.0, 0.0);
    }
}

static float3 worldApplyLighting(float3 pos, float3 nor) {
    float3 lig = normalize(float3(-0.7, 1.0, 1.3));
    return clamp(dot(nor, lig), 0.0, 1.0);
}

static float3 render(float3 ro, float3 rd) {
    Hit hit = castRay(ro, rd, 1000.0);
    
    if (hit.id > 0) {
        float3 pos = ro + hit.distance * rd;
        float3 nor = calcNormal(pos);
        float3 scol = worldGetColor(pos, nor, hit.id);
        float3 dcol = worldApplyLighting(pos, nor);

        return float3(scol * dcol);
    } else {
        return worldGetBackground(rd);
    }
}

static float3x3 setCamera(float3 ro, float3 ta, float cr) {
    float3 cw = normalize(ta - ro);
    float3 cp = float3(sin(cr), cos(cr), 0.0);
    float3 cu = normalize(cross(cw, cp));
    float3 cv = normalize(cross(cu, cw));
    return float3x3(cu, cv, cw);
}


struct Bucket {
    uint x;
    uint y;
    uint width;
    uint height;
};

kernel void renderBucket(         texture2d<float, access::write> outTexture [[texture(0)]],
                         constant Bucket                          &bucket    [[buffer(0)]],
                                  uint2                           gid        [[thread_position_in_grid]]) {
    float fov = 2.5;
    
    float2 q = float2(gid.x / float(bucket.width), gid.y / float(bucket.height));
    float2 p = -1.0 + 2.0 * q;
    p.x *= float(bucket.width) / float(bucket.height);
    
    float3 ro = float3(1.6, 0.6, 4.4);
    float3 ta = float3(0.0, 0.0, 0.0);
    
    float3x3 ca = setCamera(ro, ta, 0.0);
    
    float3 rd = ca * normalize(float3(p.xy, fov) * float3(1.0, -1.0, 1.0));
    
    float3 col = render(ro, rd);
    col = pow(col, float3(1.0 / 1.8));
    
    outTexture.write(float4(col, 1.0), gid);
}
