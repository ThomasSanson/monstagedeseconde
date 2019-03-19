require 'test_helper'

class HomeValidationTest < ActionDispatch::IntegrationTest
  include Html5Validator
  include Devise::Test::IntegrationHelpers

  test 'root_path' do
    run_request_and_cache_response(report_as: 'root_path') do
      get root_path
    end
  end

  test 'internship_offers_path' do
    run_request_and_cache_response(report_as: 'internship_offers_path') do
      get internship_offers_path
    end
  end

  test 'internship_offer_path' do
    run_request_and_cache_response(report_as: 'internship_offer_path') do
      get internship_offer_path(create(:internship_offer).to_param)
    end
  end

  test 'new_internship_offer_path'  do
    sign_in(create(:employer))
    run_request_and_cache_response(report_as: 'new_internship_offer_path') do
      get new_internship_offer_path
    end
  end

  test 'edit_internship_offer_path'  do
    stage_dev = create(:internship_offer)
    sign_in(stage_dev.employer)
    run_request_and_cache_response(report_as: 'edit_internship_offer_path') do
      get edit_internship_offer_path(id: stage_dev.to_param)
    end
  end

  test 'register as Student' do
    run_request_and_cache_response(report_as: 'new_user_registration_path_Student') do
      get new_user_registration_path(as: 'Student')
    end
  end

  test 'register as SchoolManager' do
    run_request_and_cache_response(report_as: 'new_user_registration_path_SchoolManager') do
      get new_user_registration_path(as: 'SchoolManager')
    end
  end

  test 'register as Employer' do
    run_request_and_cache_response(report_as: 'new_user_registration_path_Employer') do
      get new_user_registration_path(as: 'Employer')
    end
  end

end
