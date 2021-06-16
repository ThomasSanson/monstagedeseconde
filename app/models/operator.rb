# frozen_string_literal: true

class Operator < ApplicationRecord
  AIRTABLE_CREDENTIAL_MAP = {
    'Un stage et après !' => :unstageetapres,
    'Le Réseau' => :lereseau,
    'Institut Télémaque' => :telemaque,
    'Myfuture' => :myfuture,
    'Les entreprises pour la cité (LEPC)' => :lepc,
    'Tous en stage' => :tousenstage,
    'Viens voir mon taf' => :vvmt,
    'JobIRL' => :jobirl,
  }

  has_many :operators, class_name: 'Users::Operator'
  has_many :internship_offers, through: :operators

  def airtable_table
    Rails.application.credentials.dig(:air_table,
                                      :operators,
                                      AIRTABLE_CREDENTIAL_MAP.fetch(name),
                                      :table)
  end

  def airtable_app_id
    Rails.application.credentials.dig(:air_table,
                                      :operators,
                                      AIRTABLE_CREDENTIAL_MAP.fetch(name),
                                      :app_id)
  end

  rails_admin do
    list do
      field :name
      field :target_count
    end
    show do
      field :name
      field :target_count
      field :logo
      field :website
    end
    edit do
      field :name
      field :target_count
      field :logo
      field :website
    end
  end
end
