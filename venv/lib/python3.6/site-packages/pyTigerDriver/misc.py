# -*- coding: utf-8 -*-

try:
    
    from urllib.parse import quote_plus, urlencode
    from http.client import HTTPConnection, HTTPSConnection

    def native_str(s):
        return s


    def is_str(s):
        return isinstance(s, str)

except ImportError:
    from urllib import quote_plus, urlencode
    from httplib import HTTPConnection, HTTPSConnection


    def native_str(s):
        if isinstance(s, unicode):
            return s.encode("utf-8")
        else: 
            return s


    def is_str(s):
        return isinstance(s, (str, unicode))

try:
    import ssl

    is_ssl = True
except ImportError:
    is_ssl = False

class ExceptionAuth(Exception):
    pass
