# frozen_string_literal: true

namespace :zeitwerk do
  desc "Checks project structure for Zeitwerk compatibility"
  task check: :environment do
    begin
      Zeitwerk::Loader.eager_load_all
    rescue NameError => e
      if e.message =~ /expected file .*? to define constant [\w:]+/
        abort $&.sub(/expected file #{Regexp.escape(Server.config.root)}./, "expected file ")
      else
        raise
      end
    end
  end
end

