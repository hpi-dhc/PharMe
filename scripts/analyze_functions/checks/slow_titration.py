import analyze_functions.constants as constants
from analyze_functions.data_helpers import get_guideline_content

def check_slow_titration(args):
    guideline = args['item']
    annotations = args['annotations']
    guideline_recommendation = get_guideline_content(guideline, 'recommendation')
    should_have_slow_titration = 'slower titration' in guideline_recommendation \
        and not 'lower dose' in annotations['recommendation']
    has_slow_titration = 'cautiously and slowly' in annotations['recommendation']
    return not should_have_slow_titration or has_slow_titration