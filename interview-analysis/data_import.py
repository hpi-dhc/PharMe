import deepl, os
from dotenv import load_dotenv

load_dotenv()
translator = deepl.Translator(os.getenv('DEEPL_AUTH_KEY'))
def translate(text):
    return str(translator.translate_text(text, target_lang='EN-US'))

import csv, numpy

# `use_col(str) -> bool` determines if column should be included in output
def columns_from(source, use_col=lambda c: True, should_translate=False, file_out=None):
    with open(source, 'r') as fp:
        reader = csv.reader(fp)
        cols = { f: n for n, f in enumerate(next(reader)) if use_col(f) }
        data = [[translate(row[i]) for i in cols.values()] for row in reader] if should_translate\
            else [[row[i] for i in cols.values()] for row in reader]
    if file_out:
        with open(file_out, 'w', newline='') as fp:
            writer = csv.writer(fp)
            writer.writerow(cols.keys())
            for row in data: writer.writerow(row)
    return dict(zip(cols.keys(), numpy.rot90(data, 3)))

