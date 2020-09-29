# frozen_string_literal: true

# used in internships#index
module InternshipOffersHelper
  def duplicating?
    params[:duplicate_id].present?
  end

  def internship_offer_application_path(object)
    return object.permalink if object.from_api?
    return listable_internship_offer_path(object, anchor: 'internship-application-form')
  end

  def internship_offer_application_html_opts(object, opts)
    opts = opts.merge({title: 'Voir l\'offre en détail'})
    opts = opts.merge({title: 'Voir l\'offre en détail (nouvelle fenêtre)', target: '_blank', rel: 'external noopener noreferrer'}) if object.from_api?
    opts
  end

  def options_for_groups
    Group.all.map do |group|
      [
        group.name,
        group.id,
        {
          'data-target' => if group.is_public?
                             'organisation-form.groupNamePublic'
                           else
                             'organisation-form.groupNamePrivate'
end
        }
      ]
    end
  end

  def operator_name(internship_offer)
    internship_offer.employer.operator.name
  end

  def forwardable_params
    params.permit(
      :latitude, :longitude, :radius, :city, :keyword, :page, :filter, :school_type
    )
  end

  def back_to_internship_offers_from_internship_offer_path(current_user)
    if current_user.is_a?(Users::Employer) || current_user.is_a?(Users::Operator)
      return dashboard_internship_offers_path
    end

    default_params = {}

    internship_offers_path(default_params.merge(forwardable_params))
  end

  def listable_internship_offer_path(internship_offer, options = {})
    return '' unless internship_offer

    default_params = options.merge(id: internship_offer.id)

    internship_offer_path(default_params.merge(forwardable_params))
  end

  def internship_offer_type_options_for_default
    '-- Veuillez sélectionner un niveau scolaire --'
  end

  def tr_school_prefix
    'activerecord.attributes.internship_offer.internship_type'
  end

  def options_for_internship_type
    [
      [I18n.t("#{tr_school_prefix}.middle_school"), 'InternshipOffers::WeeklyFramed'],
      [I18n.t("#{tr_school_prefix}.high_school"), 'InternshipOffers::FreeDate']
    ]
  end

  def tr_school_type(internship_offer)
    case internship_offer.class.name
    when 'InternshipOffers::WeeklyFramed' then I18n.t("#{tr_school_prefix}.middle_school")
    when 'InternshipOffers::FreeDate' then I18n.t("#{tr_school_prefix}.high_school")
    else I18n.t("#{tr_school_prefix}.middle_school")
    end
  end

  def select_weekly_start(internship_offer)
    internship_offer.daily_hours.present? ? '--' : internship_offer.weekly_hours.try(:first) || '9:00'
  end

  def select_weekly_end(internship_offer)
    internship_offer.daily_hours.present? ? '--' : internship_offer.weekly_hours.try(:last) || '17:00'
  end

  def select_daily_start(internship_offer, day)
    internship_offer.daily_hours.present? ? internship_offer.daily_hours[day].first : '9:00'
  end

  def select_daily_end(internship_offer, day)
    internship_offer.daily_hours.present? ? internship_offer.daily_hours[day].last : '17:00'
  end
end
