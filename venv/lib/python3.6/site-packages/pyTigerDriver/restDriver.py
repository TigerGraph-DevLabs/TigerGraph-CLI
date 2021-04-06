# -*- coding: utf-8 -*-


import json
import logging

from .misc import HTTPConnection, urlencode, ExceptionAuth, native_str, is_str


class REST_ClientError(Exception):
    pass


class REST_Client(object):
    def __init__(self, server_ip):
        self._token = ""
        server_ip = native_str(server_ip)

        if ":" in server_ip:
            self._server_ip = server_ip
        else:
            self._server_ip = server_ip + ":9000"

        self._logger = logging.getLogger("gsql_client.restpp.RESTPP")

    def _setup_connection(self, method, endpoint, parameters, content):
        url = native_str(endpoint)
        if parameters:
            param_str = native_str(urlencode(parameters))
            if param_str:  # not None nor Empty
                url += "?" + param_str

        headers = {
            "Content-Language": "en-US",
            "Pragma": "no-cache",
            "Cache-Control": "no-cache",
            "Connection": "keep-alive",
            "Content-Type": "application/json"
        }

        if content:
            encoded = content.encode("utf-8")
            headers["Content-Length"] = str(len(encoded))
        else:
            encoded = None

        if self._token:
            headers["Authorization"] = "Bearer {0}".format(self._token)

        conn = HTTPConnection(self._server_ip)
        conn.request(method, url, encoded, headers)
        return conn

    def _request(self, method, endpoint, parameters=None, content=None):
        response = None
        try:
            r = self._setup_connection(method, endpoint, parameters, content)
            response = r.getresponse()
            ret_code = response.status
            if ret_code == 401:
                raise ExceptionAuth("Invalid token!")
            response_text = response.read().decode("utf-8")
            self._logger.debug(response_text)
            
            res = json.loads(response_text, strict=False)

            
            if "error" not in res:
                return res
            elif res["error"] and res["error"] != "false": 
                self._logger.error("API error: " + res["message"])
                raise REST_ClientError(res.get("message", ""))
            elif "token" in res:
                return res["token"]
            elif "results" in res:
                return res["results"]
            elif "message" in res:
                return res["message"]
            else:
                return res
        finally:
            if response:
                response.close()

    def _get(self, endpoint, parameters=None):
        return self._request("GET", endpoint, parameters, None)

    def _post(self, endpoint, parameters=None, content=None):
        return self._request("POST", endpoint, parameters, content)

    def _delete(self, endpoint, parameters=None):
        return self._request("DELETE", endpoint, parameters, None)

    def set_token(self, token):
        """
        set token to use for authentication
        """
        self._token = native_str(token)

    def request_token(self, secret, lifetime=None, use=False):
        
        parameters = {
            "secret": secret
        }
        if lifetime:
            parameters["lifetime"] = lifetime

        res = self._get("/requesttoken", parameters)
        if is_str(res):
            res = native_str(res)
            if use:
                self._token = res
            return res

    def echo(self):
        return self._get("/echo")

    def version(self):
        return self._get("/version")

    def endpoints(self):
        return self._get("/endpoints")

    def license(self):
        return self._get("/showlicenseinfo")

    def stat(self, graph, **kwargs):
        url = "/builtins/" + graph
        return self._post(url, content=json.dumps(kwargs, ensure_ascii=True))

    def stat_vertex_number(self, graph, type_name="*"):
        return self.stat(graph, function="stat_vertex_number", type=type_name)

    def stat_edge_number(self, graph, type_name="*", from_type_name="*", to_type_name="*"):
        return self.stat(graph, function="stat_edge_number", type=type_name,
                         from_type=from_type_name, to_type=to_type_name)

    def stat_vertex_attr(self, graph, type_name="*"):
        return self.stat(graph, function="stat_vertex_attr", type=type_name)

    def stat_edge_attr(self, graph, type_name="*", from_type_name="*", to_type_name="*"):
        return self.stat(graph, function="stat_edge_attr", type=type_name,
                         from_type=from_type_name, to_type=to_type_name)

    def select_vertices(self, graph, vertex_type, vertex_id=None, **kwargs):
        endpoint = "/graph/{0}/vertices/{1}".format(graph, vertex_type)
        if vertex_id:
            endpoint += "/" + vertex_id
        return self._get(endpoint, kwargs)

    def select_edges(self, graph, src_type, src_id, edge_type="_", dst_type=None, dst_id=None, **kwargs):
        endpoint = "/graph/{0}/edges/{1}/{2}/{3}".format(graph, src_type, src_id, edge_type)
        if dst_type:
            endpoint += "/" + dst_type
            if dst_id:
                endpoint += "/" + dst_id
        return self._get(endpoint, kwargs)

    def delete_vertices(self, graph, vertex_type, vertex_id=None, **kwargs):
        endpoint = "/graph/{0}/vertices/{1}".format(graph, vertex_type)
        if vertex_id:
            endpoint += "/" + vertex_id
        return self._delete(endpoint, kwargs)

    def delete_edges(self, graph, src_type, src_id, edge_type="_", dst_type=None, dst_id=None, **kwargs):
        endpoint = "/graph/{0}/edges/{1}/{2}/{3}".format(graph, src_type, src_id, edge_type)
        if dst_type:
            endpoint += "/" + dst_type
            if dst_id:
                endpoint += "/" + dst_id
        return self._delete(endpoint, kwargs)

    def load(self, graph, lines, **kwargs):
        if lines:
            content = "\n".join(lines)
        else:
            content = None

        endpoint = "/ddl/" + graph
        return self._post(endpoint, kwargs, content)

    def update(self, graph, content):
        return self._post("/graph/" + graph, content=json.dumps(content, ensure_ascii=True))

    def query(self, graph, query_name, **kwargs):
        return self._get("/query/{0}/{1}".format(graph, query_name), kwargs)
