require 'optparse'
require 'open3'


ZIP     =  "\"7-Zip\\7z.exe\"".freeze
GPG     =  "\"GPG\\gpg2.exe\"".freeze
ERASER  =  "\"eraser\\Eraserl.exe\"".freeze

class Gpg

   attr_accessor :operation, :method, :path, :nome_file, :file, :gpg_file
   def initialize(data = {})
      @operation        = if data[:encrypt] then "encrypt" else "decrypt" end
      @method           = data[:method]
      @path             = data[:path]
      @nome_file        = path.split('\\')[-1]
      @file             = if not @nome_file.include? "." then  path.gsub(nome_file, "#{nome_file}.zip") else path end
      @gpg_file         = path.gsub(nome_file, "#{nome_file}.gpg")
   end 

   def start
      if @operation == "encrypt"
         start_encrypt
      else
         start_decrypt
      end
   end

   def start_encrypt
      puts "Avvio encrypt:"
      if directory?
         file_zip = crea_archivio
         encrypt
         elimina_file "folder", path
         elimina_file "file"  , file_zip
         sleep 1
      else
         encrypt
         elimina_file "file", path
      end
   end

   def start_decrypt
      puts "Avvio decrypt:"
      decrypt_file = decrypt
      if decrypt_file.include? ".zip"
         estrai_archivio decrypt_file
         elimina_file "file", decrypt_file
      end
      elimina_file "file", path
   end

   def estrai_archivio decrypt_file
      output = @path.gsub("\\"+File.basename(@path),"")
      Open3.popen3("#{ZIP}  x -y  \"#{decrypt_file}\" -o\"#{output}\" | FIND /V \"ing  \"") do |stdin, stdout, stderr, wait_thr|
         stdout.each_line { |line| puts line}
      end
      puts "estratto file #{decrypt_file}"
   end

   def decrypt
      decrypt_file = path.gsub(".gpg","")
      if not decrypt_file.include? "."
         decrypt_file = decrypt_file+".zip"
      end
      Open3.popen3( "#{GPG} --output \"#{decrypt_file}\" -d \"#{path}\"") do |stdin, stdout, stderr, wait_thr|
         stdout.each_line { |line| puts line }
      end
      puts "decryptato file #{path}"
      return decrypt_file
   end

   def crea_archivio
      zip = path.gsub(nome_file, "#{nome_file}.zip")
      Open3.popen3("#{ZIP}  a -tzip \"#{zip}\" \"#{path}\\\" -mx0 ") do |stdin, stdout, stderr, wait_thr|
         stderr.each_line { |line| puts line }
      end
      puts "archivio creato #{zip}"
      return zip
   end

   def encrypt
      file     = if not @nome_file.include? "." then  path.gsub(nome_file, "#{nome_file}.zip") else path end
      gpg_file = path.gsub(nome_file, "#{nome_file}.gpg")
      Open3.popen3( "#{GPG} --output \"#{gpg_file}\" -e -r \"sphynx browserino\" \"#{file}\"") do |stdin, stdout, stderr, wait_thr|
         stdout.each_line { |line| puts line }
         #pid = wait_thr.pid
         #exit_status = wait_thr.value
      end
      puts "creato file #{gpg_file} cryptato"
   end

   def elimina_file type, file_da_eliminare
      Open3.popen3( "#{ERASER}  -method #{method} -queue -resultsonerror -#{type} \"#{file_da_eliminare}\" -subfolders") do |stdin, stdout, stderr, wait_thr|
         stdout.each_line { |line| puts line }
         #pid = wait_thr.pid
         #exit_status = wait_thr.value
      end
      puts "file #{file_da_eliminare} eliminato"
   end

   def directory?
      if nome_file.include? "."
         return false
      else
         return true
      end
   end

end



options = {}

optparse = OptionParser.new do |opts|

   opts.banner = "Usage: gpgr2.exe -e -p file -m mode"
   opts.separator  "Options"


   opts.on('-d', '--decrypt', 'Start in decrypt mode') do |decrypt|
      options[:decrypt] = true
   end

   opts.on('-e', '--encrypt', 'Start in encrypt mode') do |encrypt|
      options[:encrypt] = true
   end

   opts.on('-p', '--path PATH ', 'Path della directory o del file da utilizzare') do |path|
      options[:path] = path
   end

   opts.on('-m', '--method METHOD', 'Algoritmo usato da eraser per eliminare i file') do |method|
      options[:method] = method
   end

   opts.on('-h', '--help', 'Display this screen') do
      puts opts
      exit
   end
end



begin
   optparse.parse!

   data = [:decrypt, :encrypt]
   missing = data.select{|param| options[param].nil?}
   if missing.empty?                                            
      puts "Selezionare parametro -e oppure -d non possono essere selezionato contemporaneamente"                                         
      puts optparse                                                  
      exit                                                           
   end 

   if missing.size == 2                                          
      puts "Selezionare -e oppure -d, senza questi non posso continuare"                                         
      puts optparse                                                  
      exit                                                           
   end 

   data = [:path]
   missing = data.select{|param| options[param].nil?}
   if not missing.empty?                                            
      puts "Deve essere specificato almeno un path: -p PATH"                                         
      puts optparse                                                  
      exit                                                           
   end 

   data = [:method]
   missing = data.select{|param| options[param].nil?}
   if not missing.empty?                                            
      puts "Metodo non selezionato verra usato di default Schneier(35 pass)" 
      options[:method] = "Gutmann"
   end 

   metodi = ["Gutmann" , "DoD" , "DoD_E" , "First_Last2k" , "Schneier" , "Random"  , "Library"]
   if not metodi.include? options[:method]
      puts "Metodo inserito per eraser non corretto deve selezionare uno di quest algoritmi:"
      puts "Gutmann | DoD | DoD_E | First_Last2k | Schneier | Random  | Library"
      puts optparse                                                  
      exit         
   end


rescue OptionParser::InvalidOption, OptionParser::MissingArgument      
   # Con $! stampo ERROR_INFO 
   # vedere http://blog.honeybadger.io/working-with-ruby-exceptions-outside-of-the-rescue-block/
   puts $!.to_s                                                           
   puts optparse                                                          
   exit                                                                   
end 

gpg = Gpg.new(options)

gpg.start

