class JavaFile < ActiveRecord::Base
	
	validate :check_content

	after_create :add_content, :__create

	OPERATORS = %w(+= -= *= /= %= &= |= ^= >>>= <<= >>= ++ -- != == ! >= <= >>> << >> > < && || instanceof ~ & | ^ = + - * / %)

	def __create
		if chep 
			create_chep
		else 
			create_answer
		end
	end

	def prepare_code
		
		src = content.clone
		src.gsub!(/(["])(?:(?=(\\?))\2.)*?\1/, '')
		src.gsub!(/(\/\*([^*]|[\r\n]|(\*+([^*\/]|[\r\n])))*\*+\/)|(\/\/.*)/, '')
		src
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
		src = prepare_code
		OPERATORS.each do |op|
			res += src.scan(op).size
			src.gsub!(op, '')
		end
		res
		# content.scan(/;/).size
	end

	def count_deepness
		src = prepare_code
		switch_case_replacer(src)
		deepness = balance = 0
		src.each_line do |line|
			line.each_char do |chr|  
				balance += 1 if chr == '{'
				balance -= 1 if chr == '}'
				deepness = balance if deepness < balance
			end  
		end
		deepness -= 3 if compile
		deepness -= 1 unless compile
		deepness = 0 if deepness < 0
		deepness
	end

	private 

	def switch_case_replacer(src)
		src.gsub!(/\bswitch\b[^{]*{[^}]*/) do |match|  
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

	def create_chep
		self.spens = sum_spens
		self.role = role_chepins_metric.to_json.to_s
		self.chep_metric = chepins_metric
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
			false
		else 
			true
		end
	end

	def spens_hash
		key_words = %w{
			println printf print next System Arrays String
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
		replace_content = prepare_code
		key_words.each { |key| replace_content.gsub!(key, '') }
		words = replace_content.scan(/[a-zA-Z_]+[0-9]*/)
		counts = Hash.new(0)
		words.each { |word| counts[word] += 1 }
		counts.each { |k, v| counts[k] -= 1 }
		counts.delete_if { |k, v| v <= 0 }
		counts
	end

	def sum_spens
		count = spens_hash
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
		new_content = prepare_code
		role = { 'p' => [], 'm' => [], 'c' => [], 't' => [] }
		pr = new_content.scan(/println\(.+\)/)
		pr.map! { |x| x.gsub!(/println\(/, '').gsub!(/\)/, '') }
		pr.map! { |x| x.split(/,\s+/) }.flatten!
		pr.each { |i| role[select_role(i)] << i }
		sc = new_content.scan(/.*=.*next/)
		sc.map! { |x| x.gsub(/=.*/, '').split(' ').last }
		sc.each { |i| role[select_role(i, true)] << i }
		role
	end

	def select_role(i, input = false)
		new_content = prepare_code
		condition = new_content.scan(/(\bif\b|\bfor\b|\bwhile\b|\bswitch\b)(.\(.*\))/)
		condition.map! { |x| x[1] }
		condition.each { |x| return 'c' if x.scan(/\b#{i}\b/).count > 0 }
		write = new_content.scan(/(.*)=(.*);/)
		write.each { |x| return 'm' if (!x[1].include?('next') && x[0].scan(/\b#{i}\b/).count > 0)}
		write.each { |x| return 'p' if x[1].scan(/\b#{i}\b/).count > 0 || input}
		return 't'
	end

end