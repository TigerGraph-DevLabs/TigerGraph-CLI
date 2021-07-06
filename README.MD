# TigerGraph CLI project layout

At a high level, these areas make up the `tgcli` project:
- [`conf`]  - configration Manger
- [`cloud`] - Cloud Manager
- [`box`] - TigerGraph Instance Manager

## Installation 

### Mac OS:
To install TigerGraph Cli on Mac OS
```
brew tap TigerGraph-DevLabs/tg
brew install tgcli
```

### Linux:
To install TigerGraph Cli on Linux 

```SHELL
user@box $ wget https://tigertool.tigergraph.com/dl/linux/tgcli
user@box $ sudo mv tgcli /usr/bin/
user@box $ sudo chmod +x /usr/bin/tgcli
```
Or, using snapcraft 
```
snap install tgcli
```
### Windows:

```
https://tigertool.tigergraph.com/dl/windows/tgcli.exe
```

## Command-line help text

Running `tg <module> -h` displays help text for a topic. 

Example : `tg cloud -h` 

In this case, we are getting the cloud's command help. 

```
usage: tg cloud [-h] {login,start,stop,terminate,archive,list,create} ...

positional arguments:
  {login,start,stop,terminate,archive,list,create}
    login               Login to tgcloud.io
    start               Start a tgcloud instance
    stop                Stop a tgcloud instance
    terminate           Terminate a tgcloud instance
    archive             Archive a tgcloud instance
    list                List all tgcloud instance
    create              Create a tgcloud instance

optional arguments:
  -h, --help            show this help message and exit
```

# How TigerGraph CLI works

## Configuration Manager


`tg conf -h` Use this command to manage TigerGraph Cloud and Instances configuration.

```
usage: tg conf [-h] {tgcloud,add,delete,list} ...

positional arguments:
  {tgcloud,add,delete,list}
    tgcloud             tgcloud user Configuration
    add                 add Configuration
    delete              delete Configuration
    list                list Configuration

optional arguments:
  -h, --help            show this help message and exit

```

### tgcloud account 

`tg conf tgcloud -h` manages the tgcloud account credentials ( used by `tg cloud login`)

| argument | description | accepted values | default |
| -------- | ----------- | --------------- | ------- |
| -email | The email address associated with your TigerGraph Cloud account | string containing user email address | "" |
| -password | The password associated with your TigerGraph Cloud account | string containing user password | "" |

Example : 

```
tg conf tgcloud -email <mail@domain.com> -password <password>
```

### Machines ( refered to as box ) Configuration list

`tg conf list -h` lists all the configuration 
 
 Example:
 ```
=======    tgCloud Account  ======
username: myaccount@gmail.com
password: mypassword
======= TigerGraph Instances ======
Machine: alias = defaultConf  (default)  
 host: http://localhost
 user: tigergraph
 password: tigergraph
 GSQL Port: 14240
 REST Port: 9000
Machine: alias = Machine2
 host: https://machine.i.tgcloud.io
 user: tigergraph
 password: tigergraph
 GSQL Port: 14240
 REST Port: 9000
 ```
 
### Add a Machine/Box 

`tg conf add -h` add a machine to the configuration store

```
usage: tg conf add [-h] [-alias ALIAS] [-user USER] [-password PASSWORD] [-host [HOST]] [-gsPort [GSPORT]]
                   [-restPort [RESTPORT]] [-default [{y,n}]]

optional arguments:
  -h, --help            show this help message and exit
  -alias ALIAS          the name used for referring to the tigergraph Box
  -user USER            tigergraph user ( default : tigergraph )
  -password PASSWORD    tigergraph password ( default : tigergraph )
  -host [HOST]          tigergraph host ( default : http://127.0.0.1 )
  -gsPort [GSPORT]      GSQL Port ( default : 14240 )
  -restPort [RESTPORT]  Rest++ Port ( default : 9000 )
  -default [{y,n}]      Set default alias conf (y/n) ( default : n )

```


