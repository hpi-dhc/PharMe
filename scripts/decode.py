from common.get_data import get_data
from common.write_data import get_output_file_path
from common.write_data import write_json_file
from common.constants import SCRIPT_POSTFIXES
from common.constants import JSON_ENDING

write_json_file(get_data(), get_output_file_path(
    postfix=SCRIPT_POSTFIXES['decode'],
    file_ending=JSON_ENDING))
