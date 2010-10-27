#!/usr/bin/env ruby
# dustin.hoffman@breefield.com
# Grab the mp3s & cover art from each session
# Yip-yip-yip

require 'open-uri'
require 'net/http'

directories = Dir['html/*.html']
i = 0;
directories.each do |f|
  i = i + 1
  puts "#{i}/#{directories.length}"
  src = open(f).read
  info = src.split(/id="SessionDetail"/)[1]
  info = info.split(/id="SessionPlayers"/);
  music = info[1];
  info = info[0];
  band = info.match(/\<h1\>(.+?)\<\/h1\>/i)[1]
  session = info.match(/\<h2\>(.+?)\<\/h2\>/i)[1]
  date = info.match(/\<h3\>(.+?)\<\/h3\>/i)[1]
  album_cover = info.match(/src="(.+?)"/)[1]
  tracks = music.scan(/InitializeAlbumTrack\((\d+?),\s"(.+?)",\s"(.+?)",\s(\d+?)\);/i)
  
  folder = "#{band}\--#{date}".gsub!(/\s/, '_').gsub!(/(&amp;)|,|\//, '')
  album_dir = "albums/#{folder}"
  Dir.mkdir(album_dir) if folder != nil && !File::directory?(album_dir)

  tracks.each do |t|
    mp3= "http://media.daytrotter.com/audio/96/#{t[3]}.mp3"
    puts "MP3: #{mp3}"
    filename = "#{t[1]}--#{t[2]}".gsub!(/\s|\//, '_')
    filename = "#{t[1]}--#{t[2]}" if filename == nil
    if filename != nil
      mp3_file = "#{album_dir}/#{filename}.mp3"
      puts "File: #{mp3_file}"
      if !File::exists?(mp3_file)
        domain = mp3.gsub!('http://', '').split('/')[0]
        Net::HTTP.start(domain) { |http|
          resp = http.get(mp3.gsub!(domain, ''))
          open(mp3_file, "wb") { |file| file.write(resp.body) }
          puts "!!"
        }
      end
    end
  end
  
  puts "Album cover: #{album_cover}"
  album_file = "#{album_dir}/album_cover.jpg"
  if !File::exists?(album_file)
    domain = album_cover.gsub!('http://', '').split('/')[0]
    Net::HTTP.start(domain) { |http|
      resp = http.get(album_cover.gsub!(domain, ''))
      open(album_file, "wb") { |file| file.write(resp.body) }
      puts "!!"
    }
  end
end