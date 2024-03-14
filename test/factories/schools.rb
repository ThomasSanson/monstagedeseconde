# frozen_string_literal: true

require_relative '../support/coordinates'

FactoryBot.define do
  factory :school do
    name { 'Lycée evariste Gallois' }
    coordinates { Coordinates.paris }
    city { 'Paris' }
    zipcode { '75015' }
    code_uai { '075' + rand(100_000).to_s.rjust(5, '0') }
    department { 'Paris' }
    before(:create) do |school|
      Department.create(code: '75', name: 'Paris')
    end

    trait :at_paris do
      city { 'Paris' }
      name { 'Parisian school' }
      department { 'Paris 75015' }
      coordinates { Coordinates.paris }
    end

    trait :at_bordeaux do
      city { 'bordeaux' }
      name { 'bordeaux school' }
      department { 'Gironde' }
      coordinates { Coordinates.bordeaux }
      zipcode { '33072' }
      before(:create) do |school|
        Department.create(code: '33', name: 'Gironde')
      end
    end

    trait :with_school_manager do
      school_manager { build(:school_manager) }
    end

    trait :with_weeks do
      weeks { Week.selectable_on_school_year[0..1] }
    end
  end

  factory :api_school, class: Api::School do
    name { 'Lycée evariste Gallois' }
    city { 'Paris' }
    coordinates { Coordinates.paris }
    zipcode { '75015' }
  end
end
