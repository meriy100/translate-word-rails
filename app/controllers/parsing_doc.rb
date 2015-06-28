
def parsing text
  word_list =  text.scan(/\w+/)
  word_list
end
def test_m a

end

def parsing_doc file_name
  word_list = []
  begin
    File.foreach(file_name) { |line|
      word_list.push line.scan(/\w+/)
    }
    word_list
  rescue Exception => e
    puts e  
  end
  
end

if ARGV.length > 0
  parsing_doc ARGV[0]
else
  puts "prease file name"
end

