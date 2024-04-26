class CompaniesController < ApplicationController
  layout 'search'
  DEFAULT_RADIUS_IN_KM = 10

  def index
    @companies    = []
    @level_name   = ''
    parameters = {
      latitude: search_params[:latitude].presence,
      longitude: search_params[:longitude].presence,
      radius_in_km: search_params[:radius_in_km].presence || DEFAULT_RADIUS_IN_KM
    }
    appellation_code = search_params[:appellationCode].presence

    if appellation_code.present?
      @level_name, @companies = fetch_companies_by_appellation_code(appellation_code, parameters)
    else
      @companies = fetch_companies(parameters)
    end
  end

  private

  attr_accessor :latitude, :longitude, :appellation_codes
  attr_reader :city, :keyword, :radius_in_km

  def search_params
    params.permit(:city,
                  :latitude,
                  :longitude,
                  :radius_in_km,
                  :appellationCode,
                  :keyword)
  end

  def fetch_companies(parameters)
    return [] if parameters[:latitude].blank? || parameters[:longitude].blank?

    Services::ImmersionFacile.new(**parameters).perform
  end

  def fetch_companies_by_appellation_code(appellation_code, parameters)
    @level_name = ''
    iteration = 0
    coded_craft = CodedCraft.fetch_coded_craft(appellation_code)
    while iteration < 3 && @companies.to_a.count.zero? do
      @level_name, sibling_coded_crafts = coded_craft.siblings(level: iteration)
      parameters.merge!(appellation_codes: sibling_coded_crafts.pluck(:ogr_code))
      @companies = fetch_companies(parameters)
      iteration += 1
    end
    [@level_name, @companies]
  end
end