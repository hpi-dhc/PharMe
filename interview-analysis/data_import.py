import requests
# Download Google Sheet with `sheet_id` and `sheet_name` to `file_out`
def fetch_google_sheet(sheet_id, sheet_name, file_out):
    sheet = requests.get(f'https://docs.google.com/spreadsheets/d/{sheet_id}/gviz/tq?tqx=out:csv&sheet={sheet_name}')
    with open(file_out, 'w') as fp:
        fp.write(sheet.text)

import csv, numpy
# Read column-wise dictionary with { column: [elements] } from a CSV file &
# optionally save filtered / translated file
#   `use_col(str) -> bool` determines if column should be included in output
def columns_from(source, use_col=lambda _: True, should_translate=False, file_out=None):
    with open(source, 'r') as fp:
        reader = csv.reader(fp)
        # get picked columns with names n and column indeces i from csv file
        cols = { n: i for i, n in enumerate(next(reader)) if use_col(n) }
        # filter (& optionally translate) csv data for picked columns (by index i)
        data = [[row[i] for i in cols.values()] for row in reader]
        if should_translate:
            import deepl, os
            from dotenv import load_dotenv; load_dotenv()
            translator = deepl.Translator(os.getenv('DEEPL_AUTH_KEY', ''))
            data = [[translator.translate_text(cell, target_lang='EN-US') for cell in row] for row in data]
    if file_out:
        with open(file_out, 'w', newline='') as fp:
            writer = csv.writer(fp)
            writer.writerow(cols.keys())
            for row in data: writer.writerow(row)
    return dict(zip(cols.keys(), numpy.rot90(data, 3)))

