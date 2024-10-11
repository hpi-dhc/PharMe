import analyze_functions.constants as constants

def should_be_red(annotations):
    return constants.RED_TEXT in annotations['recommendation'] and all(map(
        lambda not_red_text: not_red_text not in annotations['recommendation'],
        constants.NOT_RED_TEXTS,
    ))

def should_be_yellow(annotations):
    return any(map(
        lambda yellow_text: yellow_text in annotations['recommendation'],
        constants.YELLOW_RECOMMENDATION_TEXTS,
    )) or any(map(
        lambda yellow_text: yellow_text in annotations['implication'],
        constants.YELLOW_IMPLICATION_TEXTS,
    )) or (
        # Special case: no other recommendation given
        annotations['recommendation'] == constants.WHOLE_CONSULT_TEXT
    )

def should_be_green(annotations):
    return any(map(
        lambda green_text: green_text in annotations['recommendation'],
        constants.GREEN_TEXTS,
    ))

def check_red_warning_level(args):
    annotations = args['annotations']
    has_warning_level = annotations['warning_level'] == 'red'
    should_have_warning_level = should_be_red(annotations)
    return has_warning_level == should_have_warning_level

def check_yellow_warning_level(args):
    annotations = args['annotations']
    has_warning_level = annotations['warning_level'] == 'yellow'
    should_have_warning_level = not should_be_red(annotations) and \
        should_be_yellow(annotations)
    return has_warning_level if should_have_warning_level else True

def check_green_warning_level(args):
    annotations = args['annotations']
    has_warning_level = annotations['warning_level'] == 'green'
    should_have_warning_level = not should_be_red(annotations) and \
        not should_be_yellow(annotations) and \
        should_be_green(annotations)
    return has_warning_level == should_have_warning_level

def check_none_warning_level(args):
    annotations = args['annotations']
    has_warning_level = annotations['warning_level'] == 'none'
    should_have_warning_level = not should_be_red(annotations) and \
        not should_be_yellow(annotations) and \
        not should_be_green(annotations)
    return has_warning_level == should_have_warning_level