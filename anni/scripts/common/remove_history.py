def remove_history(data):
    for table_name in data.keys():
        if table_name.endswith('_History'):
            data[table_name] = []
        else:
            for item in data[table_name]:
                item['_v'] = 1
    return data