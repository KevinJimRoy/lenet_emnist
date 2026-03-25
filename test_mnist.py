import tensorflow as tf
import numpy as np
import matplotlib.pyplot as plt

print("Loading MNIST data...")
(x_train, y_train), (x_test, y_test) = tf.keras.datasets.mnist.load_data()

x_test_padded = np.pad(x_test, ((0,0), (2,2), (2,2)), 'constant')
x_test_ready = x_test_padded.reshape(-1, 32, 32, 1).astype('float32') / 255.0

print("Loading trained model...")
model = tf.keras.models.load_model('c:/Users/noinn/Downloads/LeNet MNIST Python/lenet5_mnist.h5')

print("\n--- Running Bulk Test on 10,000 images ---")
loss, accuracy = model.evaluate(x_test_ready, y_test, verbose=0)
print(f"Total Network Accuracy: {accuracy * 100:.2f}%")

print("\n--- Running Random Individual Predictions ---")
# Pick 5 random indices from the 10,000 test images
random_indices = np.random.choice(len(x_test), 5, replace=False)

images_to_test = x_test_ready[random_indices]
true_labels = y_test[random_indices]
original_images_to_display = x_test[random_indices]

predictions = model.predict(images_to_test)

# Set up a plot with 1 row and 5 columns
fig, axes = plt.subplots(1, 5, figsize=(15, 3))

for i in range(5):
    predicted_digit = np.argmax(predictions[i])
    actual_digit = true_labels[i]
    
    # Print results to the console
    print(f"Test Index {random_indices[i]}: Network Guessed: {predicted_digit} | Actual Answer: {actual_digit}")
    
    # Display the image and prediction in the plot
    axes[i].imshow(original_images_to_display[i], cmap='gray')
    axes[i].set_title(f"Pred: {predicted_digit} | Act: {actual_digit}")
    axes[i].axis('off')  # Hides the grid axis for a cleaner look

plt.tight_layout()
plt.show()