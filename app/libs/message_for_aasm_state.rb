# frozen_string_literal: true

class MessageForAasmState
  # for html formatted default message
  delegate :student,
           :internship_offer,
           :week,
           to: :internship_application
  # "exposed" attributes
  delegate :approved_message,
           :rejected_message,
           :canceled_by_employer_message,
           :canceled_by_student_message,
           to: :internship_application

  MAP_TARGET_TO_BUTTON_COLOR = {
    approve!: 'danger',
    cancel_by_employer!: 'outline-danger',
    cancel_by_student!: 'outline-danger',
    reject!: 'outline-danger'
  }.freeze

  def target_action_color
    MAP_TARGET_TO_BUTTON_COLOR.fetch(aasm_target)
  end

  #
  # depending on target aasm_state, user edit custom message but
  # action_text default is a bit tricky to initialize
  # so depending on the targeted state, fetch the rich_text_object (void)
  # and assign the body [which show on front end the text]
  #
  MAP_TARGET_TO_RICH_TEXT_ATTRIBUTE = {
    approve!: :approved_message,
    cancel_by_employer!: :canceled_by_employer_message,
    cancel_by_student!: :canceled_by_student_message,
    reject!: :rejected_message
  }.freeze

  MAP_TARGET_TO_RICH_TEXT_INITIALIZER = {
    approve!: :on_approved_message,
    cancel_by_employer!: :on_canceled_by_employer_message,
    cancel_by_student!: :on_canceled_by_student_message,
    reject!: :on_rejected_message
  }.freeze

  def assigned_rich_text_attribute
    rich_text_object = MAP_TARGET_TO_RICH_TEXT_ATTRIBUTE.fetch(aasm_target)
    rich_text_initializer = MAP_TARGET_TO_RICH_TEXT_INITIALIZER.fetch(aasm_target)

    send(rich_text_object).body = send(rich_text_initializer)

    rich_text_object
  end

  private

  attr_reader :aasm_target, :internship_application
  def initialize(internship_application:, aasm_target:)
    @internship_application = internship_application
    @aasm_target = aasm_target
  end

  def on_approved_message
    <<~HTML.strip
      <p>Bonjour #{Presenters::User.new(student).formal_name},</p>
      <p>Votre candidature pour le stage "#{internship_offer.title}" est acceptée pour la semaine #{week.short_select_text_method}.</p>
      <p>Vous devez maintenant faire signer la convention de stage.</p>
    HTML
  end

  def on_rejected_message
    <<~HTML.strip
      <p>Bonjour #{Presenters::User.new(student).formal_name},</p>
      <p>Votre candidature pour le stage "#{internship_offer.title}" est refusée pour la semaine #{week.short_select_text_method}.</p>
    HTML
  end

  def on_canceled_by_employer_message
    <<~HTML.strip
      <p>Bonjour #{Presenters::User.new(student).formal_name},</p>
      <p>Votre candidature pour le stage "#{internship_offer.title}" est annulée pour la semaine #{week.short_select_text_method}.</p>
    HTML
  end

  def on_canceled_by_student_message
    <<~HTML.strip
      <p>#{internship_offer.employer.formal_name},</p>
      <p>Je ne suis pas en mesure d'accepter votre offre de stage
      "#{internship_offer.title}" prévu pour la semaine
      #{week.short_select_text_method}, car : </p>
    HTML
  end
end