| argument | description | accepted values | default |
| -------- | ----------- | --------------- | ------- |
| -alias | The name given to the box for using it later | string  | "" |
| -user | tigergraph user by defaulttigergraph  | string  | tigergraph |
| -password | tigergraph user's password  | string  | tigergraph |
| -host | host value for tigergraph  | string  | http://127.0.0.1 |
| -gsPort | GSQL Port for tigergraph instance | string  | 14240 |
| -restPort | RestPP Port for tigergraph instance | string  | 9000 |
| -default | y/n parameter to set this configuration as default box | string  | n |


### Delete a Machine/Box From Configuration

`tg conf delete -h` add a machine to the configuration store

```
usage: tg conf delete [-h] [-alias ALIAS]

optional arguments:
  -h, --help    show this help message and exit
  -alias ALIAS  the name used for referring to the tigergraph Box


```


| argument | description | accepted values | default |
| -------- | ----------- | --------------- | ------- |
| -alias | The machine's alias to delete | string  | "" |


## Cloud Functionalities


`tg cloud -h` Use this command to manage TigerGraph Cloud instances state.

```
usage: tg cloud [-h] {login,start,stop,terminate,archive,list,create} ...

positional arguments:
  {login,start,stop,terminate,archive,list,create}
    login               Login to tgcloud.io
    start               Start a tgcloud instance
    stop                Stop a tgcloud instance
    terminate           Terminate a tgcloud instance
    archive             Archive a tgcloud instance
    list                List all tgcloud instance
    create              Create a tgcloud instance

optional arguments:
  -h, --help            show this help message and exit

```

### Cloud login


### List tgcloud instances 

To list tgcloud instances use:

```
tg cloud list 
```

```
usage: tg cloud list [-h] [-activeonly [{y,n}]] [-o [{stdout,json}]]

optional arguments:
  -h, --help           show this help message and exit
  -activeonly [{y,n}]  Hide terminated Boxes
  -o [{stdout,json}]   Output for the tigergraph-cli

```

| argument | description | accepted values | default |
| -------- | ----------- | --------------- | ------- |
| -activeonly | list only active instances ( no terminated ) | string  | "y" |
| -o | output mode stdout or json | string  | "stdout" |



### Start/Stop/Terminate/Archive a tgcloud Machine 

To change the state of a machine on tgcloud use:

```
tg cloud start -id <machine-id-from-list>
tg cloud stop -id <machine-id-from-list>
tg cloud terminate -id <machine-id-from-list>
tg cloud archive -id <machine-id-from-list>
```

## Box Functionalities


`tg box -h` Use this command to manage TigerGraph Instances.

```
usage: tg box [-h] {demos,algos,gsql,udf,udt,services,backup,import,starter-kit} ...

positional arguments:
  {demos,algos,gsql,udf,udt,services,backup,import,starter-kit}
    demos               Loads demos to TigerGraph box.
    algos               Loads algos to TigerGraph box.
    gsql                Execute a gsql terminal.
    udf                 get/update UDF for TigerGraph box.
    udt                 get/update UDT for TigerGraph box.
    services            Start/Stop GPE/GSE/RESTPP Services in TigerGraph box.
    backup              Backup a TigerGraph box.
    import              Import a TigerGraph box from a ZIP file.
    starter-kit         Load a starter kit to TigerGraph box

optional arguments:
  -h, --help            show this help message and exit

```
### gsql terminal 

This function launches a gsql terminal ( Pure Python )

```SHELL
user@box $ tg box gsql -alias <your_box_alias>
Welcome to tigergraph
GSQL > 
```

```
usage: tg box gsql [-h] [-alias ALIAS] [-user USER] [-password PASSWORD] [-host [HOST]] [-gsPort [GSPORT]]

optional arguments:
  -h, --help          show this help message and exit
  -alias ALIAS        tigergraph Box to use
  -user USER          tigergraph user ( default : tigergraph )
  -password PASSWORD  tigergraph password ( default : tigergraph )
  -host [HOST]        tigergraph host ( default : http://127.0.0.1)
  -gsPort [GSPORT]    GSQL Port ( default : 14240 )

```

