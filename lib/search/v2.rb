module Search
  class V2 < Default
    def self.index_mappings
      { 'mappings' => {
          'dynamic' => false,
          'fields' => {
            'name' => { 'type' => 'string' },
            'publisher' => { 'type' => 'string' },
            'issn_e' => { 'analyzer' => 'lucene.whitespace', 'ignoreAbove' => 10,
                          'searchAnalyzer' => 'lucene.whitespace', 'type' => 'string' },
            'licenses' => { 'analyzer' => 'lucene.keyword', 'searchAnalyzer' => 'lucene.keyword', 'type' => 'string' },
            'subjects' => { 'type' => 'string' },
            'articles_count' => { 'type' => 'number' },
            'articles_last' => { 'type' => 'date' }
          }
        },
        'storedSource' => true }
    end

    # Search::V2.issn('2175-2346').map{|n| n[:issn_e] }
    def self.issn(q)
      req = { '$search' => { text: { query: q, path: 'issn_e' }, index: 'v2' } }
      MDB[:journals].aggregate([req])
    end

    def self.multi(q)
      req = {
        '$search' => { compound: {
          should: [{ text: { query: q, path: %w[name subjects keywords publisher] } }],
          minimumShouldMatch: 1
        }, index: 'v2' }
      }
      MDB[:journals].aggregate([req])
    end

    # Search::V2.active('biology').map { |n| n[:licenses] }.uniq

    def self.active(q)
      req = {
        '$search' => { compound: {
          should: [{ text: { query: q, path: %w[name subjects keywords publisher] } }],
          must: [
            { range: { path: 'articles_last', gt: (Date.today - 365).to_time } },
            { range: { path: 'articles_count', gt: 300 } },
            { phrase: { query: 'CC BY', path: 'licenses' } }
          ],
          minimumShouldMatch: 1
        }, index: 'v2' }
      }
      MDB[:journals].aggregate([req])
    end

    def self.score(q)
      req = [
        { '$search' => { compound: {
          should: [{ text: { query: q, path: %w[name subjects keywords publisher] } }],
          must: [
            { range: { path: 'articles_last', gt: (Date.today - 365).to_time } },
            { range: { path: 'articles_count', gt: 300 } }
          ],
          minimumShouldMatch: 1
        }, index: 'v2' } },
        { '$addFields' => { score: { '$meta' => 'searchScore' } } },
        { '$limit' => 10 }
      ]
      MDB[:journals].aggregate(req)
    end

    def self.boost(q)
      req = [
        { '$search' => { compound: {
          should: [
            { phrase: { query: q, path: 'name', score: { boost: { value: 5 } } } },
            { text: { query: q, path: %w[name] } }
          ],
          must: [
            { range: { path: 'articles_last', gt: (Date.today - 365).to_time } },
            { range: { path: 'articles_count', gt: 300 } }
          ],
          minimumShouldMatch: 1
        }, index: 'v2' } },
        { '$addFields' => { score: { '$meta' => 'searchScore' } } },
        { '$project' => { _id: 0, name: 1, articles_count: 1, score: 1 } },
        { '$limit' => 10 }
      ]
      MDB[:journals].aggregate(req)
    end

    def self.extra_boost(q)
      custom_boost = {
        function: {
          multiply: [
            { log1p: { path: { value: 'articles_count' } } },
            { score: 'relevance' }
          ]
        }
      }

      req = [
        { '$search' => { compound: {
          should: [
            { phrase: { query: q, path: 'name', score: { boost: { value: 5 } } } },
            { text: { query: q, path: %w[name] } }
          ],
          must: [
            { range: { path: 'articles_last', gt: (Date.today - 365).to_time } },
            { range: { path: 'articles_count', gt: 300, score: custom_boost } }
          ],
          minimumShouldMatch: 1
        }, index: 'v2' } },
        { '$addFields' => { score: { '$meta' => 'searchScore' } } },
        { '$project' => { _id: 0, name: 1, articles_count: 1, score: 1 } },
        { '$limit' => 10 }
      ]
      MDB[:journals].aggregate(req)
    end

    def self.setup
      create_index(index_mappings, 'v2')
    end
  end
end
