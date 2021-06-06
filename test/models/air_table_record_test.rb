# frozen_string_literal: true

require 'test_helper'

class AirTableRecordTest < ActiveSupport::TestCase
  test '.by_type' do
    create(:air_table_record, nb_spot_used: 10, internship_offer_type: 'A')
    create(:air_table_record, nb_spot_used: 10, internship_offer_type: 'A')
    create(:air_table_record, nb_spot_used: 10, internship_offer_type: 'B')

    result = AirTableRecord.by_type

    assert_includes(result.map(&:attributes), {"total_count"=>10, "internship_offer_type"=>"B", "id"=>nil})
    assert_includes(result.map(&:attributes), {"total_count"=>20, "internship_offer_type"=>"A", "id"=>nil})
  end

  test '.by_publicy' do
    create(:air_table_record, nb_spot_used: 10, is_public: true)
    create(:air_table_record, nb_spot_used: 10, is_public: true)
    create(:air_table_record, nb_spot_used: 10, is_public: false)

    result = AirTableRecord.by_publicy

    assert_includes(result.map(&:attributes), {"total_count"=>10, "is_public"=>false, "id"=>nil})
    assert_includes(result.map(&:attributes), {"total_count"=>20, "is_public"=>true, "id"=>nil})
  end

  test '.during_year' do
    school_years = [
      SchoolYear::Floating.new(date: Date.new(2019, 9, 14)),
      SchoolYear::Floating.new(date: Date.new(2020, 9, 14)),
      SchoolYear::Floating.new(date: Date.new(2021, 9, 14))
    ]
    school_years.map do |school_year|
      travel_to(school_year.strict_beginning_of_period) do
        week = Week.selectable_for_school_year(school_year: school_year).first
        create(:air_table_record, week_id: week.id)
      end
    end

    assert_equal 3, AirTableRecord.count
    assert_equal 1, AirTableRecord.during_year(school_year: school_years[0]).count
    assert_equal 1, AirTableRecord.during_year(school_year: school_years[1]).count
    assert_equal 1, AirTableRecord.during_year(school_year: school_years[2]).count
  end

  test '.last_modified_at' do
    last_updated_at = 2.weeks.ago
    create(:air_table_record, updated_at: 6.weeks.ago)
    create(:air_table_record, updated_at: 4.weeks.ago)
    create(:air_table_record, updated_at: last_updated_at)
    assert_equal last_updated_at, AirTableRecord.last_modified_at
  end
end
