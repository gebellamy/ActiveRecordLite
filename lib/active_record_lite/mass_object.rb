class MassObject
	attr_reader :attributes

	def self.set_attrs(*attributes)
		@attributes = []
		attributes.each do |attribute|
			@attributes << attribute
			send(:attr_accessor, :attribute)
		end
	end

	def self.attributes
		@attributes
	end

	def self.parse_all(results)
		all_parsed = []
		results.each do |result|
			all_parsed << self.new(result)
		end
		all_parsed
	end

	def initialize(params = {})
		params.each do |attr_name, value|
			attr_name = attr_name.to_sym
			if self.class.attributes.include?(attr_name)
				self.instance_variable_set(eval(":@#{attr_name}"), value)
			else
				raise "mass assignment to unregistered variable #{attr_name}"
			end
		end
	end
end
