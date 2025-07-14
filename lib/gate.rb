# gate.rb

lib_dir = File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)

module Gate; end

require 'Gate/Client'
require 'Gate/VERSION'
