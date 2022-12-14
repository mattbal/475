import torch, detectron2
import numpy as np
import os, json, cv2, random
from detectron2.config import get_cfg
from detectron2.engine import DefaultTrainer, DefaultPredictor
from detectron2.utils.visualizer import Visualizer, ColorMode
from detectron2.structures import BoxMode
from detectron2.data import MetadataCatalog, DatasetCatalog
from detectron2 import model_zoo # for cfg

def get_recipe_dicts(root_dir):
  json_file = os.path.join(root_dir, 'annotations.json')
  with open(json_file) as f:
    annotations = json.load(f)

  """
  Example of an annotation:
  {
    "IMG_3927.jpg128565": {
      "filename": "IMG_3927.jpg",
      "size": 128565,
      "regions": [
        {
          "shape_attributes": {
            "name": "rect",
            "x": 80,
            "y": 172,
            "width": 195,
            "height": 36
          },
          "region_attributes": {
            "class": "title"
          }
        },
        {
          "shape_attributes": {
            "name": "rect",
            "x": 74,
            "y": 296,
            "width": 346,
            "height": 131
          },
          "region_attributes": {
            "class": "ingredients"
          }
        },
        {
          "shape_attributes": {
            "name": "rect",
            "x": 73,
            "y": 427,
            "width": 344,
            "height": 78
          },
          "region_attributes": {
            "class": "steps"
          }
        }
      ],
    },
  }       
  """

  dataset_dicts = []
  for idx, v in enumerate(annotations):
    record = {}

    filename = os.path.join(root_dir, v['filename'])
    h, w = cv2.imread(filename).shape[:2]

    # insert important information from annotations into record
    record['file_name'] = filename
    record['image_id'] = idx
    record['height'] = h
    record['width'] = w

    annotation_shapes = v['regions']
    objs = []

    for _, a in annotation_shapes:
      assert not a['region_attributes']
      b = a['shape_attributes']
      class_type = a['region_attributes']['class']

      if class_type == 'title':
        category_id = 1
      elif class_type == 'ingredients':
        category_id = 2
      elif class_type == 'steps':
        category_id = 3

      obj = {
        'bbox': [b['x'], b['y'], b['width'], b['height']],
        'bbox_mode': BoxMode.XYWH_ABS,

        'category_id': category_id
      }
      objs.append(obj)
    record['annotations'] = objs
    dataset_dicts.append(record)
  return dataset_dicts

# TODO: need to split data into training and testing
for d in ['train', 'val']:
  DatasetCatalog.register('recipe_' + d, lambda d=d: get_recipe_dicts('data/' + d))
recipe_metadata = MetadataCatalog.get('recipe_train')

# Verify the dataset is formatted correct by visualizing an image with the annotation
dataset_dicts = get_recipe_dicts('data/train')
for d in random.sample(dataset_dicts, 3):
  img = cv2.imread(d['file_name'])
  visualizer = Visualizer(img[:, :, ::-1], metadata=recipe_metadata, scale=0.5)
  out = visualizer.draw_dataset_dict(d)
  cv2_imshow(out.get_image()[:, :, ::-1])


# Train
cfg = get_cfg()
cfg.merge_from_file(model_zoo.get_config_file('COCO-InstanceSegmentation/mask_rcnn_R_50_FPN_3x.yaml'))
cfg.DATASETS.TRAIN = ('recipe_train',)
cfg.DATASETS.TEST = ()
cfg.DATALOADER.NUM_WORKERS = 2
# need to probably specify our own weights in future
cfg.MODEL.WEIGHTS = model_zoo.get_checkpoint_url("COCO-InstanceSegmentation/mask_rcnn_R_50_FPN_3x.yaml")
cfg.SOLVER.IMS_PER_BATCH = 2  # the real "batch size"
cfg.SOLVER.BASE_LR = 0.00025 # learning rate
cfg.SOLVER.MAX_ITER = 300
cfg.SOLVER.STEPS = [] # do not decay learning rate
cfg.MODEL.ROI_HEADS.BATCH_SIZE_PER_IMAGE = 128 # The "RoIHead batch size"
cfg.MODEL.ROI_HEADS.NUM_CLASSES = 3 # title + ingredients + steps

os.makedirs(cfg.OUTPUT_DIR, exist_ok=True)
trainer = DefaultTrainer(cfg) 
trainer.resume_or_load(resume=False)
trainer.train()


# Inference and evaluation
cfg.MODEL.WEIGHTS = os.path.join(cfg.OUTPUT_DIR, "model_final.pth")  # path to the model we just trained
cfg.MODEL.ROI_HEADS.SCORE_THRESH_TEST = 0.7   # set a custom testing threshold
predictor = DefaultPredictor(cfg)
dataset_dicts = get_recipe_dicts('recipe/val')
for d in random.sample(dataset_dicts, 3):    
  im = cv2.imread(d["file_name"])
  outputs = predictor(im)
  v = Visualizer(im[:, :, ::-1],
                  metadata=balloon_metadata, 
                  scale=0.5, 
                  instance_mode=ColorMode.IMAGE_BW   # remove the colors of unsegmented pixels. This option is only available for segmentation models
  )
  out = v.draw_instance_predictions(outputs["instances"].to("cpu"))
  cv2_imshow(out.get_image()[:, :, ::-1])