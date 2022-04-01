# frozen_string_literal: true

class School < ApplicationRecord
  include Nearbyable
  include Zipcodable
  include SchoolAdmin
  include SchoolUsersAssociations

  has_many :class_rooms, dependent: :destroy
  has_many :school_internship_weeks, dependent: :destroy
  has_many :weeks, through: :school_internship_weeks
  has_many :internship_offers, dependent: :nullify
  has_many :internship_applications, through: :students
  has_many :internship_agreements, through: :internship_applications
  has_one :internship_agreement_preset

  validates :city, :name, :code_uai, presence: true

  validates :zipcode, zipcode: { country_code: :fr }

  VALID_TYPE_PARAMS = %w[rep rep_plus qpv qpv_proche].freeze

  scope :with_manager, lambda {
                         left_joins(:school_manager)
                           .group('schools.id')
                           .having('count(users.id) > 0')
                       }
  scope :without_manager, lambda {
     left_joins(:school_manager).group('schools.id')
                                .having('count(users.id) = 0')
  }

  scope :without_weeks_on_current_year, lambda {
    all.where.not(
      id: self.joins(:weeks)
              .merge(Week.selectable_on_school_year)
              .pluck(:id)
    )
  }

  scope :from_departments_with_len, lambda { |department_str_array:, string_size: |
    zip_codes_as_str = Arel::Nodes::NamedFunction.new('CAST', [Arel.sql("schools.zipcode as varchar(255)")] )
    first_chars = Arel::Nodes::NamedFunction.new('LEFT', [zip_codes_as_str, string_size] )
    where(first_chars.in(department_str_array))
  }

  scope :from_departments, lambda { |department_str_array:|
    from_departments_with_len(
      department_str_array: department_str_array, string_size: 2
    ).or(
      from_departments_with_len(
        department_str_array: department_str_array, string_size: 3
      )
    )
  }

  def presenter
    Presenters::School.new(self)
  end

  def self.experimented_school_departments
    ENV['OPEN_DEPARTEMENTS_CONVENTION'].split(',').map(&:to_str)
  end

  def default_search_options
    {
      city: city,
      latitude: coordinates.lat,
      longitude: coordinates.lon,
      radius: Nearbyable::DEFAULT_NEARBY_RADIUS_IN_METER
    }
  end

  def has_weeks_on_current_year?
    weeks.selectable_on_school_year.exists?
  end

  after_create :create_internship_agreement_preset!,
               if: lambda { |s| s.internship_agreement_preset.blank? }

  def has_staff?
    users.where("role = 'teacher' or role = 'main_teacher' or role = 'other'")
         .count
         .positive?
  end

  def to_s
    name
  end

  def email_domain_name
    Academy.get_email_domain(Academy.lookup_by_zipcode(zipcode: zipcode))
  end

  def email_domain_name
    Academy.get_email_domain(Academy.lookup_by_zipcode(zipcode: zipcode))
  end

  def internship_agreement_open?
    targeted_departments = ENV['OPEN_DEPARTEMENTS_CONVENTION'].split(',')
                                                              .map{|dept| dept.gsub(/\s+/, '') }
    (targeted_departments & [zipcode[0..2], zipcode[0..1]]).size.positive?
  end
end
