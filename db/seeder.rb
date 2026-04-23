require 'sqlite3'
require_relative '../config'

class Seeder
  def self.seed!
    db = SQLite3::Database.new(DB_PATH)
    db.results_as_hash = true

    db.execute('DROP TABLE IF EXISTS products')

    db.execute <<~SQL
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        price INTEGER NOT NULL,
        description TEXT NOT NULL
      )
    SQL

    db.execute(
      'INSERT INTO products (name, category, price, description) VALUES (?, ?, ?, ?)',
      ['Vindkraftverk', 'Vindkraftverk', 14999, 'Hej']
    )

    db.execute(
      'INSERT INTO products (name, category, price, description) VALUES (?, ?, ?, ?)',
      ['Solpanel', 'Solpanel', 2999, 'Hej']
    )

    db.close
  end
end
