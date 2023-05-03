import os
import shutil

from common.constants import TEMP_DIR_NAME
from common.constants import SCRIPT_POSTFIXES

if os.path.isdir(TEMP_DIR_NAME):
    shutil.rmtree(TEMP_DIR_NAME)
for file_name in os.listdir():
    is_result_file = any(map(
        lambda script_postfix: script_postfix in file_name,
        SCRIPT_POSTFIXES.values()))
    if is_result_file:
        os.remove(file_name)
