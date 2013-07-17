module Tapir
  class ReportTemplate
    include Mongoid::Document
    field :name, type: String

    validates_uniqueness_of :name  
  end
end