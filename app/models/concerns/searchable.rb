module Searchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks

    settings index: {
      number_of_shards: 1,
      analysis: {
        filter: {
          autocomplete_filter: {
            type: "edge_ngram",
            min_gram: 2,
            max_gram: 20
          }
        },
        analyzer: {
          autocomplete: {
            type: "custom",
            tokenizer: "standard",
            filter: ["lowercase", "autocomplete_filter"]
          },
          autocomplete_search: {
            type: "custom",
            tokenizer: "standard",
            filter: ["lowercase"]
          }
        }
      }
    }
  end

  class_methods do
    def search(query, fields)
      return all if query.blank?

      __elasticsearch__.search({
        query: {
          bool: {
            should: [
              {
                multi_match: {
                  query: query,
                  fields: fields,
                  fuzziness: 'AUTO'
                }
              },
              {
                wildcard: {
                  "#{fields.first.split('^').first}": { value: "*#{query.downcase}*" }
                }
              }
            ]
          }
        }
      })
    end
  end
end
