# frozen_string_literal: true

require 'application_system_test_case'

class StudentFilterOffersTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers

  def assert_presence_of(internship_offer:)
    assert_selector "a[href='#{internship_offer_path(internship_offer)}']",
                    count: 1
  end

  def assert_absence_of(internship_offer:)
    assert_no_selector "a[href='#{internship_offer_path(internship_offer)}']"
  end

  test 'navigation & interaction works until employer creation' do
    school = create(:school)
    student = create(:student, school: school)
    internship_offer = create(:internship_offer)
    sign_in(student)
    InternshipOffer.stub :nearby, InternshipOffer.all do
      InternshipOffer.stub :by_weeks, InternshipOffer.all do
        visit internship_offers_path

        assert_presence_of(internship_offer: internship_offer)
      end
    end
  end

  test 'search by term, location, radius works' do
    assert false
  end
end
