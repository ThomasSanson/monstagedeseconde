# frozen_string_literal: true

module InternshipOffers
  class Api < InternshipOffer
    MAX_CALLS_PER_MINUTE = 100

    validates :remote_id, presence: true

    validates :zipcode, zipcode: { country_code: :fr }
    validates :remote_id, uniqueness: { scope: :employer_id }
    validates :permalink, presence: true,
                          format: { without: /.*(test|staging).*/i, message: 'Le lien ne doit pas renvoyer vers un environnement de test.' }

    scope :uncompleted_with_max_candidates, lambda {
      where('1=1')
    }

    scope :fulfilled, lambda {
      none
    }
    #   applications_ar = InternshipApplication.arel_table
    #   offers_ar       = InternshipOffer.arel_table

    #   joins(:internship_applications)
    #     .where(applications_ar[:aasm_state].in(%w[approved signed]))
    #     .select([offers_ar[:id], applications_ar[:id].count.as('applications_count'), offers_ar[:max_candidates], offers_ar[:max_students_per_group]])
    #     .group(offers_ar[:id])
    #     .having(applications_ar[:id].count.gteq(offers_ar[:max_candidates]))
    # }

    scope :uncompleted_with_max_candidates, lambda {
      all
      # offers_ar       = InternshipOffer.arel_table
      # full_offers_ids = InternshipOffers::Api.fulfilled.ids

      # where(offers_ar[:id].not_in(full_offers_ids))
    }

    def init
      self.is_public ||= false
      super
    end

    def formatted_coordinates
      {
        latitude: coordinates.latitude,
        longitude: coordinates.longitude
      }
    end

    def reset_publish_states
      publish! if may_publish? && published_at.present?
      unpublish! if may_unpublish? && published_at.nil?
    end

    def as_json(options = {})
      super(options.merge(
        only: %i[title
                 description
                 employer_name
                 employer_description
                 employer_website
                 street
                 zipcode
                 city
                 remote_id
                 permalink
                 sector_uuid
                 max_candidates
                 published_at
                 is_public],
        methods: [:formatted_coordinates]
      ))
    end
  end
end
