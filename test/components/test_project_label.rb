# frozen_string_literal: true

require_relative '../minitest_helper'
require_relative '../../src/_components/atoms/project_label'

class TestProjectLabel < Bridgetown::Test
  before do
    @site = Bridgetown::Site.new(Bridgetown::Current.preloaded_configuration)
    Bridgetown::Current.site = @site
  end

  it 'renders a status badge with the project label and color' do
    project = ::Project.first
    rendered = Bridgetown::TemplateView.render(::Atoms::ProjectLabel.new(project: project)).call

    expect(rendered).must_equal(
      %(<div aria-label="Project: #{project.label_text}" class="status status-md status-#{project.label_color}"></div>)
    )
  end
end
