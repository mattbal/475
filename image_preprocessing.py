import cv2
import os

# Downsize the images. Need to do this before training our model, 
# so that our annotations remain consistent (the annotations
# contain the exact coordinates where the attributes are at)
for filename in os.listdir('original_data'):
  path = os.path.join('original_data', filename)
  print(filename)
  if filename == ".DS_Store": # macOS sometimes creates this file, skip it or it will break program
    continue
  image = cv2.imread(path)
  (h, w) = image.shape[:2] # get height and width
  r = 800 / float(h) # calculate ratio
  dim = (int(w * r), 800) # resize the image to have a height of 800
  resized_image = cv2.resize(image, dim, interpolation = cv2.INTER_AREA)

  cv2.imwrite(f'data/{filename}', resized_image)