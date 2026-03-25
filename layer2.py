import tensorflow as tf
import numpy as np

SCALE = 32.0  
FRACTIONAL_BITS = 5

def to_int8_hex(val):
    val = max(-128, min(127, int(val)))
    return f"{(val & 0xFF):02X}"

model = tf.keras.models.load_model('c:/Users/noinn/Downloads/LeNet MNIST Python/lenet5_mnist.h5')
(_, _), (x_test, _) = tf.keras.datasets.mnist.load_data()

x_test_padded = np.pad(x_test, ((0,0), (2,2), (2,2)), 'constant')
image_float = x_test_padded[0].reshape(1, 32, 32, 1) / 255.0

l1_pool_model = tf.keras.models.Model(inputs=model.inputs, outputs=model.layers[1].output)
l1_pool_out = l1_pool_model.predict(image_float)[0] 

l1_pool_int8 = np.round(l1_pool_out * SCALE).astype(np.int32)
l1_pool_int8 = np.clip(l1_pool_int8, -128, 127)

c3_layer = model.layers[2]
weights, biases = c3_layer.get_weights() 

filters = np.transpose(weights, (3, 0, 1, 2)).reshape(16, 150)

filters_int8 = np.round(filters * SCALE).astype(np.int32)
filters_int8 = np.clip(filters_int8, -128, 127)

biases_int8 = np.round(biases * SCALE).astype(np.int32)
biases_int8 = np.clip(biases_int8, -128, 127)

for f_idx in range(16):
    with open(f'c:/Users/noinn/Downloads/LeNet MNIST Python/l2_weight_f{f_idx}.hex', 'w') as f:
        for w in filters_int8[f_idx]:
            f.write(to_int8_hex(w) + "\n")

with open('c:/Users/noinn/Downloads/LeNet MNIST Python/l2_bias.hex', 'w') as f:
    for b in biases_int8:
        f.write(to_int8_hex(b) + "\n")

for f_idx in range(16):
    fmap_int8 = np.zeros((10, 10), dtype=np.int32)
    
    weight_kernel = filters_int8[f_idx].reshape(5, 5, 6)
    bias_val = biases_int8[f_idx]
    
    for y in range(10):
        for x in range(10):
            patch = l1_pool_int8[y:y+5, x:x+5, :]
            
            mac_accumulator = np.sum(patch * weight_kernel)
            mac_accumulator += (bias_val * int(SCALE))
            
            out_val = mac_accumulator // int(SCALE)
            
            if out_val < 0:
                out_val = 0
            out_val = min(127, out_val)
            
            fmap_int8[y, x] = out_val
            
    with open(f'c:/Users/noinn/Downloads/LeNet MNIST Python/l2_expected_fmap_{f_idx}.hex', 'w') as f:
        for val in fmap_int8.flatten():
            f.write(to_int8_hex(val) + "\n")