module Search
  class V1 < Default
    # Find journals by name
    def self.text(q)
      req = { '$search' => { text: { query: q, path: 'name' }, index: 'v1' } }
      MDB[:journals].aggregate([req])
    end

    # Search::V1.phrase("Medicine Health").map{|n| n[:name]}
    def self.phrase(q)
      req = { '$search' => { phrase: { query: q, path: 'name', slop: 2 }, index: 'v1' } }
      MDB[:journals].aggregate([req])
    end

    # Search::V1.advanced("(Med* OR Health) AND publisher:BMC").map{|n| [n[:name], n[:publisher]]}
    def self.advanced(q)
      req = { '$search' => { queryString: { query: q, defaultPath: 'name' },
                             index: 'v1' } }
      MDB[:journals].aggregate([req])
    end

    # Search::V1.issn('2175-2346').map{|n| n[:issn_e] }
    def self.issn(q)
      req = { '$search' => { text: { query: q, path: 'issn_e' }, index: 'v1' } }
      MDB[:journals].aggregate([req])
    end

    def self.setup
      create_index({ mappings: { dynamic: true } }, 'v1')
    end
  end
end
