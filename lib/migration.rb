# frozen_string_literal: true

class Migration
  def migrate
    Sequel::Migrator.run(establish_connection, './db/migrate')
    puts 'Database migrated'
  end

  def rollback(target = 0)
    Sequel::Migrator.run(@db, './db/migrate', target: target)
  end

  def reset
    db = establish_connection
    Sequel::Migrator.run(db, './db/migrate', target: 0)
    Sequel::Migrator.run(db, './db/migrate')
  end

  def version
    db = establish_connection

    (db[:schema_info].first[:version] if db.tables.include?(:schema_info)) || 0
  end

  def generate_migration(name)
    name ||= raise('Specify name: rake g:migration your_migration')
    timestamp = Time.now.strftime('%Y%m%d%H%M%S')
    path = "db/migrate/#{timestamp}_#{name}.rb"

    File.open(path, 'w') do |file|
      file.write <<-FILE
      # frozen_string_literal: true

      Sequel.migration do
        change do
        end
      end
      FILE
    end

    puts "migration #{path} created"
  end

  private

  def establish_connection(_config = @configurations)
    Sequel.connect(Server.config.database.url)
  end
end
