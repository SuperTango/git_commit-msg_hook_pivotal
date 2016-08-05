#!/usr/bin/env rvm 2.0.0@githook do ruby
require 'plist'

$debug = true
xcode_project = 'Playlist'

def number_or_nil(string)
  Integer(string || '')
rescue ArgumentError
  nil
end

def dexit(message)
  dprint message
  Kernel.exit(0)
end

def dprint(message)
  if $debug
    print "#{message}\n"
  end
end

commit_msg_file = ARGV[0]
plist_file = "#{xcode_project}/Info.plist"

if commit_msg_file.to_s == ''
  dexit "no file defined.  Leaving\n"
end

unless File.file?(commit_msg_file)
  dexit "Commit message file #{commit_msg_file} doesn't exist.  Leaving"
end

first_line = File.open(commit_msg_file, &:readline)
unless /\[\s*(Finishes|Delivers)\s*\#\d+\]/.match(first_line)
  dexit "Commit message doens't contain Finishes or Delivers, Leaving"
end

unless File.file?(plist_file)
  dexit "Plist file #{plist_file} doesn't exist.  Leaving"
end

result = Plist::parse_xml(plist_file)
build_version = result['CFBundleShortVersionString']
build_number = number_or_nil(result['CFBundleVersion'])
unless build_number.is_a?(Numeric)
  dexit "build number: '#{build_number}' is not a number.  Leaving"
end
build_number += 1

available_in = "Available after #{build_version} (#{build_number})"

File.open(commit_msg_file, "a") do |file|
  file.puts("")
  file.puts(available_in)
end
print "Updating git commit message with:\n"
print available_in
print "\n\n"
