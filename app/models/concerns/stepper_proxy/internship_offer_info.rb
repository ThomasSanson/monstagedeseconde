# frozen_string_literal: true

module StepperProxy
  module InternshipOfferInfo
    extend ActiveSupport::Concern

    included do
      after_initialize :init

      enum school_track: {
        troisieme_generale: 'troisieme_generale',
        troisieme_prepa_metier: 'troisieme_prepa_metier',
        troisieme_segpa: 'troisieme_segpa',
        bac_pro: 'bac_pro'
      }

      # Validations
      validates :title, presence: true, length: { maximum: InternshipOffer::TITLE_MAX_CHAR_COUNT }
      validates :school_track, presence: true
      validates :max_candidates, numericality: { only_integer: true,
                                                 greater_than: 0,
                                                 less_than_or_equal_to: InternshipOffer::MAX_CANDIDATES_PER_GROUP }

      # Relations
      belongs_to :school, optional: true # reserved to school
      belongs_to :sector

      has_rich_text :description_rich_text

      def is_individual?
        max_candidates == 1
      end

       def init
        self.max_candidates ||= 1
      end
    end
  end
end
