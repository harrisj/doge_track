# frozen_string_literal: true

module Grid
  # The roles for a particular system
  class SystemRoles < Bridgetown::Component
    include ExtraMixins

    def initialize(govt_system:, expanded: false)
      super()
      @govt_system = govt_system
      @system_roles = govt_system.system_roles
      @expanded = expanded

      @min_date = @system_roles.map(&:date_granted).compact.min
      @max_date = @system_roles.map(&:date_revoked).compact.max unless @system_roles.any? { |r| r.date_revoked.nil? }

      @user_count = @system_roles.count
      @elevated_count = @system_roles.select { |r| r.access_class == 'elevated' }.count
      @grouped_roles = @system_roles.group_by do |r|
        [r.date_granted, r.date_revoked || Date.today, r.type, r.ao_doge || '']
      end
    end

    def sources
      @sources = @system_roles.map(&:sources).flatten.compact.uniq if @sources.nil?

      @sources
    end

    def access_details
      ordered_roles = @grouped_roles.sort_by { |grp| grp[0].inspect }
      html_map(ordered_roles) do |grp|
        roles = grp[1]
        names = roles.map(&:name).uniq.compact
        unidentified_aliases = roles.select(&:doge_alias_id).select { |x| x.name.nil? }.map(&:doge_alias_id).uniq

        if roles[0].type != 'unknown'
          access_span = <<~HTML.rstrip
            <span>(#{text -> { roles[0].type }}<span class="hidden sm:inline"> access</span></span>)
          HTML
        end

        if roles[0].ao_doge && roles[0].ao_name
          ao_span = <<~HTML.rstrip
            <span>grant by #{render Atoms::PersonLink.new(roles[0].ao_name)}</span>
          HTML
        end
        extra_item 'system_grant', <<~HTML.chomp
          #{render Atoms::DateRange.new(start_date: roles[0].date_granted, end_date: roles[0].date_revoked, always_dash: true)}
          #{render Atoms::PeopleList.new(names + unidentified_aliases, style: :comma)}
          #{html -> { access_span }} #{html -> { ao_span }}
        HTML
      end
    end

    def extra_contents
      extra_table <<~HTML
        #{html -> { access_details }}
        #{html -> { sources_extra(self) }}
        #{html -> { projects_extra(@govt_system) }}
      HTML
    end

    def user_count
      if @elevated_count.positive?
        if @elevated_count == @user_count
          text -> { "#{@elevated_count} users with elevated access" }
        else
          text -> { "#{@user_count} users (#{@elevated_count} elevated)" }
        end
      else
        text -> { "#{@user_count} users" }
      end
    end

    def system_title
      if @expanded
        html -> { render Atoms::SystemLink.new(@govt_system, expanded: true) }
      else
        text -> { @govt_system.name }
      end
    end

    def template
      return unless @system_roles.any?

      html lambda {
        <<~HTML.chomp
          <details class="collapse">
           <summary class="collapse-title p-0">
              <div class="flex flex-col space-y-0.5">
                <div>#{html -> { system_title }}#{text -> { ' (created by DOGE)' if @govt_system.doge_created }}</div>
                <div>#{render Atoms::DateRange.new(start_date: @min_date, end_date: @max_date)} <strong>#{text -> { user_count }}</strong></div>
                #{text -> { @govt_system.description }}
              </div>
           </summary>
           #{html -> { extra_section }}
          </details>
        HTML
      }
    end
  end
end
