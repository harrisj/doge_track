# frozen_string_literal: true

module Atoms
  # Represents open questions
  class QuestionsList < CompactList
    def render_item(question)
      <<~HTML
        <a class="link-hover tooltip" href="/questions##{text -> { question.id }} data-tip="Open question: #{text -> { question.question }}"><i class="fa-sharp fa-solid fa-circle-question"></i></a>
      HTML
    end
  end
end
