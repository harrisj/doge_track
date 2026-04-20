# frozen_string_literal: true

module Molecules
  # Summarizes a position into a block of text
  class PositionSummary < Bridgetown::Component
    def initialize(position:, agency: nil)
      super()
      @position = position
      @agency = agency
    end

    def type_str
      case @position.type
      when 'other'
        nil
      when 'detailed'
        detail_type = @position.from_truth == 'guessed' ? 'likely detailed' : 'detailed'
        if @position.from_agency && @position.agency == @agency
          html -> { "#{text -> { detail_type }} from #{render Atoms::AgencyLink.new(@position.from_agency)}" }
        elsif @position.from_agency && @position.from_agency == @agency
          html -> { "#{text -> { detail_type }} to #{render Atoms::AgencyLink.new(@position.agency)}" }
        else
          detail_type
        end
      when 'promotion'
        @position.title ? 'promoted to' : 'promoted'
      when 'demotion'
        @position.title ? 'demoted to' : 'demoted'
      when 'converted'
        'converted to permanent position'
      when 'internal'
        'internal xfer'
      when 'appointed'
        ''
      when 'unknown'
        'unknown start type'
      else
        @position.type
      end
    end

    def hire_details
      out = []

      out << '<abbr title="Special Government Employee">SGE</abbr>' if @position.sge

      if @position.nte_date
        out.append(html(lambda {
          <<~HTML.chomp
            <abbr title="not to exceed">NTE</abbr> #{render Atoms::DateLabel.new(@position.nte_date)}
          HTML
        }))
      end

      out << @position.pay_grade

      out << 'excepted' if @position.excepted

      if @position.salary
        out << if @position.salary == '$0'
                 'volunteer'
               else
                 html lambda {
                   <<~HTML.chomp
                     <span class="font-semibold my-emphasis">#{html -> { @position.salary }}</span>
                   HTML
                 }
               end
      end

      if @position.reimbursement_amount
        out.append(html(lambda {
          <<~HTML.chomp
            reimbursed <strong>#{text -> { @position.reimbursement_amount }}</strong>
          HTML
        }))
      end

      out.compact!

      return unless out.any?

      html -> { out.join(', ') }
    end
  end
end
