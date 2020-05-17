//
//  all_in_one.metal
//  
//
//  Created by Liuliet.Lee on 13/5/2020.
//

#include <metal_stdlib>
using namespace metal;

// MARK: - metal_utils

struct pooling_layer_info {
    int2 core_size;
    int2 out_size;
    int3 in_size;
    int stride;
    int padding;
    int batch_size;
};

bool in_bound(int x, int y, int row, int col) {
    return 0 <= x && x < row && 0 <= y && y < col;
}

// MARK: - conv_m

struct conv_layer_info {
    int3 core_size; // [depth, width, height]
    int3 in_size;   // [depth, width of input, height of input]
    int3 out_size;  // [count, row, col]
    int batch_size;
    int stride;
    int padding;
};

kernel void conv_forward(device const conv_layer_info &info,
                         device const float *input,
                         device const float *core,
                         device const float *bi,
                         device const int &input_length,
                         device const int &core_length,
                         device const int &bi_length,
                         device const int &score_length,
                         device float *score,
                         uint3 gid [[ thread_position_in_grid ]])
{
    // gid = [batch, count, row * col]
    int i = gid[2] / info.out_size[2];
    int j = gid[2] % info.out_size[2];
    int index =
    gid[0] * info.out_size[0] * info.out_size[1] * info.out_size[2] +
    gid[1] * info.out_size[1] * info.out_size[2] +
    gid[2];
    
    if (index >= score_length) return;
    
    score[index] = 0.0;
    for (int x = 0; x < info.core_size[1]; x++) {
        for (int y = 0; y < info.core_size[2]; y++) {
            for (int z = 0; z < info.core_size[0]; z++) {
                int rx = i * info.stride + x - info.padding;
                int ry = j * info.stride + y - info.padding;
                if (in_bound(rx, ry, info.in_size[1], info.in_size[2])) {
                    int ii =
                    gid[0] * info.in_size[0] * info.in_size[1] * info.in_size[2] +
                    z * info.in_size[1] * info.in_size[2] +
                    rx * info.in_size[2] +
                    ry;
                    
                    int ic =
                    gid[1] * info.core_size[0] * info.core_size[1] * info.core_size[2] +
                    z * info.core_size[1] * info.core_size[2] +
                    x * info.core_size[2] +
                    y;
                    
                    if (ii >= input_length || ic >= core_length) continue;
                    
                    score[index] += input[ii] * core[ic];
                }
            }
        }
    }
    
    if ((int)gid[1] >= bi_length) return;
    
    score[index] += bi[gid[1]];
}

kernel void conv_backward_1(device const conv_layer_info &info,
                            device const float *core,
                            device const float *delta,
                            device const int &core_length,
                            device const int &delta_length,
                            device const int &da_length,
                            device float *da,
                            uint3 gid [[thread_position_in_grid ]])
{
    // gid = [batch, depth, input width * height]
    int rx = gid[2] / info.in_size[2];
    int ry = gid[2] % info.in_size[2];
    
    int index =
    gid[0] * info.in_size[0] * info.in_size[1] * info.in_size[2] +
    gid[1] * info.in_size[1] * info.in_size[2] +
    rx * info.in_size[2] +
    ry;
    
    if (index >= da_length) {
        return;
    }
    
    for (int c = 0; c < info.out_size[0]; c++) {
        for (int x = 0; x < info.core_size[1]; x++) {
            for (int y = 0; y < info.core_size[2]; y++) {
                if ((rx + info.padding - x) % info.stride == 0 &&
                    (ry + info.padding - y) % info.stride == 0) {
                    int i = (rx + info.padding - x) / info.stride;
                    int j = (ry + info.padding - y) / info.stride;
                    if (in_bound(i, j, info.out_size[1], info.out_size[2])) {
                        int ic =
                        c * info.core_size[0] * info.core_size[1] * info.core_size[2] +
                        gid[1] * info.core_size[1] * info.core_size[2] +
                        x * info.core_size[2] +
                        y;
                        
                        int id =
                        gid[0] * info.out_size[0] * info.out_size[1] * info.out_size[2] +
                        c * info.out_size[1] * info.out_size[2] +
                        i * info.out_size[2] +
                        j;
                        
                        if (ic >= core_length || id >= delta_length) continue;
                        
                        da[index] += core[ic] * delta[id];
                    }
                }
            }
        }
    }
}

