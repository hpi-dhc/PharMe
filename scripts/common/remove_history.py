def remove_history(data):
    tables_to_be_deleted = []
    for table_name in data.keys():
        if table_name.startswith('AppData') or table_name.endswith('_History'):
            tables_to_be_deleted.append(table_name)
        else:
            for item in data[table_name]:
                item['_v'] = 1
    for table_name in tables_to_be_deleted:
        del data[table_name]
    return data