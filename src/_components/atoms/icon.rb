# frozen_string_literal: true

module Atoms
  # A simple FontAwesome icon
  class Icon < Bridgetown::Component
    def initialize(name, aria: true, label: false, width: '[18px]')
      super()
      @name = name
      @aria = aria
      @label = label
      @width = width
    end

    ICONS = {
      access: { css: 'fa-database', aria: 'System Access', text: 'Access' },
      action: { css: 'fa-hammer-crash', aria: 'Action', text: 'Action' },
      directory: { css: 'fa-people-group', aria: 'Identification', text: 'Identification' },
      disruption: { css: 'fa-explosion', aria: 'Disruption', text: 'Disruption' },
      interagency: { css: 'fa-diagram-venn', aria: 'Interagency Coordination', text: 'Interagency' },
      legal: { css: 'fa-legal', aria: 'Legal', text: 'Legal' },
      milestone: { css: 'fa-map-pin', aria: 'Milestone', text: 'Milestone' },
      official: { css: 'fa-landmark', aria: 'Official Action', text: 'Official Action' },
      agency: { css: 'fa-landmark', aria: 'Agency', text: 'Agency' },
      onboard: { css: 'fa-person-to-door', aria: 'Onboarding', text: 'Onboarding' },
      onboarding: { css: 'fa-person-to-door', aria: 'Onboarding', text: 'Onboarding' },
      appointed: { css: 'fa-person-to-door', aria: 'Appointed', text: 'Appointed' },
      oversight: { css: 'fa-microscope', aria: 'Oversight', text: 'Oversight' },
      offboard: { css: 'fa-left-from-bracket', aria: 'Offboarding', text: 'Offboarding' },
      sighting: { css: 'fa-users-viewfinder', aria: 'Sighting', text: 'Sighting' },
      website: { css: 'fa-browser', aria: 'Website', text: 'Website' },
      report: { css: 'fa-newspaper', aria: 'Report', text: 'Report' },

      alias: { css: 'fa-user-secret', aria: 'Alias', text: 'Alias' },
      adjacent: { css: 'fa-megaphone', aria: 'DOGE Adjacent', text: 'DOGE Adjacent' },
      leadership: { css: 'fa-leadership', aria: 'DOGE Leadership', text: 'Leadership' },
      enabler: { css: 'fa-door-open', aria: 'Enabler', text: 'Enabler' },
      support: { css: 'fa-chair-office', aria: 'Support Team', text: 'Support Team' },
      wrecker: { css: 'fa-bomb', aria: 'Wrecker', text: 'Wrecker' },
      builder: { css: 'fa-laptop-code', aria: 'Builder', text: 'Builder' },
      person: { css: 'fa-person', aria: 'Person', text: 'Person' },

      exec_order: { css: 'fa-file-contract', aria: 'Executive Order', text: 'Executive Order' },

      external_link: { css: 'fa-up-right-from-square', aria: 'External Link', text: 'External Link' },
      internal_transfer: { css: 'fa-arrows-left-right', aria: 'Internal Transfer', text: 'Internal' },
      detailed: { css: 'fa-arrow-right', aria: 'Detailed To', text: 'Detailed To' },
      detailed_left: { css: 'fa-arrow-left', aria: 'Detailed From', text: 'Detailed From' },
      promotion: { css: 'fa-arrow-up', aria: 'Promotion', text: 'Promotion' },
      demotion: { css: 'fa-arrow-down', aria: 'Demotion', text: 'Demotion' },
      converted: { css: 'fa-person-shelter', aria: 'Converted to Permanent Position', text: 'Converted' },

      project: { css: 'fa-clipboard', aria: 'DOGE Project', text: 'Project' },
      question: { css: 'fa-question', aria: 'Question', text: 'Question' },
      fuzz: { css: 'fa-question', aria: 'Fuzziness', text: 'Fuzziness' },
      source: { css: 'fa-receipt', aria: 'Source', text: 'Source' },
      table_note: { css: 'fa-asterisk', aria: 'Note', text: 'Note' },
      salary: { css: 'fa-dollar-sign', aria: 'Salary', text: 'Salary' },
      job_title: { css: 'fa-map-pin', aria: 'Position Title', text: 'Title' },
      system_grant: { css: 'fa-display', area: 'Access Grant', text: 'Access Grant' },
      system_revoke: { css: 'fa-display-slash', aria: 'Access Revoked', text: 'Access Revoked' },

      info: { css: 'fa-circle-info', aria: 'Information', text: 'Information' }
    }.freeze

    def icon_css
      return @name if @name =~ /^fa-/

      rec = ICONS[@name.to_sym]
      rec ? rec[:css] : 'fa-circle-question'
    end

    def aria
      return nil unless @aria

      @aria_cached ||= if @aria.is_a?(String)
                         @aria
                       elsif (rec = ICONS[@name.to_sym])
                         rec[:aria]
                       end

      @aria_cached
    end

    def icon_label
      return nil unless @label

      unless @label_cached
        rec = ICONS[@name.to_sym]

        @label_cached = if rec
                          rec[:text]
                        elsif @label.is_a?(String)
                          @label
                        end
      end

      @label_cached
    end

    def aria_attr
      return unless aria

      html -> { " title=\"#{text -> { aria }}\"" }
    end

    def template
      html lambda {
        <<~HTML.rstrip
          <i class="inline-block size-5 mx-auto fa-sharp fa-solid #{text -> { icon_css }}" aria-hidden="true"#{html -> { aria_attr }}></i><span class="sr-only">#{text -> { aria }}: </span>
        HTML
      }
    end
  end
end
