# frozen_string_literal: true

require 'sti_preload'
class User < ApplicationRecord

  include StiPreload
  include Discard::Model
  include UserAdmin
  include ActiveModel::Dirty
  include PhoneComputation

  has_many :favorites
  has_many :url_shrinkers

  attr_accessor :phone_prefix, :phone_suffix, :statistician_type

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable,
         :validatable, :confirmable, :trackable,
         :timeoutable, :lockable

  include DelayedDeviseEmailSender

  before_validation :concatenate_and_clean
  # after_create :send_sms_token

  # school_managements includes different roles
  # Everyone should register with ac-xxx.fr email
  # 1. should register with ce.UAI@ email
  # 2.3.4. can register without
  enum role: {
    school_manager: 'school_manager',
    teacher: 'teacher',
    main_teacher: 'main_teacher',
    cpe: 'cpe',
    admin_officer: 'admin_officer',
    other: 'other'
  }

  validates :first_name, :last_name,
            presence: true
  validates :phone, uniqueness: { allow_blank: true },
                    format: {
                      with: /\A\+(33|262|594|596|687|689)0(6|7)\d{8}\z/,
                      message: 'Veuillez modifier le numéro de téléphone mobile' },
                    allow_blank: true

  validates :email, uniqueness: { allow_blank: true },
                    format: { with: Devise.email_regexp },
                    allow_blank: true

  validate :email_or_phone
  validate :keep_email_existence, on: :update

  delegate :application, to: Rails
  delegate :routes, to: :application
  delegate :url_helpers, to: :routes

  MAX_DAILY_PHONE_RESET = 3

  scope :employers, -> { where(type: 'Users::Employer') }

  def channel ; :email end

  def default_search_options
    has_relationship?(:school) ? school.default_search_options : {}
  end

  def has_relationship?(relationship)
    respond_to?(relationship) && self.send(relationship).present?
  end


  def missing_school?
    return true if respond_to?(:school) && school.blank?
    false
  end

  def to_s
    name
  end

  def name
    "#{first_name.try(:capitalize)} #{last_name.try(:capitalize)}"
  end

  def after_sign_in_path
    custom_dashboard_path
  end

  def dashboard_name
    'Mon tableau'
  end

  def account_link_name
    'Mon profil'
  end

  def default_account_section
    'identity'
  end

  def custom_candidatures_path(_options = {})
    after_sign_in_path
  end

  def custom_dashboard_paths
    [
      custom_dashboard_path
    ]
  end

  def email_domain_name
    self.email.split('@').last
  end

  def archive
    anonymize(send_email: false)
  end

  def anonymize(send_email: true)
    #TODO
    # return if anonymized && !discarded_at.nil?
    # Remove all personal information
    email_for_job = email.dup

    rip_email = email.blank? ? nil : "#{SecureRandom.hex}@#{email_domain_name}"

    fields_to_reset = {
      email: rip_email,
      first_name: 'NA',
      last_name: 'NA',
      phone: nil,
      current_sign_in_ip: nil,
      last_sign_in_ip: nil,
      anonymized: true
    }
    update_columns(fields_to_reset)

    discard! unless discarded?

    unless email_for_job.blank?
      AnonymizeUserJob.perform_later(email: email_for_job) if send_email
    end
  end

  def destroy
    anonymize
  end

  def reset_password_by_phone
    if phone_password_reset_count < MAX_DAILY_PHONE_RESET || last_phone_password_reset < 1.day.ago
      send_sms_token
      update(phone_password_reset_count: phone_password_reset_count + 1,
             last_phone_password_reset: Time.now)
    end
  end

  def send_sms_token
    return unless phone.present? && student? && !created_by_teacher

    create_phone_token
    message = "Votre code de validation : #{self.phone_token}"
    SendSmsJob.perform_later(user: self, message: message)
  end

  def create_phone_token
    update(phone_token: format('%04d', rand(10_000)),
           phone_token_validity: 1.hour.from_now)
  end

  def phone_confirmable?
    phone_token.present? && Time.now < phone_token_validity
  end

  def confirm_by_phone!
    update(phone_token: nil,
           phone_token_validity: nil,
           confirmed_at: Time.now,
           phone_password_reset_count: 0)
  end

  def check_phone_token?(token)
    phone_confirmable? && phone_token == token
  end

  def after_confirmation
    super
  end

  def send_confirmation_instructions
    return if created_by_teacher || statistician? || student?
    super
  end

  def send_reconfirmation_instructions
    @reconfirmation_required = false
    unless @raw_confirmation_token
      generate_confirmation_token!
    end
    if add_email_to_phone_account?
      self.confirm
    else
      unless @skip_confirmation_notification || created_by_teacher || statistician?
        devise_mailer.update_email_instructions(self, @raw_confirmation_token, { to: unconfirmed_email })
                     .deliver_later
      end
    end
  end

  def canceled_targeted_offer_id
    canceled_targeted_offer_id = self.targeted_offer_id
    self.targeted_offer_id = nil
    save
    canceled_targeted_offer_id
  end

  def statistician? = false
  def department_statistician? = false
  def ministry_statistician? = false
  def academy_statistician? = false
  def academy_region_statistician? = false
  def education_statistician? = false
  def student? = false
  def employer? = false
  def operator? = false
  def school_management? = false
  def school_manager_like? = false
  def god? = false
  def employer_like? = false
  def can_sign?(internship_agreement)= false
  def email_required? = false
  def needs_to_see_modal? = false
  def has_offers_to_apply_to? = false
  def with_2_weeks_internships_approved? = false

  def fetch_current_area_notification = nil
  def create_signature_phone_token = nil
  def send_signature_sms_token = nil
  def signatory_role = nil
  def obfuscated_phone_number = nil
  def create_default_internship_offer_area = nil
  def department_name = nil

  def already_signed?(internship_agreement_id:) = true

  def team_id = id
  def team_members_ids = [id]
  def agreement_signatorable? = agreement_signatorable
  def anonymized? = self.anonymized
  def pending_invitation_to_a_team = []
  def available_offers = InternshipOffer.none
  def team_members = User.none

  def just_created?
    self.created_at < Time.now  + 3.seconds
  end

  def presenter
    Presenters::User.new(self)
  end

  def create_reset_password_token
    raw, hashed = Devise.token_generator.generate(User, :reset_password_token)
    self.reset_password_token = hashed
    self.reset_password_sent_at = Time.now.utc
    self.save
    raw
  end

  def anonymized_email
    email.gsub(/(?<=.{2}).(?=[^@]*@)/, '*')
  end

  private

  def add_email_to_phone_account?
    phone.present? && confirmed? && email.blank?
  end

  def email_or_phone
    if email.blank? && phone.blank?
      errors.add(:email, 'Un email ou un numéro de mobile sont nécessaires.')
    end
  end

  def keep_email_existence
    if email_was.present? && email.blank?
      errors.add(
        :email,
        'Il faut conserver un email valide pour assurer la continuité du service'
      )
    end
  end
end
