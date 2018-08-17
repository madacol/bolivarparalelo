require 'active_record'

ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end
class Rate < ApplicationRecord
end