kernel void conv_backward_2(device const conv_layer_info &info,
                            device const float *input,
                            device const float *delta,
                            device const bool &need_bias,
                            device const int &input_length,
                            device const int &delta_length,
                            device const int &dbias_length,
                            device const int &dcore_length,
                            device float *dbias,
                            device float *dcore,
                            uint3 gid [[thread_position_in_grid ]])
{   // gid = [batch, count * depth, width * height]
    int c = gid[1] / info.in_size[0];
    int z = gid[1] % info.in_size[0];
    int x = gid[2] / info.core_size[2];
    int y = gid[2] % info.core_size[2];
    float sum = 0.0;
    
    for (int i = 0; i < info.out_size[1]; i++) {
        for (int j = 0; j < info.out_size[2]; j++) {
            int id =
            gid[0] * info.out_size[0] * info.out_size[1] * info.out_size[2] +
            c * info.out_size[1] * info.out_size[2] +
            i * info.out_size[2] +
            j;
            
            if (id >= delta_length) continue;
            
            float cur_delta = delta[id];
            sum += cur_delta;
            
            int rx = i * info.stride + x - info.padding;
            int ry = j * info.stride + y - info.padding;
            if (in_bound(rx, ry, info.in_size[1], info.in_size[2])) {
                int ic =
                gid[0] * info.out_size[0] * info.core_size[0] * info.core_size[1] * info.core_size[2] +
                c * info.core_size[0] * info.core_size[1] * info.core_size[2] +
                z * info.core_size[1] * info.core_size[2] +
                x * info.core_size[2] +
                y;
                
                int ii =
                gid[0] * info.in_size[0] * info.in_size[1] * info.in_size[2] +
                z * info.in_size[1] * info.in_size[2] +
                rx * info.in_size[2] +
                ry;
                
                if (ic >= dcore_length || ii >= input_length) continue;
                
                dcore[ic] += input[ii] * cur_delta;
            }
        }
    }
    
    if (need_bias && z == 0 && gid[2] == 0) {
        int ib = gid[0] * info.out_size[0] + c;
        if (ib >= dbias_length) return;
        dbias[ib] += sum;
    }
}

// MARK: - dense_m

kernel void dense_matrix_mul(device const float *input,
                             device const int &out_features,
                             device const int &in_features,
                             device float *matrix,
                             uint3 gid [[ thread_position_in_grid ]])
{
    // gid = [batch, outFeatures, inFeatures]
    matrix[gid[0] * out_features * in_features +
           gid[1] * in_features +
           gid[2]]
    *=
    input[gid[0] * in_features +
          gid[2]];
}

kernel void dense_matrix_sum(device const float *matrix,
                             device const int &in_features,
                             device const int &out_features,
                             device const float *bi,
                             device const bool &need_relu,
                             device float *score,
                             device float *inter_score,
                             uint2 gid [[ thread_position_in_grid ]])
{
    // gid = [batch, outFeatures]
    int start = gid[0] * in_features * out_features + gid[1] * in_features;
    int index = gid[0] * out_features + gid[1];
    inter_score[index] = 0.0;
    
    for (int i = 0; i < in_features; i++) {
        inter_score[index] += matrix[start + i];
    }

    score[index] = inter_score[index];
    if (need_relu && inter_score[index] < 0.0) {
        score[index] *= 0.001;
    }
    
    score[index] += bi[gid[1]];
}

