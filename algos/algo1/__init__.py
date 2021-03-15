
import sys
import pyTigerGraphBeta as tg




def gsql_install(conn,graphname):
    # GSQL Queries
    gsql = open("algos/algo1/gsql.gsql")
    content = gsql.read()
    gsql.close()
    res = ""
    try: 
        res = conn.gsql(content.format(graphname))
    except:
        print("")
    try:
        conn.gsql("""
USE GRAPH {0}
INSTALL QUERY  all_graph
INSTALL QUERY recommend_fruit
""".format(graphname))
    except:
        print("")
    return res



def start(graphname="MyGraph",server="",user="tigergraph",password="tigergraph",version="3.1.0"):
    conn = tg.TigerGraphConnection(host=server,graphname=graphname,username=user,password=password,version=version)

    try:
        gsql_install(conn,graphname)
        print("GSQL Installed")
    except Exception as e:
        print(e)
 
    
    

def info():
    return {
        'id': "algo1",
        'name': 'TigerGraph: BC Subquery',
        'tags': ['demo', 'Recommended Subquery Demo']
    }
