def check_brand_name_whitespace(_, annotations):
    check_applies = True
    for brand_name in annotations['brand_names']:
        trimmed_name = brand_name.strip()
        if trimmed_name != brand_name:
            check_applies = False
            break
    return check_applies