require "test_helper"

class InternshipApplicationsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'GET edit_transfer not logged redirects to sign in' do
    internship_offer = create(:weekly_internship_offer)
    internship_application = create(:weekly_internship_application, internship_offer: internship_offer)
    get edit_transfer_internship_offer_internship_application_path(internship_offer, internship_application)
    assert_redirected_to user_session_path
  end

  test 'GET edit_transfer when logged in it renders the page' do
    employer = create(:employer)
    internship_offer = create(:weekly_internship_offer, employer: employer)
    internship_application = create(:weekly_internship_application, internship_offer: internship_offer)
    sign_in(employer)

    get edit_transfer_internship_offer_internship_application_path(internship_offer, internship_application)
    assert_response :success
  end

  test 'GET edit_transfer when logged in as statistician it renders the page' do
    employer = create(:statistician)
    internship_offer = create(:weekly_internship_offer, employer: employer)
    internship_application = create(:weekly_internship_application, internship_offer: internship_offer)
    sign_in(employer)

    get edit_transfer_internship_offer_internship_application_path(internship_offer, internship_application)
    assert_response :success
  end

  test 'POST transfer when logged in it sends emails to targets' do
    employer = create(:employer)
    internship_offer = create(:weekly_internship_offer, employer: employer)
    internship_application = create(:weekly_internship_application, internship_offer: internship_offer)
    sign_in(employer)

    assert_difference('ActionMailer::Base.deliveries.count', 2) do
      params = {
        comment: 'test',
        destinations: 'test@mail.com,jojo@mail.com'
      }
      post transfer_internship_offer_internship_application_path(internship_offer, internship_application), params: params
    end

    internship_application.reload

    assert_equal internship_application.aasm_state, 'examined'
    assert_equal internship_application.access_token.length, 20
  end
end
