require 'test_helper'

class InternshipOffersControllerTest < ActionDispatch::IntegrationTest
  include SessionManagerTestHelper

  test 'GET #new as employer show valid form' do
    sign_in(as: MockUser::Employer) do
      travel_to(Date.new(2019, 3, 1)) do
        get new_internship_offer_path

        assert_response :success
        assert_select 'select[name="internship_offer[week_ids][]"] option', 14
        assert_select 'option', text: 'Semaine 9 - du 25/02/19 au 03/03/19'
        assert_select 'option', text: 'Semaine 10 - du 04/03/19 au 10/03/19'
        assert_select 'option', text: 'Semaine 11 - du 11/03/19 au 17/03/19'
        assert_select 'option', text: 'Semaine 12 - du 18/03/19 au 24/03/19'
        assert_select 'option', text: 'Semaine 13 - du 25/03/19 au 31/03/19'
        assert_select 'option', text: 'Semaine 14 - du 01/04/19 au 07/04/19'
        assert_select 'option', text: 'Semaine 15 - du 08/04/19 au 14/04/19'
        assert_select 'option', text: 'Semaine 16 - du 15/04/19 au 21/04/19'
        assert_select 'option', text: 'Semaine 17 - du 22/04/19 au 28/04/19'
        assert_select 'option', text: 'Semaine 18 - du 29/04/19 au 05/05/19'
        assert_select 'option', text: 'Semaine 19 - du 06/05/19 au 12/05/19'
        assert_select 'option', text: 'Semaine 20 - du 13/05/19 au 19/05/19'
        assert_select 'option', text: 'Semaine 21 - du 20/05/19 au 26/05/19'
        assert_select 'option', text: 'Semaine 22 - du 27/05/19 au 02/06/19'
      end
    end
  end

  test 'GET #new as visitor redirects to internship_offers' do
    get new_internship_offer_path
    assert_redirected_to internship_offers_path
  end

  test 'flash presence' do
    get new_internship_offer_path
    follow_redirect!
    assert_select("#alert-danger",
                  { text: "Vous n'êtes pas autorisé à créer une annonce" },
                  'missing flash rendering')
  end

  test 'POST #create as visitor redirects to internship_offers' do
    post internship_offers_path(params: {})
    assert_redirected_to internship_offers_path
  end

  test 'POST #create as employer creates the post' do
    internship_offer = FactoryBot.create(:internship_offer)

    sign_in(as: MockUser::Employer) do
      assert_difference('InternshipOffer.count', 1) do
        params = internship_offer.attributes
                  .merge(week_ids: [weeks(:week_2019_1).id],
                         "coordinates" => {latitude: 1, longitude: 1})
        post(internship_offers_path, params: { internship_offer: params })
      end
      assert_redirected_to internship_offer_path(InternshipOffer.last)
    end
  end

  test 'POST #create as employer with missing params' do
    sign_in(as: MockUser::Employer) do
      post(internship_offers_path, params: { internship_offer: {} })
      assert_response :bad_request
    end
  end

  test 'POST #create as employer with invalid data' do
    sign_in(as: MockUser::Employer) do
      post(internship_offers_path, params: { internship_offer: {title: "hello"} })
      assert_response :bad_request
    end
  end

  test 'GET #edit as visitor redirects to internship_offers' do
    get edit_internship_offer_path(FactoryBot.create(:internship_offer).to_param)
    assert_redirected_to internship_offers_path
  end

  test 'GET #edit as employer' do
    sign_in(as: MockUser::Employer) do
      get edit_internship_offer_path(FactoryBot.create(:internship_offer).to_param)
      assert_response :success
    end
  end

  test 'PATCH #update as employer updates internship_offer' do
    internship_offer = FactoryBot.create(:internship_offer)
    new_title = 'new title'

    sign_in(as: MockUser::Employer) do
      patch(internship_offer_path(internship_offer.to_param),
            params: { internship_offer: {
                        title: new_title,
                        week_ids: [weeks(:week_2019_1).id],
                        is_public: false,
                        can_be_applied_for: false
                      }
                    })
      assert_redirected_to(internship_offer,
                         'redirection should point to updated offer')
      assert_equal(new_title,
                   internship_offer.reload.title,
                   'can\'t update internship_offer title')
    end
  end

  test 'GET #index as student. check if filters are properly populated' do
    week = Week.find_by(year: 2019, number: 10)
    create(:internship_offer, sector: "Animaux", weeks: [week])
    create(:internship_offer, sector: "Droit, Justice", weeks: [week])
    create(:internship_offer, sector: "Mode, Luxe, Industrie textile", weeks: [week])
    student = create(:student)

    sign_in(as: student) do
      travel_to(Date.new(2019, 3, 1)) do
        get internship_offers_path

        assert_response :success
        assert_select 'select#internship-offer-sector-filter option', 4
        assert_select 'option', text: "Animaux"
        assert_select 'option', text: "Droit, Justice"
        assert_select 'option', text: "Mode, Luxe, Industrie textile"
        assert_select 'option', text: "abc" # Comes from the offer created by fixture. Remove when we have fully migrated to FactoryBot
      end
    end

    # assert_no_tag tag: 'select', :child => {:tag => "option",  :content => "Medical"}
  end
end
