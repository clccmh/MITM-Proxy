
require 'json'

class Config

  def self.create
    prompt = '>'
    puts 'This will help you create a config file!\n------------------------\n'
    puts 'Enter the regex you would like to check for:'
    print prompt
    regex = $stdin.gets.chomp
    puts 'Enter the file you would like to send as a response:'
    print prompt
    file_name = $stdin.gets.chomp
    h = {regex: regex, file: file_name}
    return h
  end

  def self.write hash
  end

  def self.read
  end

end


puts Config.create
