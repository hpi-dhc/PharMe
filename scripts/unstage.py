from common.get_data import get_data
from common.write_data import write_data
from common.constants import SCRIPT_POSTFIXES

def unstage_data():
    data = get_data()
    for table_name in data.keys():
        for item in data[table_name]:
            if 'isStaged' in item.keys():
                item['isStaged'] = False
    write_data(data, postfix=SCRIPT_POSTFIXES['unstage'])

if __name__ == '__main__':
    unstage_data()