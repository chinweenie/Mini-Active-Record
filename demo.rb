require_relative 'lib/01_sql_object'
require_relative 'lib/db_connection'

class Gym < SQLObject 
    has_many :trainers,
        primary_key: :id,    
        foreign_key: :gym_id,
        class_name: 'Trainer'
    
    has_many_through :pokemons, :trainers, :pokemon

    finalize!
end

class Trainer < SQLObject
    belongs_to :gym,
        primary_key: :id,    
        foreign_key: :gym_id,
        class_name: 'Gym'

    has_many :pokemons,
        primary_key: :id,    
        foreign_key: :trainer_id,
        class_name: 'Pokemon'

    finalize!
end

class Pokemon < SQLObject  
    belongs_to :trainer,
        primary_key: :id,    
        foreign_key: :trainer_id,
        class_name: 'Trainer'

    has_one_through :gym, :trainer, :gym

    finalize!
end

