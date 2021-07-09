
Getting Started with TigerGraph CLI
===================================

TigerGraph CLI consists of three major features:


* [\ ``conf``\ ]  - Configration Manger. Commands that start with ``tg conf`` allow you to manage configurations used by ``tgcli``\ , including user credentials for TigerGraph Cloud and configurations for instances managed by the Box Manager. 
* [\ ``cloud``\ ] - Cloud Manager. Commands that start with ``tg cloud`` allow you to manage the state of your TigerGraph Cloud solutions. Through ``tgcli``\ , you can create, view, stop and terminate your TigerGraph instances without going through the TigerGraph Cloud portal. 
* [\ ``box``\ ] - Box Manager. Commands that start with ``tg box`` allow you to perform sophisticated operations on the instances added to your TigerGraph CLI configurations. Such an instances is called a TigerGraph *box*. Through the box manager, you can download/upload user-defined functions (UDF), import/export solutions, start/stop services and even start a GSQL shell and run commands on your box. 

Installation
------------

Mac OS:
^^^^^^^

To install TigerGraph Cli on Mac OS

.. code-block::

   brew tap TigerGraph-DevLabs/tg
   brew install tgcli

Linux:
^^^^^^

To install TigerGraph Cli on Linux 

.. code-block:: SHELL

   user@box $ wget https://tigertool.tigergraph.com/dl/linux/tgcli
   user@box $ sudo mv tgcli /usr/bin/
   user@box $ sudo chmod +x /usr/bin/tgcli

Windows:
^^^^^^^^

.. code-block::

   https://tigertool.tigergraph.com/dl/windows/tgcli.exe

Command-line help text
----------------------

Running ``tg <module> -h`` displays help text for a topic. 

Example : ``tg cloud -h`` 

In this case, we are getting Cloud Manager's command help. 

.. code-block::

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

How TigerGraph CLI works
========================

Configuration Manager
---------------------

Commands that start with ``tg conf`` manage the configurations used by ``tg-cli``\ , which include the user's TigerGraph Cloud credentials and configurations for the user's TigerGraph boxes. 

.. code-block::

   usage: tg conf [-h] {tgcloud,add,delete,list} ...

   positional arguments:
     {tgcloud,add,delete,list}
       tgcloud             TigerGraph Cloud user configuration
       add                 add configuration
       delete              delete configuration
       list                list configurations

   optional arguments:
     -h, --help            show this help message and exit

Set up TigerGraph Cloud credentials
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

``tg conf tgcloud -h`` manages the user's TigerGraph Cloud account credentials ( used by ``tg cloud login``\ )

.. list-table::
   :header-rows: 1

   * - Argument
     - Description
     - Accepted values
     - Default
   * - -email
     - The email address associated with your TigerGraph Cloud account
     - String containing user email address
     - ""
   * - -password
     - The password associated with your TigerGraph Cloud account
     - String containing user password
     - ""


Example : 

.. code-block::

   tg conf tgcloud -email <mail@domain.com> -password <password>

List configurations
^^^^^^^^^^^^^^^^^^^

``tg conf list`` lists all the configuration 

 Example:

.. code-block::

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

Add an instance
^^^^^^^^^^^^^^^

``tg conf add`` adds a TigerGraph instance (box) to the configuration store

.. code-block::

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

.. list-table::
   :header-rows: 1

   * - Argument
     - Description
     - Accepted values
     - Default
   * - -alias
     - The name given to the box for using it later
     - string
     - ""
   * - -user
     - tigergraph user by defaulttigergraph
     - string
     - tigergraph
   * - -password
     - tigergraph user's password
     - string
     - tigergraph
   * - -host
     - host value for tigergraph
     - string
     - http://127.0.0.1
   * - -gsPort
     - GSQL Port for tigergraph instance
     - string
     - 14240
   * - -restPort
     - RestPP Port for tigergraph instance
     - string
     - 9000
   * - -default
     - y/n parameter to set this configuration as default box
     - string
     - n


Delete a Machine/Box From Configuration
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

``tg conf delete`` deletes a box from the configuration store

.. code-block::

   usage: tg conf delete [-h] [-alias ALIAS]

   optional arguments:
     -h, --help    show this help message and exit
     -alias ALIAS  the name used for referring to the tigergraph Box

.. list-table::
   :header-rows: 1

   * - Argument
     - description
     - Accepted values
     - Default
   * - -alias
     - The machine's alias to delete
     - string
     - ""


Cloud Manager
-------------

