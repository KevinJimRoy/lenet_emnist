import tensorflow as tf
from tensorflow.keras import layers, models, constraints
import numpy as np

SCALE = 32.0

class Q35WeightConstraint(constraints.Constraint):
    def __call__(self, w):
        w_scaled = tf.round(w * SCALE)
        w_clipped = tf.clip_by_value(w_scaled, -128.0, 127.0)
        return w_clipped / SCALE

class HardwareReLU(layers.Layer):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)

    def call(self, inputs):
        @tf.custom_gradient
        def _fake_quant(x):
            x_scaled = tf.round(x * SCALE)
            x_clipped = tf.clip_by_value(x_scaled, 0.0, 127.0)
            result = x_clipped / SCALE
            
            # The "Straight-Through Estimator"
            def grad(dy):
                return dy
            return result, grad
        
        return _fake_quant(inputs)

(x_train, y_train), (x_test, y_test) = tf.keras.datasets.mnist.load_data()

x_train = np.pad(x_train, ((0,0), (2,2), (2,2)), 'constant')
x_test = np.pad(x_test, ((0,0), (2,2), (2,2)), 'constant')

x_train = x_train.reshape(-1, 32, 32, 1).astype('float32') / 255.0
x_test = x_test.reshape(-1, 32, 32, 1).astype('float32') / 255.0

model = models.Sequential()

# Layer 1
model.add(layers.Conv2D(6, (5, 5), 
                        kernel_constraint=Q35WeightConstraint(), 
                        bias_constraint=Q35WeightConstraint(), 
                        input_shape=(32, 32, 1)))
model.add(HardwareReLU())
model.add(layers.MaxPooling2D((2, 2), strides=(2, 2)))

# Layer 2
model.add(layers.Conv2D(16, (5, 5), 
                        kernel_constraint=Q35WeightConstraint(), 
                        bias_constraint=Q35WeightConstraint()))
model.add(HardwareReLU())
model.add(layers.MaxPooling2D((2, 2), strides=(2, 2)))

model.add(layers.Flatten())

# Dense Layers
model.add(layers.Dense(120, kernel_constraint=Q35WeightConstraint(), bias_constraint=Q35WeightConstraint()))
model.add(HardwareReLU())

model.add(layers.Dense(84, kernel_constraint=Q35WeightConstraint(), bias_constraint=Q35WeightConstraint()))
model.add(HardwareReLU())

# Output Layer (Standard Softmax)
model.add(layers.Dense(10, activation='softmax'))

model.summary()

model.compile(optimizer='adam', 
              loss='sparse_categorical_crossentropy', 
              metrics=['accuracy'])

print("\n--- Starting Hardware-Aware Training ---")
history = model.fit(x_train, y_train, epochs=5, batch_size=128, validation_data=(x_test, y_test))

test_loss, test_acc = model.evaluate(x_test, y_test, verbose=2)
print(f"\nFinal Hardware-Simulated Accuracy: {test_acc * 100:.2f}%")

model.save('lenet5_mnist.h5')
print("Model successfully saved as 'lenet5_mnist.h5'")