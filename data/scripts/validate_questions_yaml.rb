# frozen_string_literal: true

require 'yaml'
require 'date'
require 'edtf'
require 'shortuuid'

questions_file = File.join(File.dirname(__FILE__), '..', 'raw_data', 'questions.yaml')
questions = YAML.unsafe_load(File.read(questions_file), symbolize_names: true)

questions = questions.map do |q|
  unless q.key?(:id)
    id = SecureRandom.uuid
    q[:id] = ShortUUID.shorten(id)[0...8]
  end

  q
end

File.open(questions_file, 'w') do |file|
  schema_hdr = "# yaml-language-server: $schema=../schemas/questions-file.json\n"
  out_yaml = YAML.dump(questions, line_width: 300, stringify_names: true, header: false)
  file.write(schema_hdr, out_yaml.gsub(/^- /, "\n- "))
end
