from common.get_data import get_data
from common.write_data import write_data
from common.constants import SCRIPT_POSTFIXES

write_data(get_data(), postfix=SCRIPT_POSTFIXES['encode'])
