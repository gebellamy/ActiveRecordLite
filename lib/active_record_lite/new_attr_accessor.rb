class Cat
  
  def self.new_attr_accessor(*args)
  	args.each do |i_var_name|
  		instance_variable_set(eval(":@#{i_var_name}"), nil)
  	end
  end

  def method_missing(method_name)
  	method_name = method_name.to_s
  	
  end

  new_attr_accessor :name, :color


end



 cat = Cat.new
 cat.name = "Sally"
 cat.color = "brown"

 puts cat.name # => "Sally"
 puts cat.color