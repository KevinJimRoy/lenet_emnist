import tensorflow as tf
import numpy as np

# ==========================================
# 1. Configuration: Q3.5 Fixed-Point Format
# ==========================================
# 5 fractional bits means a scale of 32
SCALE = 32.0  
FRACTIONAL_BITS = 5

def to_int8_hex(val):
    """Formats an 8-bit signed integer to 2-digit HEX."""
    val = max(-128, min(127, int(val)))
    return f"{(val & 0xFF):02X}"

print("Loading trained model and data...")
model = tf.keras.models.load_model('lenet5_mnist.h5')
(_, _), (x_test, _) = tf.keras.datasets.mnist.load_data()

# ==========================================
# 2. Extract and Quantize Weights & Biases
# ==========================================
c1_layer = model.layers[0]
weights, biases = c1_layer.get_weights()
filters = np.transpose(weights, (3, 0, 1, 2)).reshape(6, 25)

# Convert to integers by multiplying by 32 and rounding
filters_int8 = np.round(filters * SCALE).astype(np.int32)
filters_int8 = np.clip(filters_int8, -128, 127)

biases_int8 = np.round(biases * SCALE).astype(np.int32)
biases_int8 = np.clip(biases_int8, -128, 127)

# Write Weights
for f_idx in range(6):
    with open(f'c1_weight_f{f_idx}.hex', 'w') as f:
        for w in filters_int8[f_idx]:
            f.write(to_int8_hex(w) + "\n")

# Write Biases
with open('c1_bias.hex', 'w') as f:
    for b in biases_int8:
        f.write(to_int8_hex(b) + "\n")

# ==========================================
# 3. Quantize the Input Image
# ==========================================
x_test_padded = np.pad(x_test, ((0,0), (2,2), (2,2)), 'constant')
image_float = x_test_padded[0].reshape(32, 32) / 255.0

image_int8 = np.round(image_float * SCALE).astype(np.int32)
image_int8 = np.clip(image_int8, -128, 127)

with open('input_image.hex', 'w') as f:
    for val in image_int8.flatten():
        f.write(to_int8_hex(val) + "\n")

# ==========================================
# 4. Hardware Simulation (Expected Outputs)
# ==========================================
print("\nSimulating Verilog integer MAC operations...")

for f_idx in range(6):
    fmap_int8 = np.zeros((28, 28), dtype=np.int32)
    weight_kernel = filters_int8[f_idx].reshape(5, 5)
    bias_val = biases_int8[f_idx]
    
    for y in range(28):
        for x in range(28):
            # 1. Grab 5x5 pixel patch
            patch = image_int8[y:y+5, x:x+5]
            
            # 2. MAC Operation
            # Multiplying two Q3.5 numbers creates a Q6.10 number.
            mac_accumulator = np.sum(patch * weight_kernel)
            
            # 3. Add Bias
            # Since the bias is Q3.5, we must bit-shift it left by 5 (multiply by 32)
            # so it matches the Q6.10 scale before adding it to the accumulator.
            mac_accumulator += (bias_val * int(SCALE))
            
            # 4. Shift back to Q3.5
            # In Verilog, this is: out_val = mac_accumulator >>> 5;
            out_val = mac_accumulator // int(SCALE)
            
            # 5. Hardware ReLU Activation
            if out_val < 0:
                out_val = 0
                
            # 6. Prevent Overflow (Saturate to 8-bit limits)
            out_val = min(127, out_val)
            
            fmap_int8[y, x] = out_val
            
    # Write the calculated expected feature map to file
    with open(f'c1_expected_fmap_{f_idx}.hex', 'w') as f:
        for val in fmap_int8.flatten():
            f.write(to_int8_hex(val) + "\n")

print("Files generated. The expected hex files will no longer saturate!")