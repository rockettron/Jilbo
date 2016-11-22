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

	def spens
		key_words = %w{
			print printf println next System Arrays String
			Scanner abstract continue for new switch
			assert default goto package synchronized
			boolean do if private this
			break double implements protected throw
			byte else import public throws
			case enum instanceof return transient
			catch extends int short try
			char final interface static void
			class finally long strictfp volatile
			const float native super while true false 
		}
		replace_content = content.clone
		key_words.each { |key| replace_content.gsub!(key, '') }
		words = replace_content.scan(/[a-zA-Z_]+[0-9]*/)
		counts = Hash.new(0)
		words.each { |word| counts[word] += 1 }
		counts.each { |k, v| counts[k] -= 1 }
		counts.delete_if { |k, v| v <= 0 }
		counts
	end

	def sum_spens
		count = spens
		sum = 0
		count.each_value { |v| sum += v }
		sum
	end

	def chepins_metric
		role = role_chepins_metric
		count = []
		role.each { |k, v| count << v.count}
		metric = count[0] + 2 * count[1] + 3 * count[2] + 0.5 * count[3]
	end

	def role_chepins_metric
		role = { 'p' => [], 'm' => [], 'c' => [], 't' => [] }
		pr = content.scan(/println\(.+\)/)
		pr.map! { |x| x.gsub!(/println\(/, '').gsub!(/\)/, '') }
		pr.map! { |x| x.split(/,\s+/) }.flatten!
		pr.each { |i| role[select_role(i)] << i }
		sc = content.scan(/.*=.*next/)
		sc.map! { |x| x.gsub(/=.*/, '').split(' ').last }
		sc.each { |i| role[select_role(i, true)] << i }
		role
	end

	def select_role(i, input = false)
		condition = content.scan(/(\bif\b|\bfor\b|\bwhile\b|\bcase\b)(.\(.*\))/)
		condition.map! { |x| x[1] }
		condition.each { |x| return 'c' if x.scan(/\b#{i}\b/).count > 0 }
		write = content.scan(/(.*)=(.*);/)
		write.each { |x| return 'm' if x[0].scan(/\b#{i}\b/).count > 0 }
		write.each { |x| return 'p' if x[1].scan(/\b#{i}\b/).count > 0 || input}
		return 't'
	end

end