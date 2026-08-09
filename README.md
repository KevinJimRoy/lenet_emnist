Note: This is not exactly lenet-5's architecture but a modified version of it(The image of the modifies architecture is uploaded).
The directory Verilog_files contains all the design files for the CNN in verilog.
The directory mem_files contain the weights, biases and inputs in .mem format which we converted from .hex format via python.
Both the training and the testing were done by using the constrain of all values being in Q3.5 signed format so that it corresponds to how it works in hardware too.
