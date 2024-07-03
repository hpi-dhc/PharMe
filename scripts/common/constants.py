JSON_ENDING = ".json"
BASE64_ENDING = ".base64.json"
ZIP_ENDING = ".zip"
VALID_INPUT_ENDINGS = [ JSON_ENDING, BASE64_ENDING ]

TEMP_DIR_NAME = "temp"

SCRIPT_POSTFIXES = {
    'migrate': '_migrated',
    'decode': '_decoded',
    'update': '_updated',
    'encode': '_encoded',
    'correct': '_corrected',
    'reset': '_reset',
    'unstage': '_unstaged',
}

DRUG_COLLECTION_NAME = 'Drug'
GUIDELINE_COLLECTION_NAME = 'Guideline'
APP_DATA_COLLECTION_NAME = 'AppData'
HISTORY_COLLECTION_POSTFIX = '_History'
BRICK_COLLECTION_NAME = 'TextBrick'

NON_RESULT_PHENOTYPES = [ 'No Result', 'Indeterminate' ]

def get_history_collection_name(collection_name):
    return f'{collection_name}{HISTORY_COLLECTION_POSTFIX}'

DRUG_HISTORY_COLLECTION_NAME = get_history_collection_name(DRUG_COLLECTION_NAME)
GUIDELINE_HISTORY_COLLECTION_NAME = get_history_collection_name(
    GUIDELINE_COLLECTION_NAME)
