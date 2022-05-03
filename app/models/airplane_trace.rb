require 'dry-struct'

class AirplaneTrace < Dry::Struct
  attribute :name, Types::String
  attribute :age, Types::String
end
