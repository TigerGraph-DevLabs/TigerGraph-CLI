# -*- coding: utf-8 -*-

from .misc import ExceptionAuth
from .pyDriver import GSQL_Client, ExceptionRecursiveRet, ExceptionCodeRet
from .restDriver import REST_Client, REST_ClientError

class Client():
    def __init__(self, server_ip="127.0.0.1", username="tigergraph", password="tigergraph", cacert=""
                 ,version="", commit=""):
        self.Rest = REST_Client(server_ip)
        self.Gsql = GSQL_Client(server_ip=server_ip, username=username, password=password, cacert=cacert
                           ,version=version, commit=commit)