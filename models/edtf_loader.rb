# frozen_string_literal: true

require 'edtf'

# Helper to coerce EDTF fields
module EdtfLoader
  def edtf_field(*fields)
    fields.each do |field|
      define_method(field) do
        return if values[field].nil?

        EDTF.parse(values[field])
      end
    end
  end
end
