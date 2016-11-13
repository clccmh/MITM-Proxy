
require 'json'

class Config

  def self.create (config = [])
    prompt = '>'
    puts "This will help you create a config file!\n-------------------------\n"

    exploit_type = '0'
    exploits = {'1' => 'replacement', '2' => 'append'}

    while not exploits.key? exploit_type
      puts 'What kind of exloit will this be?'
      puts "1) Replacement\t2) Appending"
      print prompt
      exploit_type = $stdin.gets.chomp
      if not (exp = exploits[exploit_type])
        puts 'Not a valid option!'
      end
    end
    puts 'Enter the regex you would like to check for:'
    print prompt
    regex = $stdin.gets.chomp
    puts 'Enter the file you would like to send as a response:'
    print prompt
    file_name = $stdin.gets.chomp

    config << {regex: regex, type: exp, file: file_name}
    cont = ''
    while cont != 'y' and cont != 'n' and prompt != 'Y' and prompt != 'N'
      puts 'Do you want to add another? (y/n)'
      print prompt
      cont = $stdin.gets.chomp
      if cont == 'y' or cont == 'Y'
        return self.create config
      elsif cont == 'n' or cont == 'N'
        return config
      end
    end
  end

  def self.write (config_list)
    File.open('../config', 'w') {|file| file.write config_list.to_json}
  end

  def self.read
    JSON.parse(File.read('../config'))
  end

end

if __FILE__ == $0
  Config.write Config.create
end
