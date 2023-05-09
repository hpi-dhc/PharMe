import bson
import time

def get_object_id():
    return str(bson.ObjectId())

def get_timestamp():
    return round(time.time() * 1000)
