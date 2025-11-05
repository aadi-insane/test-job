# config/initializers/elasticsearch.rb
if File.exists?("config/elasticsearch.yml")
  config = YAML.load_file("config/elasticsearch.yml")[Rails.env]
  Elasticsearch::Model.client = Elasticsearch::Client.new(config.merge(url: ENV['ELASTICSEARCH_URL']))
end