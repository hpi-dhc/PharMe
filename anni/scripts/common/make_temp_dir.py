import os

from .constants import TEMP_DIR_NAME

def make_temp_dir():
    temp_path = TEMP_DIR_NAME
    if not os.path.isdir(temp_path):
        os.mkdir(temp_path)
