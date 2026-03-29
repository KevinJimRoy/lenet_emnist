import tensorflow as tf
import numpy as np

# ==========================================
# 1. Configuration: Q3.5 Fixed-Point Format
# ==========================================
SCALE = 32.0  

def to_int8_hex(val):
    """Formats an 8-bit signed integer to 2-digit HEX."""
    val = max(-128, min(127, int(val)))
    return f"{(val & 0xFF):02X}"

print("Loading trained model and data...")
model = tf.keras.models.load_model('lenet5_mnist.h5')
(_, _), (x_test, _) = tf.keras.datasets.mnist.load_data()

# Prepare the input image
x_test_padded = np.pad(x_test, ((0,0), (2,2), (2,2)), 'constant')
image_float = x_test_padded[0].reshape(1, 32, 32, 1) / 255.0

# Get the exact output from Layer 2's Max Pooling (S4)
l2_pool_model = tf.keras.models.Model(inputs=model.inputs, outputs=model.layers[3].output)
l2_pool_out = l2_pool_model.predict(image_float)[0] 

# Quantize and flatten the 5x5x16 volume into a 1D array of 400 values
l2_pool_int8 = np.round(l2_pool_out * SCALE).astype(np.int32)
l2_pool_int8 = np.clip(l2_pool_int8, -128, 127).flatten()

# ==========================================
# Helper Function for Dense Hardware Simulation
# ==========================================
def process_dense_layer(layer_name, keras_layer, input_array, use_relu=True):
    print(f"\nProcessing {layer_name}...")
    
    # 1. Extract and format weights
    weights, biases = keras_layer.get_weights()
    # Transpose weights so each row represents all weights for a single neuron
    filters = np.transpose(weights, (1, 0)) 
    
    weights_int8 = np.clip(np.round(filters * SCALE), -128, 127).astype(np.int32)
    biases_int8 = np.clip(np.round(biases * SCALE), -128, 127).astype(np.int32)
    
    num_neurons = weights_int8.shape[0]
    weights_per_neuron = weights_int8.shape[1]
    
    # 2. Write Weights Hex
    with open(f'{layer_name}_weights.hex', 'w') as f:
        for n in range(num_neurons):
            for w in weights_int8[n]:
                f.write(to_int8_hex(w) + "\n")
    print(f"Generated {layer_name}_weights.hex ({num_neurons * weights_per_neuron} lines)")

    # 3. Write Bias Hex
    with open(f'{layer_name}_bias.hex', 'w') as f:
        for b in biases_int8:
            f.write(to_int8_hex(b) + "\n")
    print(f"Generated {layer_name}_bias.hex ({num_neurons} lines)")

    # 4. Hardware Math Simulation
    expected_out = np.zeros(num_neurons, dtype=np.int32)
    
    for n in range(num_neurons):
        # Multiply-Accumulate the entire flat array
        mac = np.sum(input_array * weights_int8[n])
        
        # Add bias (shifted to Q6.10 scale)
        mac += (biases_int8[n] * int(SCALE))
        
        # Shift back to Q3.5
        out_val = mac // int(SCALE)
        
        # Apply ReLU (except for the final output layer)
        if use_relu and out_val < 0:
            out_val = 0
            
        # Saturate to 8-bit
        expected_out[n] = min(127, max(-128, out_val))
        
    # 5. Write Expected Output Hex
    with open(f'{layer_name}_expected_out.hex', 'w') as f:
        for val in expected_out:
            f.write(to_int8_hex(val) + "\n")
    print(f"Generated {layer_name}_expected_out.hex ({num_neurons} lines)")
    
    return expected_out

# ==========================================
# Execute the Dense Pipeline
# ==========================================
# Note: Keras layer indices -> 5: Dense(120), 6: Dense(84), 7: Dense(10)
l3_out = process_dense_layer("l3", model.layers[5], l2_pool_int8, use_relu=True)
l4_out = process_dense_layer("l4", model.layers[6], l3_out, use_relu=True)

# The final layer outputs raw logits (probabilities), so we disable ReLU
l5_out = process_dense_layer("l5", model.layers[7], l4_out, use_relu=False)

print("\nAll dense files successfully generated!")