require 'active_support/core_ext/object/try'
require 'active_support/inflector'
require_relative './db_connection.rb'
require 'active_support/inflector'

class AssocParams
  def other_class
  end

  def other_table
  end
end

class BelongsToAssocParams < AssocParams
  attr_reader :other_class_name, :primary_key, :foreign_key, :other_class, :other_table_name
  def initialize(name, params = {})
    if params[:class_name].nil?
      @other_class_name = "#{name.to_s.camelize}"
    else
      @other_class_name = params[:class_name]
    end
    if params[:id].nil?
      @primary_key = :id
    else
      @primary_key = params[:id]
    end
    if params[:foreign_key].nil?
      @foreign_key = eval(":#{name}_id")
    else
      @foreign_key = params[:foreign_key]
    end
  end

  def type
  end
end

class HasManyAssocParams < AssocParams
  attr_reader :other_class_name, :primary_key, :foreign_key, :other_class, :other_table_name
  def initialize(name, params, self_class)
    if params[:class_name].nil?
        @other_class_name = eval("#{name.to_s.singularize.camelize}")
      else
        @other_class_name = params[:class_name]
      end
      if params[:id].nil?
        @primary_key = :id
      else
        @primary_key = params[:id]
      end
      if params[:foreign_key].nil?
        @foreign_key = eval(":#{self_class.underscore}_id")
      else
        @foreign_key = params[:foreign_key]
      end

      @other_class = @other_class_name.to_s.constantize
      @other_table_name = @other_class.table_name
  end

  def type
  end
end

module Associatable
  def assoc_params
    @assoc_params ||= {}
  end

  def belongs_to(name, params = {})
    aps = BelongsToAssocParams.new(name, params)
    self.assoc_params["#{name}"] = aps
    
    define_method("#{name}") do
      aps.other_class_name.to_s.constantize.find(eval("@#{aps.foreign_key}"))
    end
  end

  def has_many(name, params = {})
    define_method("#{name}") do 
      aps = HasManyAssocParams.new(name, params, self.class)
      many = aps.other_class.where({eval("@#{aps.primary_key}") => @id})
      aps.other_class.parse_all(many)
    end
  end

  def has_one_through(name, assoc1, assoc2)
    assoc1_params = self.assoc_params[assoc1.to_s]
    p assoc1_params
    define_method("#{name}") do
      assoc2_params = assoc1.to_s.camelize.constantize.assoc_params[assoc2.to_s]
      stuff = DBConnection.execute("
        SELECT *
        FROM #{assoc2_params.other_class_name.constantize.table_name}
        JOIN #{assoc1_params.other_class_name.constantize.table_name}
        ON (#{assoc2_params.primary_key} = #{assoc1_params.other_class_name.constantize.instance_variable_get(:@id)})
        ")

      p stuff
    end
  end
end
