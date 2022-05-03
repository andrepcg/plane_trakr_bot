# frozen_string_literal: true

class Migration
  def migrate
    Sequel::Migrator.run(establish_connection, './db/migrate')
    puts "Database migrated"
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

    version = if db.tables.include?(:schema_info)
      db[:schema_info].first[:version]
    end || 0
  end

  def generate_migration(name)
    name = name || raise("Specify name: rake g:migration your_migration")
    timestamp = Time.now.strftime("%Y%m%d%H%M%S")
    migration_class = name.split("_").map(&:capitalize).join
    path = "db/migrate/#{timestamp}_#{name}.rb"

    File.open(path, "w") do |file|
      file.write <<-EOF
      # frozen_string_literal: true

      Sequel.migration do
        change do
        end
      end
    EOF
    end

    puts "migration #{path} created"
  end

  private

  def establish_connection(config = @configurations)
    Sequel.connect(Server.config.database.url)
  end
end
