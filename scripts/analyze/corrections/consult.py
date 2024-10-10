from analyze.data_helpers import ensure_unique_item, get_english_text
from common.constants import BRICK_COLLECTION_NAME

from analyze.checks.constants import CONSULT_TEXT

def get_consult_brick(data):
    brick_filter = filter(
        lambda brick: get_english_text(brick).startswith(CONSULT_TEXT),
        data[BRICK_COLLECTION_NAME])
    return ensure_unique_item(brick_filter, 'brick meaning', CONSULT_TEXT)

def add_consult(data, guideline):
    guideline['annotations']['recommendation'].append(
        get_consult_brick(data)['_id'])