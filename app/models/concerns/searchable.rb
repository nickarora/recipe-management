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

    def self.chef_search(query, chefname, options={})
      options ||= {}

      # empty search not allowed, for now
      return nil if query.blank? && options.blank?

      # define search definition
      search_definition = {
        query: {
          bool: {
            must: []
          }
        }
      }

      if query.present?
        search_definition[:query][:bool][:must] << {
          multi_match: {
            query: query,
            fields: %w(name summary description),
            operator: 'and'
          }
        }
      end

      if chefname.present?
        search_definition[:query][:bool][:must] << {
          nested: {
            path: 'chef',
            query: {
              bool: {
                must: [
                  match: {
                    chefname: chefname
                  }
                ]
              }
            }
          }
        }
      end

      __elasticsearch__.search(search_definition)
    end
  end
end