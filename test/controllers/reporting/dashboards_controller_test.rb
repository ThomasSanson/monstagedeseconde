# frozen_string_literal: true

require 'test_helper'

module Reporting
  class DashboardsControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers

    test 'GET #index not logged fails' do
      get reporting_dashboards_path
      assert_response 302
    end

    test 'GET #index as GOD success and has a page title' do
      god = create(:god)
      sign_in(god)
      get reporting_dashboards_path
      assert_response :success
      assert_select 'title', "Statistiques - Tableau de bord | Monstage"
    end

    test 'GET #index as statistician success ' \
         'when department params match his departement_name' do
      statistician = create(:statistician)
      zipcode = "#{statistician.department_zipcode}000"
      sign_in(statistician)
      get reporting_dashboards_path(department: statistician.department)
      assert_select "a[data-test-refresh=1][href=?]", reporting_dashboards_refresh_path
      assert_select "a[data-test-refresh=1][data-method=post]"
      assert_response :success
    end

    test 'GET #index as statistician fails ' \
         'when department params does not match his department' do
      statistician = create(:statistician)
      sign_in(statistician)
      get reporting_dashboards_path(department: 'Ain')
      assert_response 302
      assert_redirected_to root_path
    end

    test 'GET #index as operator fails' do
      user_operator = create(:user_operator)
      sign_in(user_operator)
      get reporting_dashboards_path(department: 'Ain')
      assert_response 302
      assert_redirected_to root_path
    end

    test 'GET #index as ministry statistician counts ' \
         'offers of his own administration' do
      ministry_statistician = create(:ministry_statistician)
      ministry_group = ministry_statistician.ministry
      public_group = create(:public_group)
      private_group  = create(:private_group)

      assert ministry_group.is_public,
             'ministry_statistician associated group should have been public'
      # ministry internship offer with 1
      first_offer = create(
        :weekly_internship_offer,
        group: ministry_group,
        is_public: true
      )

      # private independant internship_offer with 10
      create(
        :weekly_internship_offer,
        max_candidates: 10,
        group: nil,
        is_public: false
      )

      # private internship offer with 20
      create(
        :weekly_internship_offer,
        max_candidates: 20,
        group: private_group,
        is_public: false
      )

      sign_in(ministry_statistician)
      get reporting_dashboards_path
      assert_response 200
      assert_select ".test-administrations-proposed-offers", text: '1'
      assert_select ".test-administrations-approved-offers", text: '0'

      create(
        :last_year_weekly_internship_offer,
        max_candidates: 3,
        group: ministry_group,
        is_public: true
      )

      get reporting_dashboards_path
      assert_response 200
      assert_select ".test-administrations-proposed-offers", text: '4'
      assert_select ".test-administrations-approved-offers", text: '0'

      create(
        :weekly_internship_application,
        :approved,
        internship_offer: first_offer
      )

      # no change on older offers
      get reporting_dashboards_path(school_year: (Date.today - 1.year).year)
      assert_response 200
      assert_select ".test-administrations-proposed-offers", text: '3'
      assert_select ".test-administrations-approved-offers", text: '0'

      # public internship offer other group with 100
      create(
        :weekly_internship_offer,
        max_candidates: 100,
        group: public_group,
        is_public: true
      )

      get reporting_dashboards_path
      assert_response 200
      assert_select ".test-administrations-proposed-offers", text: '4'
      assert_select ".test-administrations-approved-offers", text: '1'
    end

    test 'POST #refresh as super admin' do
      god = create(:god)
      sign_in(god)
      airtable_syncronizer_mock = Minitest::Mock.new
      airtable_syncronizer_mock.expect(:pull_all, true)
      Airtable::BaseSynchronizer.stub :new, airtable_syncronizer_mock do
        post reporting_dashboards_refresh_path
        assert_redirected_to "#{god.custom_dashboard_path}#operator-stats"
      end
      airtable_syncronizer_mock.verify
    end
  end
end
