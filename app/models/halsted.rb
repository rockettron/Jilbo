class Halsted < ActiveRecord::Base

	OPERATORS = %w(+= -= *= /= %= &= |= ^= >>>= <<= >>= ++ -- != == ! >= <= >>> << >> > < && || instanceof return ~ & | ^ = + - * / %)

	validate :check_content

	after_create :add_content, :init

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

	def add_content
		self.content = File.open(path_file).read
		self.save!
	end

	def prepare_code(scip = true)
		src = content.clone
		src.gsub!(/(\/\*([^*]|[\r\n]|(\*+([^*\/]|[\r\n])))*\*+\/)|(\/\/.*)/, '')
		src.gsub!(/\b(int|boolean|double|float|char|long|short)\b.+?;/, '')
		src.gsub!(/\b(void|int|boolean|double|float|char|long|short)\b.+/, '')
		src.gsub!(/(["])(?:(?=(\\?))\2.)*?\1/, '') if scip
		src
	end

	def find_conditions_loops_switch
		code = prepare_code
		hash = Hash.new(0)
		code.scan(/(\bif\b)|([^?\r\n]*)\?([^:]*):([^;]*)/).flatten.compact.each { |match| hash[match.to_s] += 1 }
		code.scan(/\b(for)|(while)|(switch)\b/).flatten.compact.each { |match| hash[match.to_s] += 1 }
		code.scan(/\b(break)|(continue)\b/).flatten.compact.each { |match| hash[match.to_s] += 1 }
		hash
	end	

	def find_count_govno
		code = prepare_code
		hash = Hash.new(0)
		code.scan(/,|\.|:|;/).flatten.compact.each { |match| hash[match.to_s] += 1 }
		code.scan(/\w+\(.*\)/).flatten.compact.each { |match| match.gsub!(/\(.*\)/, '(..)'); hash[match.to_s] += 1 }
		code.gsub!(/\w+\(.*\)/, '')
		for_if_while_swith_count = code.scan(/\b(for)|(while)|(switch)|(if)\b/).flatten.compact.count
		brackets = code.scan(/\(/).count - for_if_while_swith_count
		hash["(..)"] += brackets if brackets > 0
		code.scan(/\]/).each { |match| hash["[..]"] += 1 }
		code.scan(/\}/).each { |match| hash["{..}"] += 1 }
		hash
	end

	def find_count_ebutchee_govno
		code = prepare_code
		hash = Hash.new 0
		OPERATORS.each do |op|
			code.scan(op).each { |match| hash[match.to_s] += 1 }
			code.gsub!(op, '')
		end
		hash
	end

	def find_variables
		keywords = %w{ 
			byte short int long char float double boolean
			if else switch case default while do break continue for
			try catch finally throw throws
			private protected public
			import package class interface extends implements static final void abstract native
			new return this super
			synchronized volatile
			const goto instanceof enum assert transient strictfp
		}
		code = prepare_code false
		code.gsub!(/\w+\(/, '')
		hash = Hash.new(0)
		code.scan(/\".+\"/).each do |match|
			hash[match.to_s] += 1 unless keywords.include?(match)
		end
		code.gsub!(/\".+\"/)
		code.scan(/\w+/).each do |match|
			hash[match.to_s] += 1 unless keywords.include?(match)
		end
		hash
	end

	def init
		hash_oprs = find_conditions_loops_switch.merge(find_count_govno).merge(find_count_ebutchee_govno)
		hash_opds = find_variables
		self.operators = hash_oprs.to_json.to_s
		self.operands = hash_opds.to_json.to_s
		self.uniq_operators = hash_oprs.size
		self.uniq_operands = hash_opds.size
		self.count_operators = hash_oprs.values.reduce(:+)
		self.count_operands = hash_opds.values.reduce(:+)
		self.save!
	end

end
