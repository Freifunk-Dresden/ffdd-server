# vnstat-dashboard
[![FOSSA Status](https://app.fossa.io/api/projects/git%2Bgithub.com%2Falexandermarston%2Fvnstat-dashboard.svg?type=shield)](https://app.fossa.io/projects/git%2Bgithub.com%2Falexandermarston%2Fvnstat-dashboard?ref=badge_shield)


An adaptation of vnstat-php-frontend by bjd using Bootstrap written in PHP.

## Features
* Hourly Statistics Chart (using Google Charts)
* Daily & Monthly Statistics Overview
* Top 10 Day Statistics
* Automatically populated interface selection

## System Requirements
* PHP Version 5.4

## How to run it with Docker
### Prerequisites
* Docker should be installed:
    * https://docs.docker.com/install/
* `vnstat` should be installed:
    * https://www.linuxbabe.com/monitoring/install-vnstat-debian-8ubuntu-16-04-server-monitor-network-traffic
    * https://github.com/vergoh/vnstat

### How to start it
1. `docker-compose up -d`
2. Open http://localhost/vnstat

### How to stop it
`docker-compose down`

## Licensing
Copyright (C) 2016 Alexander Marston (alexander.marston@gmail.com)

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

[![FOSSA Status](https://app.fossa.io/api/projects/git%2Bgithub.com%2Falexandermarston%2Fvnstat-dashboard.svg?type=large)](https://app.fossa.io/projects/git%2Bgithub.com%2Falexandermarston%2Fvnstat-dashboard?ref=badge_large)
