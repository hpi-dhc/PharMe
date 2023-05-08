import base64
import json
import os
import zipfile

from datetime import datetime

from .constants import BASE64_ENDING
from .constants import TEMP_DIR_NAME
from .constants import JSON_ENDING
from .constants import ZIP_ENDING
from .make_temp_dir import make_temp_dir
from .get_data import get_input_file_path

def get_file_name(file_path):
    return os.path.basename(file_path).split('.')[0]

def get_output_file_path(postfix='', file_ending=BASE64_ENDING, temp=False):
    input_file_path = get_input_file_path()
    input_file_name = get_file_name(input_file_path)
    output_path = os.path.dirname(input_file_path)
    if temp:
        make_temp_dir()
        output_path = TEMP_DIR_NAME
    timestamp_postfix = datetime.now().strftime('_%y%m%d%H%M%S')
    output_file_name = input_file_name + postfix + timestamp_postfix + \
        file_ending
    return os.path.join(output_path, output_file_name)

def get_archive_name():
    return 'backup.json'

def write_json_file(data, file_path):
    with open(file_path, 'w') as json_file:
        json.dump(data, json_file)

def write_data(data, postfix=''):
    json_temp_path = get_output_file_path(
        postfix, file_ending=JSON_ENDING, temp=True)
    zip_temp_path = get_output_file_path(
        postfix, file_ending=ZIP_ENDING, temp=True)
    output_path = get_output_file_path(postfix)
    write_json_file(data, json_temp_path)
    with zipfile.ZipFile(zip_temp_path, 'w') as zip_file:
        zip_file.write(json_temp_path, arcname=get_archive_name())
    with open(zip_temp_path, 'rb') as zip_file:
        with open(output_path, 'wb') as base64_file:
            base64.encode(zip_file, base64_file)
