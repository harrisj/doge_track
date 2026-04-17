# frozen_string_literal: true

module MonthGrid
  # A representation of the start positions
  class SystemGrants < Bridgetown::Component
    def initialize(roles:)
      super()
      @roles = roles
    end

    def template
      return text -> { '' } if @roles.empty?

      @by_system_access = roles.group_by { |r| [r.govt_system, r.type] }

      html_map(@by_system_access) do |grp|
        grp[0]
        grp[1]

        <<~HTML
          <div><i class="fa-sharp fa-solid fa-display"></i></div>
          <div></div>
        HTML
      end
    end
  end
end
