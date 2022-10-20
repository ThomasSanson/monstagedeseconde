require 'test_helper'

module Admin
  class AdminControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    test 'redirects to root path for all profile' do
      school = create(:school)
      school_manager = create(:school_manager, school: school)
      roles = [create(:employer),
               create(:main_teacher, school: school),
               create(:user_operator),
               create(:other, school: school),
               create(:statistician),
               create(:student),
               create(:teacher, school: school)]
      roles.each do |role|
        sign_in(role)
        get rails_admin_path
        assert_redirected_to Rails.application.routes.url_helpers.root_path
      end
    end

    test 'allows god to access admin_path' do
      god = create(:god)
      sign_in(god)
      get rails_admin_path
      assert_response :success
    end

    test 'allows to add dasen to whitelist' do
      white_list = EmailWhitelists::EducationStatistician.new(email: 'Patrice.Minet@France-Culture.fr' , zipcode: 75)
      white_list.save

      assert_equal 'patrice.minet@france-culture.fr', white_list.reload.email
      assert_equal "EmailWhitelists::EducationStatistician", white_list.type
    end
  end
end
