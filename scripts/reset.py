from common.get_data import get_data
from common.write_data import write_data
from common.constants import SCRIPT_POSTFIXES
from common.remove_history import remove_history

# Migrate data
def reset_data():
    data = remove_history(get_data())
    write_data(data, postfix=SCRIPT_POSTFIXES['reset'])

if __name__ == '__main__':
    reset_data()