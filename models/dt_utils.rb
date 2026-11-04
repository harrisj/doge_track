# frozen_string_literal: true

require 'edtf'

# Handles EDTF interval ranges like "2025-01-20/2025-12-31"
# Provides min_date_date and max_date_date methods returning single Date objects
module DtUtils
  # Parse an EDTF field and return min/max as Date objects
  def self.parse_interval(raw_value)
    # EDTF.parse handles nil gracefully (returns nil)
    # Also handles empty string gracefully
    parsed = EDTF.parse(raw_value)

    return nil unless parsed

    if parsed.respond_to?(:min) && parsed.respond_to?(:max)
      min_date = parsed.min
      max_date = parsed.max
      if min_date && max_date
        [min_date.to_date, max_date.to_date]
      elsif min_date
        [min_date.to_date, nil]
      elsif max_date
        [nil, max_date.to_date]
      end
    else
      parsed_date = parsed.is_a?(Date) ? parsed : parsed.to_date
      [parsed_date, parsed_date]
    end
  end
end
