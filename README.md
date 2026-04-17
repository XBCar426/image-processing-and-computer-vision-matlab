# MATLAB Image Processing and Computer Vision Projects

This repository contains MATLAB implementations of image processing, computer vision, and basic machine learning techniques. The work focuses on segmentation, enhancement, motion analysis, and neural networks using real-world and biomedical image datasets.

Machine Learning:
- mnist_main.m – Implements a neural network for MNIST digit classification, including data loading, normalization, training, validation, and k-fold cross-validation. :contentReference[oaicite:0]{index=0}  
- nn_forward_backward.m – Performs forward propagation and backpropagation using ReLU activation and softmax output with cross-entropy loss. :contentReference[oaicite:1]{index=1}  

Motion Analysis:
- Motion_Estimation.m – Computes optical flow between consecutive frames and identifies moving objects based on motion magnitude and thresholding. :contentReference[oaicite:2]{index=2}  

Image Enhancement:
- Nature.m – Enhances an image using histogram equalization (CLAHE), color scaling, and sharpening, with histogram comparison before and after processing. :contentReference[oaicite:3]{index=3}  
- Valley_Enhancement.m – Applies histogram equalization to improve contrast and visual clarity of grayscale images. :contentReference[oaicite:4]{index=4}  
- Winter_Grayscale.m – Converts a color image to grayscale and displays both versions for comparison. :contentReference[oaicite:5]{index=5}  
- Grayscale_Desert.m – Converts desert images to grayscale for further analysis. :contentReference[oaicite:6]{index=6}  
- grayscale_1.m – Performs basic grayscale conversion and preprocessing.  

Histogram Analysis:
- Snow_Histogram.m – Extracts a region of interest and computes a normalized histogram to analyze pixel intensity distribution. :contentReference[oaicite:7]{index=7}  
- Histogram_Overlay.m – Compares intensity distributions by overlaying normalized histograms of different images. :contentReference[oaicite:8]{index=8}  

Filtering and Denoising:
- TV.m – Implements total variation (Chambolle) denoising for noise reduction in grayscale images. :contentReference[oaicite:9]{index=9}  

Segmentation:
- cryoEM_ACWE_segmentation.m – Performs segmentation on Cryo-EM images using total variation smoothing followed by active contour (Chan–Vese) methods and evaluates performance across iterations. :contentReference[oaicite:10]{index=10}  

Object Detection and Shape Analysis:
- _CoffeeBeans.m – Segments the largest object in an image, extracts its boundary, and analyzes curvature before and after rotation. :contentReference[oaicite:11]{index=11}  

Feature Detection and Computer Vision:
- Houghs.m – Applies the Hough Transform for detecting lines and geometric features in images.  
- Lenna_Pryamid.m – Constructs a multi-level image pyramid for scale-space analysis using downsampling. :contentReference[oaicite:12]{index=12}  

Visualization and Utilities:
- DW_Overlay.m – Generates overlay visualizations for comparing processed image outputs.  
- make_flowchart.m – Creates a structured flowchart for data processing and visualization workflows. :contentReference[oaicite:13]{index=13}  
