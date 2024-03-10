# frozen_string_literal: true

module ApplicationHelper
  def env_class_name
    return 'development' if Rails.env.development?
    return 'review' if Rails.env.staging? || Rails.env.review?
    return 'staging' if request.host.include?('recette')

    ''
  end

  def helpdesk_url
    'https://zammad.incubateur.anct.gouv.fr/help/fr-fr/3-professionnels'
  end

  def custom_dashboard_controller?(user:)
    user.custom_dashboard_paths
        .map { |path| current_page?(path) }
        .any?
  end

  def account_controller?(user:)
    [
      current_page?(account_path),
      current_page?(account_path(section: :resume)),
      current_page?(account_path(section: :api)),
      current_page?(account_path(section: :identity)),
      current_page?(account_path(section: :school))
    ].any?
  end

  def onboarding_flow?
    devise_controller? && request.path.include?('identity_id')
  end

  def body_class_name
    class_names = []
    class_names.push('homepage fr-px-0') if homepage?
    class_names.push('onboarding-flow') if onboarding_flow?
    class_names.join(' ')
  end

  def homepage?
    current_page?(root_path)
  end

  # def in_dashboard?
  #   request.path.include?('dashboard') || request.path.include?('tableau-de-bord')
  # end

  def statistics?
    controller.class.name.deconstantize == 'Reporting'
  end

  def current_controller?(controller_name)
    controller.controller_name.to_s == controller_name.to_s
  end


  def page_title
    if content_for?(:page_title)
      content_for :page_title
    else
      default = 'Stages de 2de'
      i18n_key = "#{controller_path.tr('/', '.')}.#{action_name}.page_title"
      dyn_page_name = t(i18n_key, default: default)
      dyn_page_name == default ? default : "#{dyn_page_name} | #{default}"
    end
  end

  def regions_list
    [
      { name: "Auvergne" ,
        url: "https://www.auvergnerhonealpes.fr/ ",
        logo: "auvergne.png",
        alt: "logo de la région Auvergne"},
      { name: "Bourgogne" ,
        url: "https://www.bourgognefranchecomte.fr/",
        logo: "bourgogne.png",
        alt: "logo de la région bourgogne"},
      { name: "Bretagne" ,
        url: "https://www.bretagne.bzh/",
        logo: "bretagne.png",
        alt: "logo de la région bretagne"},
      { name: "Centre Val de Loire " ,
        url: "https://www.centre-valdeloire.fr/",
        logo: "centrevaldeloire.png",
        alt: "logo de la région Centre Val de Loire"},
      { name: "Corse" ,
        url: "https://www.isula.corsica/",
        logo: "corse.png",
        alt: "logo de la région Corse"},
      { name: "Grand Est " ,
        url: "https://www.grandest.fr/",
        logo: "grandest.png",
        alt: "logo de la région Grand Est"},
      { name: "Guadeloupe" ,
        url: "https://www.regionguadeloupe.fr/accueil/#_",
        logo: "guadeloupe.png",
        alt: "logo de la région Guadeloupe"},
      { name: "Guyane" ,
        url: "https://www.ctguyane.fr/",
        logo: "guyane.png",
        alt: "logo de la région Guyane"},
      { name: "Hauts de France" ,
        url: "https://www.hautsdefrance.fr/",
        logo: "hautsdefrance.png",
        alt: "logo de la région Hauts de France"},
      { name: "Ile de France" ,
        url: "https://www.iledefrance.fr/",
        logo: "iledefrance.png",
        alt: "logo de la région Ile de France"},
      { name: "Martinique" ,
        url: "https://www.collectivitedemartinique.mq/",
        logo: "martinique.png",
        alt: "logo de la région Martinique"},
      { name: "Mayotte" ,
        url: "https://www.mayotte.fr/",
        logo: "mayotte.png",
        alt: "logo de la région Mayotte"},
      { name: "Normandie" ,
        url: "https://www.normandie.fr/",
        logo: "normandie.png",
        alt: "logo de la région Normandie"},
      { name: "Nouvelle Aquitaine" ,
        url: "https://www.nouvelle-aquitaine.fr/",
        logo: "nouvelleaquitaine.png",
        alt: "logo de la région Nouvelle Aquitaine"},
      { name: "Occitanie" ,
        url: "https://www.laregion.fr/",
        logo: "occitanie.png",
        alt: "logo de la région Occitanie"},
      { name: "Pays de la Loire" ,
        url: "https://www.paysdelaloire.fr/",
        logo: "paysdeloire.png",
        alt: "logo de la région Pays de la Loire"},
      { name: "PACA" ,
        url: "https://www.maregionsud.fr/",
        logo: "paca.png",
        alt: "logo de la région Provence,
        Alpes Coté d'Azur"},
      { name: "La Réunion " ,
        url: "https://regionreunion.com/",
        logo: "reunion.png",
        alt: "logo de la région La Réunion"},
    ]
  end

  def involved_partners_logos
    [
      { logo_img: "airbus.png", alt: "airbus logo" },
      { logo_img: "bnp.png", alt: "bnp logo" },
      { logo_img: "bouygues.png", alt: "bouygues logo" },
      { logo_img: "bpce.png", alt: "bpce logo" },
      { logo_img: "carrefour.png", alt: "carrefour logo" },
      { logo_img: "creditmutuel.png", alt: "creditmutuel logo" },
      { logo_img: "decathlon.png", alt: "decathlon logo" },
      { logo_img: "disneyland.png", alt: "disneyland logo" },
      { logo_img: "intermarche.png", alt: "intermarche logo" },
      { logo_img: "laposte.png", alt: "laposte logo" },
      { logo_img: "loreal.png", alt: "loreal logo" },
      { logo_img: "safran.png", alt: "safran logo" }
    ]
  end
end
