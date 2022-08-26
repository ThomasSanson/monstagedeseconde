require 'application_system_test_case'
module Dashboard::Users
  class ResendCodeTest < ApplicationSystemTestCase
    include Devise::Test::IntegrationHelpers

    test 'employer requests a new code and everything is ok' do
      internship_agreement = create(:internship_agreement, :validated)
      sign_in(internship_agreement.employer)
      visit dashboard_internship_agreements_path
      click_on 'Signer la convention'
      find('button.fr-btn.button-component-cta-button[disabled]')
      click_on 'Signer'

      find('h1#fr-modal-signature-title', text: 'Vous vous apprêtez à signer 1 convention de stage')
      find('input#phone_suffix').set('0612345678')
      click_button('Recevoir un code')

      find('h1#fr-modal-signature-title', text: 'Nous vous avons envoyé un code de vérification')
      find("button#button-code-submit.fr-btn[disabled]")
      click_link('Renvoyer le code')
      sleep 0.1
      find("#code-request", text: 'Un nouveau code a été envoyé')
    end

    test 'school_manager requests a new code and everything is ok' do
      internship_agreement = create(:internship_agreement, :validated)
      sign_in(internship_agreement.school_manager)
      visit dashboard_internship_agreements_path
      click_on 'Signer la convention'
      click_on 'Signer'

      find('h1#fr-modal-signature-title', text: 'Vous vous apprêtez à signer 1 convention de stage')
      find('input#phone_suffix').set('0612345678')
      click_button('Recevoir un code')

      find('h1#fr-modal-signature-title', text: 'Nous vous avons envoyé un code de vérification')
      find("button#button-code-submit.fr-btn[disabled]")
      click_link('Renvoyer le code')
      sleep 0.1
      find("#code-request", text: 'Un nouveau code a été envoyé')
    end

    test 'employer requests a new code and it fails for almost no reason' do
      internship_agreement = create(:internship_agreement, :validated)
      employer = internship_agreement.employer
      sign_in(employer)
      visit dashboard_internship_agreements_path
      click_on 'Signer la convention'
      click_on 'Signer'

      find('h1#fr-modal-signature-title', text: 'Vous vous apprêtez à signer 1 convention de stage')
      find('input#phone_suffix').set('0612345678')
      click_button('Recevoir un code')

      find('h1#fr-modal-signature-title', text: 'Nous vous avons envoyé un code de vérification')
      raises_exception = -> { raise ArgumentError.new('This is a test') }
      Users::Employer.stub_any_instance(:send_signature_sms_token, raises_exception) do #error
        click_link('Renvoyer le code')
        find("#code-request", text: "Une erreur est survenue et votre demande n'a pas été traitée")
      end
    end
  end
end
