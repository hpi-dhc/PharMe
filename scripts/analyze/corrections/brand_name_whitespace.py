def correct_brand_name_whitespace(_, drug):
    drug['annotations']['brandNames'] = list(map(
        lambda brand_name: brand_name.strip(),
        drug['annotations']['brandNames']))