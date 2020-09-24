Project FT_Services @42SP

This is a System Administration and Networking project.
The project consists of setting up an infrastructure of different services, all in diffents containers.
All the services are balanced using the load balancer metallb.
The Services are:
  - Nginx Server, this container can also be acessed by SSH
  - Wordpress blog with mySQL database and phpMyAdmin to manage the database.
  - FTPS server
  - A grafana server with InfluxDB database.
