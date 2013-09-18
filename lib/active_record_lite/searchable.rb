require_relative './db_connection'

module Searchable
  def where(params)
  	column_names = []
  	values = []
  	params.each do |column, value|
  		column_names << "#{column} = ?"
  		values << value
  	end

  	DBConnection.execute("
  		SELECT *
  		FROM #{self.table_name}
  		WHERE #{column_names.join(" AND ")}
  		", values)
  end
end