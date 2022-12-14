# Folder Structure Explained

The iOS app is located inside of the `RecipeBox` folder.

The data folder contains all of the recipe photos in a jpg format

annotations.json is the annotations for the images in the dataset. There are currently ~800 annotations.

The order the ML algorithm would be run in is as follows:

1. image_preprocessing.jpg
2. R-CNN.py
3. ocr_algorithm.py
