# frozen_string_literal: true

require "active_support/string_inquirer"

module Initialization
  def initialize!
    raise "Application has already been initialized." if @initialized

    run_initializers
    @initialized = true
  end

  def env
    @env ||= begin
      raise "RUBY_ENV env var is missing!" if ENV["RUBY_ENV"].nil?
      ActiveSupport::StringInquirer.new(ENV["RUBY_ENV"])
    end
  end

  private

  def run_initializers
    initialize_root_path
    initialize_env_vars
    initialize_encoding
    run_config_initializer_files
  end

  # Resolves the root directory of the application and assigns the value to `config.root`.
  #
  # The idea here is to iterate the paths in the callstack until we find a
  # directory that contains `boot.rb` file.
  def initialize_root_path
    return if config.root

    # Inspired by Rails:
    # https://github.com/rails/rails/blob/7578e6f141e3c24fc6a1208e189eb1958d0b304f/railties/lib/rails/engine.rb#L364
    call_stack = caller_locations.map { |l| l.absolute_path || l.path }
    candidates = call_stack.reject { |p| p.match?(/ruby\/gems/) }

    candidates.each do |f|
      dir = File.dirname(f)
      next unless File.directory?(dir)
      next unless File.exist?("#{dir}/boot.rb")

      config.root = dir
      return
    end

    raise "Couldn't find root path for application. "\
      "Make sure that boot.rb file is present in root directory."
  end

  # Loads values from `config/env_vars.yml` file and assigns them to `ENV`.
  # If an ENV variable with given name already exists it won't be replaced.
  #
  # An example `env_vars.yml` file may look like this:
  # default: &default
  #   DDB_TABLE_NAME: "no-such-table"
  #   AWS_REGION: "us-east-1"
  # test:
  #   <<: *default
  #   URANINITE_DB_DATABASE: "radium_test"
  # development:
  #   <<: *default
  #   URANINITE_DB_DATABASE: "radium_development"
  #   DDB_TABLE_NAME: "radium-tracking-stats-staging"
  def initialize_env_vars
    file = File.expand_path(File.join(config.root, "config/env_vars.yml"))
    raise "config/env_vars.yml file is missing" unless File.exist?(file)

    yaml_content = YAML.load_file(file)

    return unless yaml_content.key?(env)

    yaml_content[env].each do |key, value|
      ENV[key] ||= value || ""
    end
  end

  def initialize_encoding
    # Ensure Ruby uses UTF-8 so strings are properly interpreted.
    # Without this HttpUrlValidator fails as PublicSuffix
    # raises invalid US-ASCII character error for every string.
    #
    # This is done in Rails apps automatically in application.rb via `config`:
    # https://github.com/rails/rails/blob/b6987d6e14070d4d0bce85d0b3fa0008b024d5dc/railties/lib/rails/application/configuration.rb#L282
    Encoding.default_external = Encoding::UTF_8
    Encoding.default_internal = Encoding::UTF_8
  end

  # Loads Rails-like initializers by including all files (sorted alphabetically)
  # contained in `config/initializers` directory.
  def run_config_initializer_files
    Dir[File.join(config.root, "config", "initializers", "**", "*.rb")].sort.each { |f| require f }
  end
end
