module Searchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks

    mappings dynamic: 'false' do
      indexes :name, type: 'string'
      indexes :summary, type: 'string'
      indexes :description, type: 'string'

      indexes :chef, type: 'nested' do
        indexes :chefname, type: 'string'
      end
    end

    def as_indexed_json(options={})
      self.as_json( include: {chef: { only: :chefname} })
    end
  end
end