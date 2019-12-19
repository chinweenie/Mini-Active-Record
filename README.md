# MiniActRecord
MiniActRecord is a customized object relational database library that facilitates 
the mapping of Ruby objects to their relative tables in the database. MiniActRecord
abtracts away complicated SQL queries and provides an intuitive interface for users
to interact with the database.

## Demo
To use the library,
1. Clone the repo
2. Load 'pry' in the terminal
3. Run `load 'demo.rb'`
4. Test it out in pry

The database consists of the following tables:

### Gyms
Column          | Data Type | Details
--------------- | --------- | -------
id              | integer   | not null, primary key
name            | string    | not null

### Trainers
Column          | Data Type | Details
--------------- | --------- | -------
id              | integer   | not null, primary key
name            | string    | not null
gym_id          | integer   |

### Pokemon
Column          | Data Type | Details
--------------- | --------- | -------
id              | integer   | not null, primary key
name            | string    | not null
trainer_id      | integer   |

## For use in private projects
1. Download the contents of lib folder
2. Change `demo.sql` to own SQlite3 table file in `db_connection.rb`
3. Replace `demo.db` with what you want your database file name to be in `db_connection.rb`

## Libraries
* SQLite3
* ActiveSupport::Inflector

## Methods defined
* `all`
* `first`
* `last`
