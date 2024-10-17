from analyze_functions.constants import IGNORE_STAGED_CHECK

def check_if_fully_annotated_staged(args):
    if args['drug_name'] in IGNORE_STAGED_CHECK: return None
    item = args['item']
    isStaged = item['isStaged']
    if isStaged: return True
    annotations = args['annotations']
    isFullyAnnotated = all(map(
        lambda annotationKey: annotations[annotationKey] != None,
        annotations.keys(),
    ))
    return isFullyAnnotated and isStaged    
