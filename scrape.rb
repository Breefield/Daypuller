#!/usr/bin/env ruby
# dustin.hoffman@breefield.com
# Grab all session pages (from alphabet.html)
# Yip-yip-yip

file = STDIN.read
links = file.scan(/href="\/dt\/(.+?)">/);
links.each do |l|
    system 'wget http://www.daytrotter.com/dt/' + l[0]
end
