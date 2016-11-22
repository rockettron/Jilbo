class JavaFile < ActiveRecord::Base
	
	validate :check_content

	after_create :add_content, :create_answer

	OPERATORS = %w(+= -= *= /= %= &= |= ^= <<= >>= >>>= ++ -- ! == != >= <= > < && || instanceof ~ << >> >>> & | ^ = + - * / %)

	def prepare_code
		source = content.clone
		source.gsub!(/(["])(?:(?=(\\?))\2.)*?\1/, '')
		source.gsub!(/(\/\*([^*]|[\r\n]|(\*+([^*\/]|[\r\n])))*\*+\/)|(\/\/.*)/, '')
	end

	def find_conditions
		prepare_code.scan(/(\bif\b)|([^?\r\n]*)\?([^:]*):([^;]*)/).size
	end

	def find_loops
		prepare_code.scan(/(\bfor\b)|(\bwhile\b)/).size
	end

	def find_switch
		res = 0
		prepare_code.scan(/\bswitch\b[^{]*{[^}]*/) do |match|  
			res += match.scan(/(\bcase\b)|(\bdefault\b)/).size - 1
		end
		res
	end

	def ifelse_count_operators
		res = 0
		source = prepare_code
		OPERATORS.each do |op|
			res += source.scan(op).size
			source.gsub!(op, '')
		end
		res
		# content.scan(/;/).size
	end

	def count_deepness
		source = prepare_code
		switch_case_replacer(source)
		deepness = balance = 0
		source.each_line do |line|
			line.each_char do |chr|  
				balance += 1 if chr == '{'
				balance -= 1 if chr == '}'
				deepness = balance if deepness < balance
			end  
		end
		deepness -= 3 if compile
		deepness = 0 if deepness < 0
		deepness
	end

	private 

	def switch_case_replacer(source)
		source.gsub!(/\bswitch\b[^{]*{[^}]*/) do |match|  
			kol = "}" * (match.scan(/(\bcase\b)|(\bdefault\b)/).size.to_i - (match.include?('default') ? 2 : 1))
			match.gsub!(/\bswitch\b/, '}')
			match.gsub!(/\bcase\b/, '} else { if {')
			match.gsub!(/\bdefault\b/, '} else {')
			match + kol
		end
	end

	def add_content
		self.content = File.open(path_file).read
		self.save!
	end

	def create_answer
		self.count_operators = find_conditions + find_switch + find_loops
		self.cl = (self.count_operators.to_f / ( self.count_operators.to_f + ifelse_count_operators)).round 4
		self.deepness = count_deepness
		self.save!
	end

	def check_content
		return true unless compile
		errors_path = Rails.root.join(File.dirname(path_file), 'errors.txt').to_s
		pid = Process.spawn('javac', path_file, err: errors_path)
		Process.waitpid(pid)
		errors_file = File.open(errors_path).read
		if errors_file != ''
			errors.add(:File, "Your code is uncompilible")
		else 
			true
		end
	end

end