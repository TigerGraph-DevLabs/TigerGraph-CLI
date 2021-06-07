# TigerGraph CLI

This tool allows you to connect to your TigerGraph instance via the command line and execute commands to manage your TigerGraph Cloud solutions.

## Requirements

- Python >= 3.6
- Google Chrome


## How to setup

- Install all necessary python packages with `pip install -r requirements.txt`

## How to use

There are two different methods of operation with which you can use the TigerGraph CLI, as a CLI, and as an API interface. Both of these methods offer the same features.

### Logging in

The first thing you will need to do is authenticate with your TigerGraph instance. 

- run `python3 tigergraph-cli login`
- enter your `tgcloud username` and `tgcloud password` where prompted
- a browser window will open and begin running through the login process for TGCloud
    - please allow this process to complete without interrupting it
    - you will NOT be able to use a Google or LikedIn for authentication with this process
- `Login Successful` will appear in the command line once the login process has completed

## Using the CLI

<hr>

### Login

Use this command to log into TigerGraph Cloud and authenticate future actions this session.

`tigergraph-cli login [-email=TGCLOUD_EMAIL] [-password=TGCLOUD_PASSWORD] [-save=SAVE_CREDS] [-o=OUTPUT_FORMAT]`

| argument | description | accepted values | default |
| -------- | ----------- | --------------- | ------- |
| -email | The email address associated with your TigerGraph Cloud account | string containing user email address | "" |
| -password | The password associated with your TigerGraph Cloud account | string containing user password | "" |
| -save | Whether or not to save your credentials | "y" or "n" | "n" |
| -o | results output format | "stdout", "json" | "stdout" |

<hr>

### Ops

Execute operations for maintaining your TigerGraph Cloud instances.

`tigergraph-cli ops -action=ACTION_TYPE -id=MACHINE_ID`

| argument | description | accepted values | default |
| -------- | ----------- | --------------- | ------- |
| -action | The action to be executed | "Start", "Stop", "Terminate", "Archive" | none |
| -id | The name of the machine to execute the action on | string containing machine id | none |

<br>

| action | description |
| ------ | ----------- |
| Start | Start a stopped machine |
| Stop | Stop a running machine |
| Terminate | Perminantly stop a machine |
| Archive | Hide a terminated machine from the view |

<hr>

### List

This command will list all solutions under your account

`tigergraph-cli list [-activeonly=SHOW_INACTIVE] [-o=OUTPUT_FORMAT]`

| argument | description | accepted values | default |
| -------- | ----------- | --------------- | ------- |
| -activeonly | Choose to show only active solutions | "y" or "n" | "y" |
| -o | results output format | "stdout", "json" | "stdout |

<hr>

### Algos

List algorithms available to install on solutions

`tigergraph-cli algos`

Upon selecting an algorithm from this list, you will be prompted for the following information

| field | description | accepted values | default |
| ----- | ----------- | --------------- | ------- |
| server url | URL of the TigerGraph Cloud account | url for your account ending in '.tgcloud.io' | none |
| graph name | Name of the graph to install the algorithm on | the name of any graph in your chosen solution | "MyGraph" |
| user | username for authentication | username used for access GraphStudio | "tigergraph" |
| password | password for chosen user | password for slected user | none |
| version | TigerGraph version of the selected solution | "3.0.6" or "3.1.0" | "3.0.6" |

<hr>

### Demos

Install a demo on one of your exisitng solutions

`tigergraph-cli demos`

Upon selecting a demo from this list, you will be prompted for the following information

| field | description | accepted values | default |
| ----- | ----------- | --------------- | ------- |
| server url | URL of the TigerGraph Cloud account | url for your account ending in '.tgcloud.io' | none |
| graph name | Name of the graph to install the demo on | the name of any graph in your chosen solution | "MyGraph" |
| user | username for authentication | username used for access GraphStudio | "tigergraph" |
| password | password for chose user | password for slected user | none |
| version | TigerGraph version of the selected solution | "3.0.6" or "3.1.0" | "3.0.6" |

<hr>

### api

Enable API endpoints for interacting with the CLI

`tigergraph-cli api`

Upon running this command, the API server will start and host the CLI API on `localhost:5000`. The following endpoints are exposed for interfacing.

| endpoint | type | description | params |
| -------- | ---- | ----------- | ------ |
| /login | POST | login to your TigerGraph Cloud account | <ul><li>`username`: TigerGraph Cloud username</li><li>`password`: TigerGraph Cloud password</li></ul> |
| /loginbox | POST | login to your TigerGraph Cloud account | <ul><li>`host`: Host address ("".tgcloud.io)</li><li>`username`: TigerGraph Cloud username</li><li>`password`: TigerGraph Cloud password</li></ul> |
| /ops | POST | execute an operation on your TigerGraph Cloud solution | <ul><li>`token`: authentication token</li><li>`action`: action to exeute on the solution (see actions above)</li><li>`id_machine`: id of the solution to execute the action on</li></ul> |
| /list | POST | list solutions on your account | <ul><li>`token`: authentication token</li></ul> |
| /loadtobox | POST | load an algorithm into one of your existing solutions | <ul><li>`host`: Host address ("".tgcloud.io)</li><li>`username`: TigerGraph Cloud username</li><li>`password`: TigerGraph Cloud password</li><li>`graph`: name of graph to load algorithm into</li><li>`algo`: name of algorithm to load</li></ul> |