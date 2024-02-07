module Search
  class Default
    def self.create_index(conf, name)
      MDB[:journals].search_indexes.create_one(conf, name: name) unless index_exists?(name)
    end

    def self.index_exists?(name)
      MDB[:journals].search_indexes.find { |n| n[:name] == name }
    end
  end
end
