# frozen_string_literal: true

class InternshipOfferInfo < ApplicationRecord
  MAX_CANDIDATES_PER_GROUP = 200
  TITLE_MAX_CHAR_COUNT = 150
  DESCRIPTION_MAX_CHAR_COUNT= 500
    
  # Relation
  belongs_to :sector
  belongs_to :school, optional: true # reserved to school
  belongs_to :group, optional: true
  belongs_to :internship_offer, optional: true

  has_rich_text :description_rich_text

  before_validation :replicate_rich_text_to_raw_fields
  
  # Validations
  validates :title, presence: true,
                    length: { maximum: TITLE_MAX_CHAR_COUNT }

  # Scopes 
  scope :weekly_framed, lambda {
    where(type: [InternshipOfferInfos::WeeklyFramedInfo.name,
                 InternshipOfferInfos::ApiInfo.name])
  }

  scope :free_date, lambda {
    where(type: InternshipOfferInfos::FreeDateInfo.name)
  }


  def replicate_rich_text_to_raw_fields
    self.description = description_rich_text.to_plain_text if description_rich_text.to_s.present?
  end
  
  def is_individual?
    max_candidates == 1
  end

  def from_api?
    permalink.present?
  end

  def reserved_to_school?
    school.present?
  end

  def is_fully_editable?
    true
  end

  def weekly?
    false
  end

  def free_date?
    false
  end

  def class_prefix_for_multiple_checkboxes
    'internship_offer_info'
  end

  def init
    self.max_candidates ||= 1
  end

  def self.build_from_internship_offer(internship_offer)
    info = InternshipOfferInfo.new(
      title: internship_offer.employer_name,
      description: internship_offer.description,
      max_candidates: internship_offer.max_candidates,
      school_id: internship_offer.school_id,
      employer_id: internship_offer.employer_id,
      type: "InternshipOfferInfos::#{internship_offer.type.split('::').last}Info",
      sector_id: internship_offer.sector_id,
      daily_hours: internship_offer.daily_hours,
    )
    info.weeks << internship_offer.weeks
    info
  end
end
