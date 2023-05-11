from common.constants import APP_DATA_COLLECTION_NAME
from common.constants import HISTORY_COLLECTION_POSTFIX


def remove_history(data):
    tables_to_be_deleted = []
    for table_name in data.keys():
        if table_name.startswith(APP_DATA_COLLECTION_NAME) or \
            table_name.endswith(HISTORY_COLLECTION_POSTFIX):
            tables_to_be_deleted.append(table_name)
        else:
            for item in data[table_name]:
                item['_v'] = 1
    for table_name in tables_to_be_deleted:
        del data[table_name]
    return data