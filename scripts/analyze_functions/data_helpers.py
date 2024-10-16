from common.constants import BRICK_COLLECTION_NAME

def get_guideline_content(guideline, key):
    return guideline['externalData'][0][key]

def joint_implication_text(guideline):
    return '–'.join(sorted(set(get_guideline_content(guideline, 'implications').values()))).lower()

def ensure_unique_item(item_filter, field_name, value):
    item = list(item_filter)
    if len(item) != 1:
        message = f'[ERROR] Items are not unique for {field_name} == ' \
            f'{value}: {item}'
        raise Exception(message)
    return item[0]

def get_unique_item(items, field_name, value):
    item_filter = filter(lambda item: item[field_name] == value, items)
    return ensure_unique_item(item_filter, field_name, value)

def get_english_text(brick):
    translation = get_unique_item(brick['translations'], 'language', 'English')
    return translation['text'].lower()

def get_brick_meaning(data, brick_id):
    bricks = data[BRICK_COLLECTION_NAME]
    brick = get_unique_item(bricks, '_id', brick_id)
    return get_english_text(brick)

def get_bricks_meaning(data, brick_ids):
    return ' '.join(map(
        lambda brick_id: get_brick_meaning(data, brick_id),
        brick_ids))

def get_used_bricks(item):
    used_bricks = []
    for brick_list in item['annotations'].values():
        used_bricks += brick_list
    return used_bricks

def get_brick_ids(data):
    return list(map(
        lambda brick: brick['_id'],
        data[BRICK_COLLECTION_NAME],
    ))

def get_annotation(data, item, key, resolve=True):
    if not key in item['annotations']: return None
    annotation = item['annotations'][key]
    if resolve: annotation = get_bricks_meaning(data, annotation)
    return annotation

def get_guideline_annotations(data, guideline):
    return {
        'implication': get_annotation(data, guideline, 'implication'),
        'recommendation': get_annotation(data, guideline, 'recommendation'),
        'warning_level': get_annotation(data, guideline, 'warningLevel',
            resolve=False)
    }

def get_drug_annotations(data, drug):
    return {
        'drugclass': get_annotation(data, drug, 'drugclass'),
        'indication': get_annotation(data, drug, 'indication'),
        'brand_names': get_annotation(data, drug, 'brandNames', resolve=False)
    }

def has_annotations(annotations):
    return all(list(map(
        lambda value: value != None,
        annotations.values())))