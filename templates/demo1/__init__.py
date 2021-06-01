
import sys
import pyTigerGraphBeta as tg




def gsql_install(conn,graphname):
    # GSQL Queries
    gsql = open("templates/demo1/gsql.gsql")
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


def schema(conn,graphname):
    #  Apply the GSQL Code  
    res = conn.gsql("""
USE GRAPH """+graphname+"""
CREATE SCHEMA_CHANGE JOB change_schem_for_recommend_fruit  FOR GRAPH """+graphname+""" {
ADD  VERTEX Customer (PRIMARY_ID id STRING)  WITH primary_id_as_attribute="TRUE";
ADD  VERTEX Fruit (PRIMARY_ID id STRING)  WITH primary_id_as_attribute="TRUE";
ADD  UNDIRECTED EDGE purchase (FROM Customer, TO Fruit, numbers INT);
}
RUN SCHEMA_CHANGE JOB change_schem_for_recommend_fruit
DROP JOB change_schem_for_recommend_fruit
""")
    return res

def data_loader(conn,graphname):
    # Loading Job , Loading data 
  
    res = conn.gsql("""
USE GRAPH {0}
BEGIN
CREATE LOADING JOB load_purchase_job FOR GRAPH {0} {{
DEFINE FILENAME f1;
LOAD f1 TO VERTEX Customer VALUES ($0) USING separator = ",";
LOAD f1 TO VERTEX Fruit VALUES ($2) USING separator = ",";
LOAD f1 TO EDGE purchase VALUES ($0, $2, $1) USING separator = ",";
}}
END
""".format(graphname))
    return res

def start(graphname="MyGraph",server="",user="tigergraph",password="tigergraph",version="3.1.0"):
    conn = tg.TigerGraphConnection(host=server,graphname=graphname,username=user,password=password,version=version)
    try:
        schema(conn,graphname)
        print("Schema Created")
    except Exception as e:
        print(e)
    try:
        gsql_install(conn,graphname)
        print("GSQL Installed")
    except Exception as e:
        print(e)
    try:
        # data_loader(conn,graphname)
        print("Loading Job Created")
    except Exception as e:
        print(e)
    try:
        conn.graphname = graphname
        secret = conn.createSecret()
        conn.apiToken = conn.getToken(secret)[0]
        # print(conn.apiToken)
        res = conn.uploadFile(filePath="templates/demo1/purchase.csv",fileTag="f1",jobName="load_purchase_job",timeout=128000)
        print("Data Loaded")
    except Exception as e:
        print(e) 
    
    

def info():
    return {
        'id': "demo1",
        'name': 'TigerGraph: Recommended Fruit Demo',
        'tags': ['demo', 'Recommended Fruit Demo']
    }
