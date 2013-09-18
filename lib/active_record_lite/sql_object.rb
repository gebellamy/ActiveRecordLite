require_relative './associatable'
require_relative './db_connection'
require_relative './mass_object'
require_relative './searchable'
require 'active_support/inflector'

class SQLObject < MassObject

  extend Searchable
  extend Associatable

  def self.set_table_name(table_name)
    table_name = table_name.underscore
    @table_name = table_name
  end

  def self.table_name
    @table_name
  end

  def self.all
    rows = DBConnection.execute("SELECT * FROM #{self.table_name}")
    all = []
    rows.each do |row|
      all << self.new(row)
    end
    all
  end

  def self.find(id)
    instance = DBConnection.execute("
      SELECT * 
      FROM #{self.table_name}
      WHERE id = ?", id)

    self.new(instance.first)
  end

  def create
    no_id = self.class.attributes.select {|attr| attr != :id}
    comma_sep_attributes = "(#{no_id.join(", ")})"
    question_marks = "(#{(['?'] * no_id.count).join(", ")})"
    values = no_id.map { |attr_name| eval("@#{attr_name}") }
    
    DBConnection.execute("
          INSERT INTO #{self.class.table_name}
          #{comma_sep_attributes}
          VALUES #{question_marks}", values)

    @id = self.class.all.last.instance_variable_get(:@id)
  end

  def update
    set_line = self.class.attributes.map { |attr_name| "#{attr_name} = ?" }.join(", ")
    values = attribute_values

    DBConnection.execute("
      UPDATE #{self.class.table_name}
      SET #{set_line}
      WHERE id = #{@id}
      ", values)
  end

  def save
    if @id.nil?
      self.create
    else
      self.update
    end
  end

  def attribute_values
    self.class.attributes.map { |attr_name| eval("@#{attr_name}") }
  end
end
