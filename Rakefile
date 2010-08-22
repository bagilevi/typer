require 'rubygems'
require 'rake'
require 'echoe'

Echoe.new('typer', '0.1.0') do |p|
  p.description     = "Touch typing practice for developers/sysadmins"
  p.url             = "http://github.com/bagilevi/typer"
  p.author          = "Levente Bagi"
  p.email           = "bagilevi@gmail.com"
  p.ignore_pattern  = ["tmp/*", "script/*", "lessons/private*"]
  p.development_dependencies = []
end

Dir["#{File.dirname(__FILE__)}/tasks/*.rake"].sort.each { |ext| load ext } 