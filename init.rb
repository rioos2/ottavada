require 'colorize'
require 'dotenv'
Dotenv.load

$LOAD_PATH.unshift(File.expand_path('./lib', __dir__))

require 'version'
require 'project/rioos'
require 'project/nilavu'
require 'project/beedi'
require 'project/omnibus_gitlab'
require 'release/rioos_release'
require 'release/nilavu_release'
require 'release/beedi_release'
require 'shared_status'
require 'slack'
