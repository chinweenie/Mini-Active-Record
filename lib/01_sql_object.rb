require_relative 'db_connection'
require 'active_support/inflector'
require_relative '02_searchable'
require_relative '03_associatable'
require 'byebug'

# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    return @columns if @columns 
    columns = DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
      LIMIT
        0
    SQL
    @columns = columns.first.map! {|ele| ele.to_sym}
  end

  def self.finalize!
    self.columns.each do |col|
      define_method("#{col}") do    
        self.attributes[col]
      end
      define_method("#{col}=") do |val|
        self.attributes[col] = val
      end   
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name || self.name.underscore.pluralize
  end

  def self.all  
    results = DBConnection.execute(<<-SQL)
        SELECT
         *
        FROM
         #{self.table_name}
      SQL
    self.parse_all(results)
  end

  def self.parse_all(results)
    arr = []
    results.each do |attr_hash|
      arr << self.new(attr_hash)
    end
    arr
  end

  def self.find(id)
    results = DBConnection.execute(<<-SQL, id)
      SELECT
        '#{self.table_name}'.*
      FROM
        '#{self.table_name}'
      WHERE
        '#{self.table_name}'.id = ?
    SQL
    # we dont need to call self.class.parse_all because we
    # are calling this inside a class method
    # same goes to self.table_name, actually we dont
    # need to call self.table_name
    parse_all(results).first
  end

  def initialize(params = {})
    keys = params.keys.map(&:to_sym).each do |key|
      raise "unknown attribute '#{key}'" unless self.class.columns.include?(key)
    end

    params.each do |key, val|
      self.send("#{key}=", val)
    end
    
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    self.class.columns.map{ |col| self.send(col)}
  end

  def insert
    columns = self.class.columns.drop(1)
    col_names = columns.map(&:to_s).join(', ') 
    question_marks = (["?"] * columns.length).join(', ')

    DBConnection.execute(<<-SQL, *self.attribute_values.drop(1))
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
       (#{question_marks})
    SQL
    self.id = DBConnection.last_insert_row_id
  end

  def update
    set_line = self.class.columns
      .map { |attr| "#{attr} = ?" }.join(", ")

    DBConnection.execute(<<-SQL, *self.attribute_values, id)
      UPDATE
        #{self.class.table_name}
      SET
        #{set_line}
      WHERE
        #{self.class.table_name}.id = ?
    SQL
  end

  def save
    self.id.nil? ? self.insert : self.update
  end
end
