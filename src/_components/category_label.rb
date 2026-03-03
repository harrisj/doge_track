# frozen_string_literal: true

# Component for labeling position categories
class CategoryLabel
  def initialize(category, style = :full)
    @category = category
    @style = style
  end

  def category_icon_name
    case @category
    when 'alias'
      'fa-user-secret'
    when 'adjacent'
      'fa-megaphone'
    when 'leadership'
      'fa-briefcase'
    when 'enabler'
      'fa-door-open'
    when 'support'
      'fa-chair-office'
    when 'wrecker'
      'fa-bomb'
    when 'builder'
      'fa-laptop-code'
    when 'person'
      'fa-person'
    when 'project'
      'fa-clipboard'
    else
      'fa-circle-question'
    end
  end

  def category_icon
    "<i class=\"fa-sharp fa-solid #{category_icon_name}\"></i>"
  end

  def category_text
    @category&.titleize
  end

  def render_in(_view_context)
    case @style
    when :icon
      category_icon
    when :name
      category_text
    else
      "#{category_icon} #{category_text}"
    end
  end
end
