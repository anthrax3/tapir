# TAPIR - The API for Reconnaissance

## About

Tapir is a framework designed to make it easy to discover interesting data about organizations, users, computers, and networks on the web, using common (and not so common) OSINT techniques.

The core of Tapir is the object model (implemented and database-backed with Active Record) and the tasks (implemented as small, structured ruby scripts like metasploit modules) to modify and create entities. 

Tapir entities are real-world objects that we want to track.

Tapir tasks are the code that operate on the entities to create new entities or modify existing entities. Tasks are simple to create, have just enough structure, and harness the full power of ruby to extend the framework in useful ways. Have a look at the existing tasks in the lib/tapir/tasks directory. 

Tapir keeps track of entities generated by each task for you. For example, if you add a host entity, and run a 'geolocate_host' task, you'll find that the physical address generated by the task is now a child of that host (and the host is now a parent of that physical address). You can view, modify, and programmatically query and inspect these relationships.

## News

* 06/18/2012 - Cleaned up Web UI and background tasks! Renamed to Tapir!
* 02/25/2012 - The EAR Project has a stubbed out web UI, and is on its way to v1.0!
* 12/16/2011 - The EAR Project has been updated to Rails 3!
* 06/01/2011 - (or some time around here) Initial version of EAR spawned for #AHA.

## Prerequisites and Initial Setup:

Tapir is currently tested and working on:

* OS X 10.5.x+
* Ubuntu Linux 9.10+

The following prerequisites are required for execution: 

### Prerequisites (Debian / Ubuntu) 

All prerequisites can be installed via apt:

	sudo apt-get install nmap qt4-qmake libnokogiri-ruby1.8 libxslt-dev libxml2-dev libqt4-dev libpcap-dev libpq-dev libsqlite3-dev 

### Prerequisites (OSX using Brew)

Brew can be used to install prerequisites on OSX:

	brew install qt
	brew install nmap

### Initial Setup (platform independent): 

Execute the bundle installer: 

	$ gem install bundle 
	$ bundle install      # from within the ear application root
  $ rake setup:initial  # from within the ear application root

## Getting Started with Tapir

### Using the Web Interface (Start Here!)

To start the server, in the root of the Tapir directory, run: 

  $ rails s
   
Now browse to http://[server_name]:3000, and you're in the jungle!

### Using the Scriptable Console (Advanced)
Once you have a database, simply run `$ util/console.rb` - this will give you access to a pry shell from which you can create entitys and run tasks. 

Creating a host entity & running tasks: 

    ear> h = Host.create(:ip_address => "8.8.8.8")
    ear> h.run_task("dns_reverse_lookup")
    ear> h.run_task("geolocate_host")
    ear> h.children

## Advanced

### Configuration files

The config/api_keys.yml file configures API key required for API operations and where they may be located. 

The config/database.yml file can also be configured with the following databases:

	* SQLite3 - For light / small scale test database operations and development. **Used by default
	* MySQL / Postgres - For heavier / long term operations and development.
    
The latest geolitecity data can be pulled by running: 

  $ data/geolitecity/get_latest.sh 

### Additional Utilities

Tapir ships with a few utilities which you may find of use:

 - util/sniff.rb: This utility sets up a packet sniffer on the local machine, which automatically creates Host entitys within the Tapir's database. These host entitys are then available to you within Tapir. This is a fun & easy way to find out more information about the systems your host is communicating with.

 - util/load_*.rb: Use these utilities to load a list of hosts into the system. Optionally, you can run modules against the entitys you import. It's likely you'll want to take a look at the code before running them. 

Check out the utils/ directory for more useful utilities.

### Known Issues

Installation of therubyracer gem might fail due to an invalid GEM specification file, refer to the following link for details: 

	https://github.com/cowboyd/therubyracer/issues/140#issuecomment-4707363
