# frozen_string_literal: true

require 'test_helper'

class InternshipOfferTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test 'factory is valid' do
    assert build(:weekly_internship_offer).valid?
  end

  test 'api factory is valid' do
    assert build(:api_internship_offer).valid?
  end

  test 'create enqueue SyncInternshipOfferKeywordsJob' do
    assert_enqueued_jobs 1, only: SyncInternshipOfferKeywordsJob do
      create(:weekly_internship_offer)
    end
  end

  test 'destroy enqueue SyncInternshipOfferKeywordsJob' do
    internship_offer = create(:weekly_internship_offer)

    assert_enqueued_jobs 1, only: SyncInternshipOfferKeywordsJob do
      internship_offer.destroy
    end
  end

  test 'update title enqueues SyncInternshipOfferKeywordsJob' do
    internship_offer = create(:weekly_internship_offer)

    assert_enqueued_jobs 1, only: SyncInternshipOfferKeywordsJob do
      internship_offer.update(title: 'bingo bango bang')
    end

    assert_enqueued_jobs 1, only: SyncInternshipOfferKeywordsJob do
      internship_offer.update(description_rich_text: 'bingo bango bang')
    end

    assert_enqueued_jobs 1, only: SyncInternshipOfferKeywordsJob do
      internship_offer.update(employer_description_rich_text: 'bingo bango bang')
    end

    assert_enqueued_jobs 0, only: SyncInternshipOfferKeywordsJob do
      internship_offer.update(first_date: 2.days.from_now)
    end
  end

  test 'faulty zipcode' do
    internship_offer = create(:weekly_internship_offer)
    internship_offer.update_columns(zipcode: 'xy75012')

    refute internship_offer.valid?
    assert_equal ["Code postal le code postal ne permet pas de déduire le département" ],
                 internship_offer.errors.full_messages
  end

  test 'is_favorite?' do
    student = create(:student)
    other_student = create(:student)
    internship_offer = create(:weekly_internship_offer)
    other_internship_offer = create(:weekly_internship_offer)
    refute internship_offer.is_favorite?(student)

    create(:favorite, user: student, internship_offer: internship_offer)
    create(:favorite, user: other_student, internship_offer: other_internship_offer)
    refute internship_offer.is_favorite?(other_student)
    assert internship_offer.is_favorite?(student)
  end
  
  test 'when bulking internship_offer is created, make sure area is set' do
    employer = create(:employer)
    assert_equal 1, employer.internship_offer_areas.count
    offer = build(:weekly_internship_offer, employer: employer)
    offer.internship_offer_area_id = nil
    assert offer.valid?
    assert offer.save
    assert offer.internship_offer_area_id.present?
    assert_equal employer.current_area_id, offer.internship_offer_area_id
  end

  test 'with period equals to 1' do
    internship_offer = create(:weekly_internship_offer, :week_1)
    assert_equal 1, InternshipOffer.week_1.count
    assert internship_offer.week_1?
    assert_equal 1, internship_offer.period
  end

  test 'school_year value' do
    travel_to(Date.new(2024, 7, 17)) do
      internship_offer = create(:weekly_internship_offer, :week_1)
      assert_equal 2025, internship_offer.school_year
    end
    travel_to(Date.new(2023, 10, 17)) do
      internship_offer = create(:weekly_internship_offer, :week_1)
      assert_equal 2024, internship_offer.school_year
    end
    travel_to(Date.new(2023, 3, 17)) do
      internship_offer = create(:weekly_internship_offer, :week_1)
      assert_equal 2023, internship_offer.school_year
    end
  end
end