### UDF Download/Upload 

Download/Upload UDF 

```SHELL
user@box $ tg box udf -alias <your_box_alias> -ops download
user@box $ tg box udf -alias <your_box_alias> -ops upload
```
Full usage:
```
usage: tg box udf [-h] [-alias ALIAS] [-user USER] [-password PASSWORD] [-host [HOST]] [-gsPort [GSPORT]]
                  [-ops {download,upload}]

optional arguments:
  -h, --help            show this help message and exit
  -alias ALIAS          tigergraph Box to use
  -user USER            tigergraph user ( default : tigergraph )
  -password PASSWORD    tigergraph password ( default : tigergraph )
  -host [HOST]          tigergraph host ( default : http://127.0.0.1)
  -gsPort [GSPORT]      GSQL Port ( default : 14240 )
  -ops {download,upload}
                        upload/download UDF ( default : download )

```

### UDT Download/Upload 

Download/Upload UDT

```SHELL
user@box $ tg box udt -alias <your_box_alias> -ops download
user@box $ tg box udt -alias <your_box_alias> -ops upload
```
Full usage: 

```
usage: tg box udt [-h] [-alias ALIAS] [-user USER] [-password PASSWORD] [-host [HOST]] [-gsPort [GSPORT]]
                  [-ops {download,upload}]

optional arguments:
  -h, --help            show this help message and exit
  -alias ALIAS          tigergraph Box to use
  -user USER            tigergraph user ( default : tigergraph )
  -password PASSWORD    tigergraph password ( default : tigergraph )
  -host [HOST]          tigergraph host ( default : http://127.0.0.1 )
  -gsPort [GSPORT]      GSQL Port ( default : 14240 )
  -ops {download,upload}
                        upload/download UDT ( default : download )
```

### Manage GPE/GSE/RESTPP Services

start/stop GPE/GSE/RESTPP

```SHELL
user@box $ tg box services -alias <your_box_alias> -ops start
user@box $ tg box services -alias <your_box_alias> -ops stop
```

Full usage:

```
usage: tg box services [-h] [-user USER] [-password PASSWORD] [-host [HOST]] [-gsPort [GSPORT]] [-ops {start,stop}]

optional arguments:
  -h, --help          show this help message and exit
  -user USER          tigergraph user ( default : tigergraph )
  -password PASSWORD  tigergraph password ( default : tigergraph )
  -host [HOST]        tigergraph host ( default : http://127.0.0.1 )
  -gsPort [GSPORT]    GSQL Port ( default : 14240 )
  -ops {start,stop}   start/stop GPE/GSE/RESTPP ( default : start )
```


### backup a TigerGraph Instance ( Full , Data , Schema )

Backup a tigergraph instance 

```SHELL
user@box $ tg box backup -alias <your_box_alias> 
```

Full usage:
```
usage: tg box backup [-h] [-alias ALIAS] [-user USER] [-password PASSWORD] [-host [HOST]] [-gsPort [GSPORT]]
                     [-restPort [RESTPORT]] [-t {ALL,SCHEMA,DATA}]

optional arguments:
  -h, --help            show this help message and exit
  -alias ALIAS          tigergraph Box to use
  -user USER            tigergraph user ( default : tigergraph )
  -password PASSWORD    tigergraph password ( default : tigergraph )
  -host [HOST]          tigergraph host ( default : http://127.0.0.1 )
  -gsPort [GSPORT]      GSQL Port ( default : 14240 )
  -restPort [RESTPORT]  Rest Port ( default : 9000 )
  -t {ALL,SCHEMA,DATA}  backup Mode ( default : ALL )
```

### Demos , Algos , Starter-Kit , Import ( Pending - Work in progress )

:construction: these functionalities are pending release (work in progress).
