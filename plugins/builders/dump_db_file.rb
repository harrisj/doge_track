# frozen_string_literal: true

require 'json'

module Builders
  # Save out a static API
  class DumpDBFile < SiteBuilder
    def build
      hook :site, :post_write do |_|
        file = site.in_destination_dir('downloads', 'dogetrack.sql.gz')
        FileUtils.mkdir_p(File.dirname(file))
        `sqlite3 data/doge.sqlite .dump | gzip -c >#{file}`
      end
    end
  end
end
