# frozen_string_literal: true

# Component for showing a label for events
class EventLabel
  def initialize(event_type, style = :full)
    @event_type = event_type
    @style = style
  end

  def event_icon_name
    case @event_type
    when 'access'
      'fa-database'
    when 'action'
      'fa-hammer-crash'
    when 'directory'
      'fa-people-group'
    when 'disruption'
      'fa-explosion'
    when 'interagency'
      'fa-diagram-venn'
    when 'legal'
      'fa-legal'
    when 'milestone'
      'fa-map-pin'
    when 'official'
      'fa-landmark'
    when 'onboard'
      'fa-person-to-door'
    when 'oversight'
      'fa-microscope'
    when 'offboard'
      'fa-left-from-bracket'
    when 'sighting'
      'fa-users-viewfinder'
    when 'website'
      'fa-browser'
    else
      'fa-newspaper'
    end
  end

  def event_icon
    "<i class=\"fa-sharp fa-solid #{event_icon_name}\"></i>"
  end

  def event_title
    case @event_type
    when 'access'
      'Access'
    when 'action'
      'Action'
    when 'directory'
      'Directory'
    when 'disruption'
      'Disruption'
    when 'interagency'
      'Interagency'
    when 'legal'
      'Legal'
    when 'milestone'
      'Milestone'
    when 'official'
      'Official'
    when 'onboard'
      'Onboard'
    when 'oversight'
      'Oversight'
    when 'offboard'
      'Offboard'
    when 'sighting'
      'Sighting'
    when 'website'
      'Website'
    else
      'Report'
    end
  end

  def render_in(_view_context)
    case @style
    when :icon
      event_icon
    when :text
      event_title
    when :responsive
      "#{event_icon}  <span class=\"hidden md:inline font-bold\">{#{event_title}</span>"
    else
      "#{event_icon} #{event_title}"
    end
  end
end
