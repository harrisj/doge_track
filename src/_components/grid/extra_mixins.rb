# frozen_string_literal: true

module Grid
  # Extra mixins
  module ExtraMixins
    def extra_table(body)
      <<~HTML
        <table class="table-fixed text-xs md:text-sm xl:table-md">
          #{html -> { body }}
        </table>
      HTML
    end

    def extra_item(icon, body)
      <<~HTML
        <tr>
          <td class="align-top align-center w-[22px]">#{render Atoms::Icon.new(icon)}</td>
          <td class="align-top align-left">#{html -> { body }}</td>
        </tr>
      HTML
    end

    def fuzz_extra(item)
      return unless item.fuzz

      extra_item 'question', <<~HTML.chomp
        <span class="italic">Fuzz: #{render Atoms::Blurb.new(item.fuzz)}
      HTML
    end

    def agencies_extra(item)
      return unless item.agencies.any?

      extra_item 'agency', <<~HTML.chomp
        #{render Atoms::AgenciesList.new(item.agencies, style: :comma)}
      HTML
    end

    def people_extra(item)
      people = if item.is_a?(Array)
                 item
               else
                 item.people
               end

      return unless people.any?

      extra_item 'person', <<~HTML.chomp
        #{render Atoms::PeopleList.new(people, style: :comma)}
      HTML
    end

    def projects_extra(item)
      return unless item.projects.any?

      extra_item 'project', <<~HTML.chomp
        #{render Atoms::ProjectsList.new(item.projects, style: :comma)}
      HTML
    end

    def sources_extra(item)
      return unless item.sources.any?

      html_map(item.sources) do |source|
        extra_item 'source', <<~HTML
          <small><a target="_blank" href="#{text -> { source.url }}"><cite>#{text -> { source.title }}</cite></a> #{text -> { source.publisher.name }},&nbsp;#{html -> { render Atoms::DateLabel.new(source.pub_date) }}</small>
        HTML
      end
    end

    def table_note_extra(text)
      return unless text

      extra_item 'table_note', <<~HTML.chomp
        <span class="italic">#{text -> { text }}</span>
      HTML
    end

    def position_extra(position)
      if position.type == 'detailed'
        <<~HTML.chomp
          <td colspan="2" class="align-top">#{render Atoms::PositionMoveLabel.new(position: position)} #{render Atoms::PersonOrAliasLink.new(position.person || position.doge_alias)} #{render Atoms::DateRange.new(start_date: position.start_date, end_date: position.end_date)}</td>
        HTML
      else
        extra_item position.type, <<~HTML.chomp
          #{render Atoms::PersonOrAliasLink.new(position.person || position.doge_alias)} #{render Atoms::DateRange.new(start_date: position.start_date, end_date: position.end_date)}
        HTML
      end
    end

    def title_extra(position)
      return unless position.title

      extra_item 'job_title', <<~HTML
        #{text -> { position.title }}#{text -> { ", #{text -> { position.office }}" if position.office }}
      HTML
    end

    def salary_extra(position)
      return unless position.salary

      salary = position.salary == '$0' ? 'Volunteer' : position.salary

      extra_item 'salary', <<~HTML.chomp
        #{text -> { salary }}#{html -> { ' (<abbr title="Special Government Employee">SGE</abbr>)' if position.sge }}
      HTML
    end

    def system_name_extra(govt_system)
      return unless govt_system

      extra_item 'access', <<~HTML.chomp
        #{render Atoms::SystemLink.new(govt_system, expanded: true)}
      HTML
    end

    def access_type_extra(grants)
      return if grants.empty?

      system_role = grants.first

      extra_item 'system_grant', <<~HTML.chomp
        #{text -> { system_role.type }} #{render Atoms::DateRange.new(start_date: system_role.date_granted, end_date: system_role.date_revoked)} #{render Atoms::PeopleList.new(grants.map(&:person), style: :comma)}
      HTML
    end

    def extra_section
      contents = extra_contents

      if contents
        <<~HTML
          <div class="collapse-content text-sm p-0">
            <div class="ml-[25px] pt-1 flex flex-col gap-y-3">
               #{html -> { contents }}
            </div>
          </div>
        HTML
      else
        html -> { '' }
      end
    end
  end
end
