require 'smarter_csv'
require 'zlib'

class DateConverter
  def self.convert(value)
    Time.parse(value)
  end
end

class LicencesConverter
  def self.convert(value)
    value.split(',').map(&:strip)
  end
end

module Import
  CONF = {
    journal_title: :name,
    journal_url: :url,
    'journal_eissn_(online_version)': :issn_e,
    keywords: :keywords,
    publisher: :publisher,
    journal_license: :licenses,
    subjects: :subjects,
    number_of_article_records: :articles_count,
    most_recent_article_added: :articles_last
  }.freeze

  def self.reload!(url = 'https://doaj.org/csv')
    MDB[:journals].drop
    chunks(cached(url)) { |chunk| MDB[:journals].insert_many(chunk) }
    p "Imported #{MDB[:journals].count} journals"
  end

  def self.cached(url)
    FileUtils.mkdir_p 'tmp'
    File.write('tmp/doaj.csv', download(url)) unless File.exist?('tmp/doaj.csv')
    'tmp/doaj.csv'
  end

  def self.chunks(file, &)
    SmarterCSV.process(
      file,
      chunk_size: 1000,
      key_mapping: CONF,
      remove_unmapped_keys: true,
      value_converters: { articles_last: DateConverter, licenses: LicencesConverter },
      &)
  end

  def self.download(url)
    uri = URI(url)
    Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
      request = Net::HTTP::Get.new(uri)
      http.request(request) do |response|
        case response
        when Net::HTTPSuccess
          return response.body
        when Net::HTTPRedirection
          return download(response['location'])
        else
          raise "Unexpected response: #{response}"
        end
      end
    end
  end
end
