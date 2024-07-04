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
    empty_tables = []
    for table_name in data.keys():
        if len(data[table_name]) == 0:
            empty_tables.append(table_name)
    for table_name in empty_tables:
        del data[table_name]
    json_temp_path = get_output_file_path(
        postfix, file_ending=JSON_ENDING, temp=True)
    zip_temp_path = get_output_file_path(
        postfix, file_ending=ZIP_ENDING, temp=True)
    base64_temp_path = get_output_file_path(
        postfix, file_ending='.base64', temp=True)
    output_path = get_output_file_path(postfix)
    write_json_file(data, json_temp_path)
    with zipfile.ZipFile(zip_temp_path, 'w') as zip_file:
        zip_file.write(json_temp_path, arcname=get_archive_name())
    with open(zip_temp_path, 'rb') as zip_file:
        with open(base64_temp_path, 'wb') as base64_file:
            base64.encode(zip_file, base64_file)
    with open(base64_temp_path, 'r') as base64_file:
        with open(output_path, 'w') as output_file:
            base64_string = ''
            for line in base64_file.readlines():
                base64_part = line.strip()
                if base64_part != '':
                    base64_string += base64_part
            json.dump({
                'data': {
                    'base64': base64_string
                }
            }, output_file)

def write_log(log_content, postfix):
    log_file_postfix = postfix + '_log'
    log_file_ending = '.md'
    log_file_path = get_output_file_path(
        postfix=log_file_postfix,
        file_ending=log_file_ending)
    with open(log_file_path, 'w') as log_file:
        log_file.writelines(log_content)