kernel void dense_backward_1(device const bool &need_relu,
                             device const int &out_features,
                             device const int &in_features,
                             device const float *matrix,
                             device const float *delta,
                             device const float *inter_score,
                             device float *da,
                             uint2 gid [[ thread_position_in_grid ]])
{
    // gid = [batch, inFeatures]
    int index = gid[0] * in_features + gid[1];
    da[index] = 0.0;
    for (int i = 0; i < out_features; i++) {
        float d = delta[gid[0] * out_features + i] * matrix[i * in_features + gid[1]];
        
        if (need_relu && inter_score[gid[0] * out_features + i] < 0.0) {
            da[index] += d * 0.001;
        } else {
            da[index] += d;
        }
    }
}

kernel void dense_backward_2(device const bool &need_relu,
                             device const int &out_features,
                             device const int &in_features,
                             device const float *delta,
                             device const float *input,
                             device const float *inter_score,
                             device float *dparam,
                             device float *dbias,
                             uint3 gid [[ thread_position_in_grid ]])
{
    // gid = [batch, outFeatures, inFeatures]
    int batch = gid[0];
    int i = gid[1];
    int j = gid[2];
    
    if (j == 0) {
        dbias[batch * out_features + i] += delta[batch * out_features + i];
    }
    
    float d = delta[batch * out_features + i] * input[batch * in_features + j];
    int index = batch * in_features * out_features + i * in_features + j;
    if (need_relu && inter_score[batch * out_features + i] < 0.0) {
        dparam[index] += d * 0.001;
    } else {
        dparam[index] += d;
    }
}

// MARK: - avgpool_m

kernel void averagepool_forward(device const pooling_layer_info &info,
                                device const float *input,
                                device float *score,
                                uint3 gid [[ thread_position_in_grid ]])
{
    int batch = gid[0];
    int k = gid[1];
    int i = gid[2] / info.out_size[1];
    int j = gid[2] % info.out_size[1];
    
    int ri = i * info.stride;
    int rj = j * info.stride;
    
    float sum = 0.0;
    
    for (int x = 0; x < info.core_size[0]; x++) {
        for (int y = 0; y < info.core_size[1]; y++) {
            int rx = x + ri;
            int ry = y + rj;
            
            sum += input[batch * info.in_size[0] * info.in_size[1] * info.in_size[2] +
                         k * info.in_size[1] * info.in_size[2] +
                         rx * info.in_size[2] +
                         ry];
        }
    }
    
    score[batch * info.in_size[0] * info.out_size[0] * info.out_size[1] +
          k * info.out_size[0] * info.out_size[1] +
          i * info.out_size[1] +
          j]
    = sum / (float)(info.core_size[0] * info.core_size[1]);
}

kernel void averagepool_backward(device const pooling_layer_info &info,
                                 device const float *delta,
                                 device float *da,
                                 uint3 gid [[ thread_position_in_grid ]])
{
    int batch = gid[0];
    int k = gid[1];
    int i = gid[2] / info.in_size[1];
    int j = gid[2] % info.in_size[1];
    
    int ri = i / info.core_size[0];
    int rj = j / info.core_size[1];
    
    da[batch * info.in_size[0] * info.in_size[0] * info.in_size[1] +
       k * info.in_size[0] * info.in_size[1] +
       i * info.in_size[1] +
       j]
    =
    delta[batch * info.in_size[0] * info.out_size[0] * info.out_size[1] +
          k * info.out_size[0] * info.out_size[1] +
          ri * info.out_size[1] +
          rj]
    / (float)(info.core_size[0] * info.core_size[1]);
}

// MARK: - maxpool_m

struct switch_mapper {
    int batch;
    int3 inpos, outpos;
};

