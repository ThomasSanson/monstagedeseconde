# frozen_string_literal: true

require 'test_helper'

module InternshipApplications
  class IndexTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    def assert_has_link_count_to_transition(internship_application, transition, count)
      internship_offer = internship_application.internship_offer
      if count.positive?
        assert_select 'form[action=?]',
                      dashboard_internship_offer_internship_application_path(internship_offer,
                                                                             internship_application)
      end
      assert_select "form input[name=\"transition\"][value=\"#{transition}\"]",
                    count: count
    end

    test 'GET internship_applications#index redirects to new_user_session_path when not logged in' do
      get dashboard_internship_offer_internship_applications_path(create(:internship_offer))
      assert_redirected_to new_user_session_path
    end

    test 'GET #index redirects to root_path when logged in as student' do
      sign_in(create(:student))
      get dashboard_internship_offer_internship_applications_path(create(:internship_offer))
      assert_redirected_to root_path
    end

    test 'GET #index redirects to root_path when logged as different employer than internship_offer.employer' do
      sign_in(create(:employer))
      get dashboard_internship_offer_internship_applications_path(create(:internship_offer))
      assert_redirected_to root_path
    end

    test 'GET #index succeed when logged in as employer, shows default fields' do
      school = create(:school, city: 'Paris', name: 'Mon établissement')
      student = create(:student, school: school,
                                 phone: '+330665656565',
                                 email: 'student@edu.school',
                                 birth_date: 14.years.ago,
                                 resume_educational_background: 'resume_educational_background',
                                 resume_other: 'resume_other',
                                 resume_languages: 'resume_languages')
      internship_application = create(:internship_application, :weekly, :submitted, student: student)
      sign_in(internship_application.internship_offer.employer)
      get dashboard_internship_offer_internship_applications_path(internship_application.internship_offer)
      assert_response :success

      assert_select 'h2', "Candidature de #{internship_application.student.name} reçue le #{I18n.localize(internship_application.created_at, format: '%d %B')}"
      assert_select '.student-name', student.name
      assert_select '.school-name', school.name
      assert_select '.school-city', school.city
      assert_select '.student-age', "#{student.age} ans"
      assert_select '.student-email', student.email
      assert_select '.student-phone', student.phone
      assert_select '.reboot-trix-content', student.resume_educational_background.to_plain_text
      assert_select '.reboot-trix-content', student.resume_other.to_plain_text
      assert_select '.reboot-trix-content', student.resume_languages.to_plain_text
    end

    test 'GET #index succeed when logged in as employer, shows handicap field when present' do
      school = create(:school, city: 'Paris', name: 'Mon établissement')
      student = create(:student, school: school,
                                 handicap: 'cotorep')
      internship_application = create(:internship_application, :weekly, :submitted, student: student)
      sign_in(internship_application.internship_offer.employer)
      get dashboard_internship_offer_internship_applications_path(internship_application.internship_offer)
      assert_response :success

      assert_select '.student-handicap', student.handicap
    end

    test 'GET #index with drafted does not shows internship_application' do
      internship_application = create(:internship_application, :weekly, :drafted)
      sign_in(internship_application.internship_offer.employer)
      get dashboard_internship_offer_internship_applications_path(internship_application.internship_offer)
      assert_response :success
      assert_select "[data-test-id=internship-application-#{internship_application.id}]", count: 0
    end

    test 'GET #index with expired shows internship_application' do
      internship_application = create(:internship_application, :weekly, :expired)
      sign_in(internship_application.internship_offer.employer)
      get dashboard_internship_offer_internship_applications_path(internship_application.internship_offer)
      assert_response :success
      assert_select "[data-test-id=internship-application-#{internship_application.id}]", count: 1
    end

    test 'GET #index with submitted internship_application, shows approve/reject links' do
      internship_application = create(:internship_application, :weekly, :submitted)
      sign_in(internship_application.internship_offer.employer)
      get dashboard_internship_offer_internship_applications_path(internship_application.internship_offer)
      assert_response :success

      assert_select 'i.fas.fa-2x.fa-chevron-down', 1
      assert_select 'i.fas.fa-2x.fa-chevron-right', 0
      assert_select '.collapsible', 1
      assert_select '.collapsible.d-none', 0
      assert_select "[data-test-id=internship-application-#{internship_application.id}]", count: 1
      assert_has_link_count_to_transition(internship_application, :approve!, 1)
      assert_has_link_count_to_transition(internship_application, :reject!, 1)
      assert_has_link_count_to_transition(internship_application, :cancel_by_employer!, 0)
      assert_has_link_count_to_transition(internship_application, :signed!, 0)
    end

    test 'GET #index as Employer with approved internship_application, shows cancel_by_employer! & signed! links' do
      internship_application = create(:internship_application, :weekly, :approved)
      sign_in(internship_application.internship_offer.employer)
      get dashboard_internship_offer_internship_applications_path(internship_application.internship_offer)
      assert_response :success

      assert_select 'i.fas.fa-2x.fa-chevron-down', 0
      assert_select 'i.fas.fa-2x.fa-chevron-right', 1
      assert_select '.collapsible', 1
      assert_select '.collapsible.d-none', 1
      assert_has_link_count_to_transition(internship_application, :approve!, 0)
      assert_has_link_count_to_transition(internship_application, :reject!, 0)
      assert_has_link_count_to_transition(internship_application, :cancel_by_employer!, 1)
      assert_has_link_count_to_transition(internship_application, :signed!, 0)
    end

    test 'GET #index with rejected offer, shows approve' do
      internship_application = create(:internship_application, :weekly, :rejected)
      sign_in(internship_application.internship_offer.employer)
      get dashboard_internship_offer_internship_applications_path(internship_application.internship_offer)
      assert_response :success
      assert_has_link_count_to_transition(internship_application, :approve!, 1)
      assert_has_link_count_to_transition(internship_application, :reject!, 0)
      assert_has_link_count_to_transition(internship_application, :cancel_by_employer!, 0)
      assert_has_link_count_to_transition(internship_application, :signed!, 0)
    end

    test 'GET #index with convention_signed offer, does not shows any link' do
      internship_application = create(:internship_application, :weekly, :convention_signed)
      sign_in(internship_application.internship_offer.employer)
      get dashboard_internship_offer_internship_applications_path(internship_application.internship_offer)
      assert_response :success
      assert_has_link_count_to_transition(internship_application, :approve!, 0)
      assert_has_link_count_to_transition(internship_application, :reject!, 0)
      assert_has_link_count_to_transition(internship_application, :cancel_by_employer!, 0)
      assert_has_link_count_to_transition(internship_application, :signed!, 0)
    end
  end
end