``tg cloud -h`` Commands that start with ``tg cloud`` allow you to log in to your TigerGraph Cloud account and manage your TigerGraph Cloud instances.

.. code-block::

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

Cloud login
^^^^^^^^^^^

To log in to your TigerGraph Cloud account, run the following command:

.. code-block:: SHELL

   $ tg cloud login -email <your_email> -password <your_password>

If you have already set up your TigerGraph credential through ``tg conf tgcloud``\ , then just run:

.. code-block::

   $ tg cloud login

``tg-cli`` will use the credentials you set up to log in to TigerGraph Cloud.

List tgcloud instances
^^^^^^^^^^^^^^^^^^^^^^

Once you are logged in, to list tgcloud instances use:

.. code-block::

   tg cloud list

.. code-block::

   usage: tg cloud list [-h] [-activeonly [{y,n}]] [-o [{stdout,json}]]

   optional arguments:
     -h, --help           show this help message and exit
     -activeonly [{y,n}]  Hide terminated Boxes
     -o [{stdout,json}]   Output for the tigergraph-cli

.. list-table::
   :header-rows: 1

   * - argument
     - description
     - accepted values
     - default
   * - -activeonly
     - list only active instances ( no terminated )
     - string
     - "y"
   * - -o
     - output mode stdout or json
     - string
     - "stdout"


Start/Stop/Terminate/Archive a TigerGraph Cloud solution
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

To change the state of a machine on TigerGraph Cloud use:

.. code-block::

   tg cloud start -id <machine-id-from-list>
   tg cloud stop -id <machine-id-from-list>
   tg cloud terminate -id <machine-id-from-list>
   tg cloud archive -id <machine-id-from-list>

Box Manager
-----------

``tg box -h`` Commands that start with ``tg box`` allow you to perform sophisticated operations on your TigerGraph instances (boxes). 

.. code-block::

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

Launch a GSQL terminal
^^^^^^^^^^^^^^^^^^^^^^

This function launches a GSQL terminal ( Pure Python )

.. code-block:: SHELL

   user@box $ tg box gsql -alias <your_box_alias>
   Welcome to tigergraph
   GSQL >

.. code-block::

   usage: tg box gsql [-h] [-alias ALIAS] [-user USER] [-password PASSWORD] [-host [HOST]] [-gsPort [GSPORT]]

   optional arguments:
     -h, --help          show this help message and exit
     -alias ALIAS        tigergraph Box to use
     -user USER          tigergraph user ( default : tigergraph )
     -password PASSWORD  tigergraph password ( default : tigergraph )
     -host [HOST]        tigergraph host ( default : http://127.0.0.1)
     -gsPort [GSPORT]    GSQL Port ( default : 14240 )

UDF Download/Upload
^^^^^^^^^^^^^^^^^^^

Download/Upload UDF 

.. code-block:: SHELL

   user@box $ tg box udf -alias <your_box_alias> -ops download
   user@box $ tg box udf -alias <your_box_alias> -ops upload

Full usage:

.. code-block::

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

UDT Download/Upload
^^^^^^^^^^^^^^^^^^^

Download/Upload UDT

.. code-block:: SHELL

   user@box $ tg box udt -alias <your_box_alias> -ops download
   user@box $ tg box udt -alias <your_box_alias> -ops upload

Full usage: 

.. code-block::

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

Manage GPE/GSE/RESTPP Services
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

start/stop GPE/GSE/RESTPP

.. code-block:: SHELL

   user@box $ tg box services -alias <your_box_alias> -ops start
   user@box $ tg box services -alias <your_box_alias> -ops stop

Full usage:

.. code-block::

   usage: tg box services [-h] [-user USER] [-password PASSWORD] [-host [HOST]] [-gsPort [GSPORT]] [-ops {start,stop}]

   optional arguments:
     -h, --help          show this help message and exit
     -user USER          tigergraph user ( default : tigergraph )
     -password PASSWORD  tigergraph password ( default : tigergraph )
     -host [HOST]        tigergraph host ( default : http://127.0.0.1 )
     -gsPort [GSPORT]    GSQL Port ( default : 14240 )
     -ops {start,stop}   start/stop GPE/GSE/RESTPP ( default : start )

backup a TigerGraph Instance ( Full , Data , Schema )
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Backup a tigergraph instance 

.. code-block:: SHELL

   user@box $ tg box backup -alias <your_box_alias>

Full usage:

.. code-block::

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

Demos , Algos , Starter-Kit , Restore (Import) ( Pending - Work in progress )
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

:construction: these functionalities are pending release (work in progress).