kernel void maxpooling_forward(device const pooling_layer_info &info,
                               device const float *input,
                               device switch_mapper *switches,
                               device float *score,
                               uint3 gid [[ thread_position_in_grid ]])
{
    // gid = [batch, depth, row * col]
    int i = gid[2] / info.out_size[1];
    int j = gid[2] % info.out_size[1];
    int ri = i * info.stride;
    int rj = j * info.stride;
    int2 max_pos = {ri, rj};
    float maxv = -MAXFLOAT;
    if (in_bound(ri, rj, info.in_size[1], info.in_size[2])) {
        maxv = input[gid[0] * info.in_size[0] * info.in_size[1] * info.in_size[2] +
                     gid[1] * info.in_size[1] * info.in_size[2] +
                     ri * info.in_size[2] +
                     rj];
    }
    
    for (int x = 0; x < info.core_size[0]; x++) {
        for (int y = 0; y < info.core_size[1]; y++) {
            int rx = ri + x - info.padding, ry = rj + y - info.padding;
            if (!in_bound(rx, ry, info.in_size[1], info.in_size[2])) {
                continue;
            }
            
            float curv = input[gid[0] * info.in_size[0] * info.in_size[1] * info.in_size[2] +
                             gid[1] * info.in_size[1] * info.in_size[2] +
                             rx * info.in_size[2] +
                             ry];
            
            if (maxv < curv) {
                maxv = curv;
                max_pos = {rx, ry};
            }
        }
    }
    
    int index =
        gid[0] * info.in_size[0] * info.out_size[0] * info.out_size[1] +
        gid[1] * info.out_size[0] * info.out_size[1] +
        gid[2];
    
    int3 inpos = {(int)gid[1], max_pos[0], max_pos[1]};
    int3 outpos = {(int)gid[1], i, j};
    switches[index] = switch_mapper {
        (int)gid[0], inpos, outpos
    };
    score[index] = maxv;
}

kernel void maxpooling_backward(device const pooling_layer_info &info,
                                device const switch_mapper *switches,
                                device const float *delta,
                                device float *da,
                                uint3 gid [[ thread_position_in_grid ]])
{
    int batch = gid[0];
    int k = gid[1];
    int ri = gid[2] / info.in_size[2];
    int rj = gid[2] % info.in_size[2];
    
    int pos =
    batch * info.in_size[0] * info.in_size[1] * info.in_size[2] +
    k * info.in_size[1] * info.in_size[2] +
    ri * info.in_size[2] +
    rj;
    
    for (int i = 0; i < info.out_size[0]; i++) {
        for (int j = 0; j < info.out_size[1]; j++) {
            int lui = i * info.stride - info.padding;
            int luj = j * info.stride - info.padding;
            
            if (lui <= ri && ri < lui + info.core_size[0] &&
                luj <= rj && rj < luj + info.core_size[1]) {
                
                int index =
                batch * info.in_size[0] * info.out_size[0] * info.out_size[1] +
                k * info.out_size[0] * info.out_size[1] +
                i * info.out_size[1] +
                j;

                switch_mapper m = switches[index];

                if (m.inpos[1] == ri && m.inpos[2] == rj) {
                    da[pos] += delta[index];
                }
            }
        }
    }
}

// MARK: - relu_m

kernel void relu_forward(device const float *input,
                         device float *score,
                         uint index [[ thread_position_in_grid ]])
{
    score[index] = max(input[index] * 0.001, input[index]);
}

kernel void relu_backward(device const float *input,
                          device const float *delta,
                          device float *da,
                          uint index [[ thread_position_in_grid ]])
{
    da[index] = delta[index];
    if (input[index] < 0.0) {
        da[index] *= 0.001;
    }
}

// MARK: - step_m

kernel void param_step(device const int &batch,
                       device const float &lr,
                       device const float &momentum,
                       device const int &count,
                       device const float *d,
                       device float *m,
                       device float *v,
                       device float *p,
                       uint i [[ thread_position_in_grid ]])
{
    for (int j = 0; j < batch; j++) {
        int idx = j * count + i;
        m[idx] = 0.9 * m[idx] + (1 - 0.9) * d[idx];
        v[idx] = momentum * v[idx] + (1 - 0.9) * d[idx] * d[idx];
        p[i] -= lr * m[idx] / (sqrt(v[idx]) + 0.0000001);
    }
}
