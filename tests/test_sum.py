# https://stackoverflow.com/questions/14132789/relative-imports-for-the-billionth-time
# https://realpython.com/absolute-vs-relative-python-imports/
if __name__ == '__main__' and __package__ is None:
    from os import sys, path
    # __file__ should be defined in this case
    PARENT_DIR = path.dirname(path.dirname(path.abspath(__file__)))
    sys.path.append(PARENT_DIR)

from patfu.sum.main import func as func

def test_func():
    '''test multiplication'''
    assert func(2,5) == 7
    assert func(2,2) == 4
    assert func(2,0) == 2


if __name__ == '__main__':
    test_func()