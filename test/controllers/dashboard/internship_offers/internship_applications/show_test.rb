# frozen_string_literal: true

require 'test_helper'

module InternshipApplications
  class ShowTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

  

    test 'GET #show redirects to new_user_session_path when not logged in' do
      internship_application = create(:weekly_internship_application)
      get dashboard_internship_offer_internship_application_path(internship_application.internship_offer, internship_application)
      assert_redirected_to new_user_session_path
    end

    test 'GET #show redirects to new_user_session_path when token is wrong' do
      internship_application = create(:weekly_internship_application)
      get dashboard_internship_offer_internship_application_path(internship_application.internship_offer, internship_application, token: 'abc')
      assert_redirected_to root_path
    end
  end
end
