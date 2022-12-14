import layoutparser as lp
import cv2

# In the future, given more time, this python script would be converted to a format that works with Apple and the file this gets run on would be based on when a user takes a photo
image = cv2.imread("data/IMG_3934.jpg")
image = image[..., ::-1]

model = lp.Detectron2LayoutModel(
  # load in custom model
  label_map={1: 'title', 2: 'ingredients', 3: 'steps'}
  )

layout = model.detect(image)
lp.draw_box(image, layout, box_width=3)

# There should be only 1 block of each per image, but there may be an image with 2 different combined into one. There are some in the dataset like that
title_blocks = lp.Layout([x for x in layout if x.type =='title'])
ingredients_blocks = lp.Layout([x for x in layout if x.type =='ingredients'])
steps_blocks = lp.Layout([x for x in layout if x.type =='steps'])

# use Tesseract OCR engine
ocr_agent = lp.TesseractAgent(languages='eng')

x = [title_blocks, ingredients_blocks, steps_blocks]
y = ['title', 'ingredients', 'steps']

for idx, section in enumerate(x):
  for block in section:
    segment_image = (block.pad(left=5, right=5, top=5, bottom=5).crop_image(image))
    text = ocr_agent.detect(segment_image)
    block.set(text=text, inplace=True)

  for text in section.get_texts():
    print(f'{y[idx]}: ', text, '\n')

