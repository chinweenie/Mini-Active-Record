require_relative '03_associatable'
require 'active_support/inflector'


# Phase IV
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

  def has_one_through(name, through_name, source_name)
    define_method(name) do 
      through_options = self.class.assoc_options[through_name]
      source_options = through_options.model_class.assoc_options[source_name]

      # Cat belongs to human, so cat has foreign key
      through_table = through_options.table_name #humans
      through_pk = through_options.primary_key  #human.id
      through_fk = through_options.foreign_key  #cat.owner_id

      # Human belongs to a house, so it has a foreign key
      source_table = source_options.table_name #houses
      source_pk = source_options.primary_key #house.id     
      source_fk = source_options.foreign_key  #human.house_id

      key_val = self.send(through_fk)

      # SELECT
      #   houses.*  
      # FROM
      #   humans 
      # JOIN
      #   houses ON houses.id = humans.house_id 
      # WHERE  
      #   humans.id = cats.owner_id

      results = DBConnection.execute(<<-SQL, key_val)
        SELECT
          #{source_table}.*
        FROM
          #{source_table}
        JOIN
          #{through_table}
        ON
          #{through_table}.#{source_fk} = #{source_table}.#{source_pk}
        WHERE
          #{through_table}.#{through_pk} = ?
      SQL
      source_options.model_class.parse_all(results).first
    end
  end

  def has_many_through(name, through_name, source_name)
    # Gym has_many :pokemons, through: :trainers, source: :pokemons
    through_assoc = "humans".to_sym if through_name == "human"
    through_assoc ||= through_name.to_s.tableize.to_sym
    define_method(name) do
      # Trainer belongs to gym, so trainer has foreign key
      through_table = through_options.table_name #trainers
      through_pk = through_options.primary_key  #trainer_id
      through_fk = through_options.foreign_key  #trainers.gym_id

      # Pokemon belongs to a trainer, so it has a foreign key
      source_table = source_options.table_name #pokemons
      source_pk = source_options.primary_key #pokemon.id     
      source_fk = source_options.foreign_key  #pokemon.trainer_id

      key_val = self.send(through_fk) # get the value of trainers.gym_id

      # SELECT
      #   pokemons.*  
      # FROM
      #   trainers 
      # JOIN
      #   pokemons ON trainers.id = pokemons.trainer_id 
      # WHERE  
      #   gyms.id = trainers.gym_id

      results = DBConnection.execute(<<-SQL, key_val)
        SELECT
          #{source_table}.*
        FROM
          #{source_table}
        JOIN
          #{through_table}
        ON
          #{through_table}.#{source_fk} = #{source_table}.#{source_pk}
        WHERE
          #{through_table}.#{through_pk} = ?
      SQL

      source_options.model_class.parse_all(results)    
    end
  end
end
