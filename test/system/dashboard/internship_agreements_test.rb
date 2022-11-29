require 'application_system_test_case'

module Dashboard
  class InternshipAgreementTest < ApplicationSystemTestCase
    include Devise::Test::IntegrationHelpers

    test 'employer reads internship agreement table with correct indications - draft' do
      internship_agreement = create(:internship_agreement, aasm_state: :draft)
      sign_in(internship_agreement.employer)
      visit dashboard_internship_agreements_path
      within('td[data-head="Statut"]') do
        find('div.actions', text: 'À remplir par les deux parties.')
      end
      find('a.button-component-cta-button', text: 'Remplir ma convention')
    end

    test 'employer reads internship agreement table with correct indications - status: started_by_employer' do
      internship_agreement = create(:internship_agreement, aasm_state: :started_by_employer)
      sign_in(internship_agreement.employer)
      visit dashboard_internship_agreements_path
      within('td[data-head="Statut"]') do
        find('div.actions', text: "Votre convention est remplie, mais elle n'est pas envoyée au chef d'établissement.")
      end
      find('a.button-component-cta-button', text: 'Valider ma convention')
    end

    test 'employer reads internship agreement table with correct indications - status: completed_by_employer /' do
      internship_agreement = create(:internship_agreement, aasm_state: :completed_by_employer)
      sign_in(internship_agreement.employer)
      visit dashboard_internship_agreements_path
      within('td[data-head="Statut"]') do
        find('div.actions', text: "La convention est dans les mains du chef d'établissement.")
      end
      find('a.button-component-cta-button', text: 'Vérifier ma convention')
    end

    test 'employer reads internship agreement table with correct indications - status: started_by_school_manager' do
      internship_agreement = create(:internship_agreement, aasm_state: :started_by_school_manager)
      sign_in(internship_agreement.employer)
      visit dashboard_internship_agreements_path
      within('td[data-head="Statut"]') do
        find('div.actions', text: "La convention est dans les mains du chef d'établissement.")
      end
      find('a.button-component-cta-button', text: 'Vérifier ma convention')
    end

    test 'employer reads internship agreement table with correct indications - status: validated' do
      internship_agreement = create(:internship_agreement, aasm_state: :validated)
      sign_in(internship_agreement.employer)
      visit dashboard_internship_agreements_path
      within('td[data-head="Statut"]') do
        find('div.actions', text: "Votre convention est prête. Imprimez-la et renvoyez-la signée au chef d'établissement.")
      end
      find('a.button-component-cta-button', text: 'Imprimer')
      find('button[data-action=\'group-signing#toggleFromButton\']', text: 'Ajouter aux signatures')
    end

    test 'employer reads internship agreement table with correct indications - status: signatures_started with employer' do
      internship_agreement = create(:internship_agreement, aasm_state: :signatures_started)
      create(:signature, internship_agreement: internship_agreement, signatory_role: :employer, user_id: internship_agreement.employer.id)
      sign_in(internship_agreement.employer.reload)
      visit dashboard_internship_agreements_path
      within('td[data-head="Statut"]') do
        find('.actions.d-flex', text: "Vous avez déjà signé. En attente de la signature du chef d’établissement.")
      end
      find('a.button-component-cta-button', text: 'Imprimer')
      find('a.fr-btn.button-component-cta-button', text: 'Déjà signé')
    end

    test 'employer reads internship agreement table with correct indications - status: signatures_started with school_manager' do
      internship_agreement = create(:internship_agreement, aasm_state: :signatures_started)
      create(:signature, internship_agreement: internship_agreement, signatory_role: :school_manager, user_id: internship_agreement.school_manager.id)
      sign_in(internship_agreement.employer)
      visit dashboard_internship_agreements_path
      within('td[data-head="Statut"]') do
        find('.actions.d-flex', text: "Le chef d'établissement a déjà signé. En attente de votre signature.")
      end
      find('a.button-component-cta-button', text: 'Imprimer')
      find('button[data-action=\'group-signing#toggleFromButton\']', text: 'Ajouter aux signatures')
    end

    test 'employer reads internship agreement table with correct indications - status: signed_by_all' do
      internship_agreement = create(:internship_agreement, aasm_state: :signed_by_all)
      sign_in(internship_agreement.employer)
      visit dashboard_internship_agreements_path
      within('td[data-head="Statut"]') do
        find('.actions.d-flex', text: "Signée par toutes les parties.")
      end
      find('a.button-component-cta-button', text: 'Imprimer')
      find('a.fr-btn.button-component-cta-button', text: 'Signée de tous')
    end

    # =================== School Manager ===================

    test 'school_manager reads internship agreement table with correct indications - draft' do
      internship_agreement = create(:internship_agreement, aasm_state: :draft)
      sign_in(internship_agreement.school_manager)
      visit dashboard_internship_agreements_path
      within('td[data-head="Statut"]') do
        find('div.actions', text: 'En attente de l\'offreur.')
      end
      find('a.button-component-cta-button', text: 'En attente')
    end

    test 'school_manager reads internship agreement table with correct indications - status: started_by_employer' do
      internship_agreement = create(:internship_agreement, aasm_state: :started_by_employer)
      sign_in(internship_agreement.school_manager)
      visit dashboard_internship_agreements_path
      within('td[data-head="Statut"]') do
        find('div.actions', text: 'En attente de l\'offreur.')
      end
      find('a.button-component-cta-button', text: 'En attente')
    end

    test 'school_manager reads internship agreement table with correct indications - status: completed_by_employer /' do
      internship_agreement = create(:internship_agreement, aasm_state: :completed_by_employer)
      sign_in(internship_agreement.school_manager)
      visit dashboard_internship_agreements_path
      within('td[data-head="Statut"]') do
        find('div.actions', text: "Votre convention est remplie par l'offreur, mais vous ne l'avez pas renseignée.")
      end
      find('a.button-component-cta-button', text: 'Remplir ma convention')
    end

    test 'school_manager reads internship agreement table with correct indications - status: started_by_school_manager' do
      internship_agreement = create(:internship_agreement, aasm_state: :started_by_school_manager)
      sign_in(internship_agreement.school_manager)
      visit dashboard_internship_agreements_path
      within('td[data-head="Statut"]') do
        find('div.actions', text: "Votre convention est remplie, mais pas validée.")
      end
      find('a.button-component-cta-button', text: 'Valider ma convention')
    end

    test 'school_manager reads internship agreement table with correct indications - status: validated' do
      internship_agreement = create(:internship_agreement, aasm_state: :validated)
      sign_in(internship_agreement.school_manager)
      visit dashboard_internship_agreements_path
      within('td[data-head="Statut"]') do
        find('div.actions', text: "Votre convention est prête.")
      end
      find('a.button-component-cta-button', text: 'Imprimer')
      find('button[data-action=\'group-signing#toggleFromButton\']', text: 'Ajouter aux signatures')
    end

    test 'school_manager reads internship agreement table with correct indications - status: signatures_started with employer' do
      internship_agreement = create(:internship_agreement, aasm_state: :signatures_started)
      create(:signature, internship_agreement: internship_agreement, signatory_role: :employer, user_id: internship_agreement.employer.id)
      sign_in(internship_agreement.school_manager.reload)
      visit dashboard_internship_agreements_path
      within('td[data-head="Statut"]') do
        find('.actions.d-flex', text: "L'employeur a déjà signé. En attente de votre signature.")
      end
      find('a.button-component-cta-button', text: 'Imprimer')
      find('button[data-action=\'group-signing#toggleFromButton\']', text: 'Ajouter aux signatures')
    end

    test 'school_manager reads internship agreement table with correct indications - status: signatures_started with school_manager' do
      internship_agreement = create(:internship_agreement, aasm_state: :signatures_started)
      create(:signature, internship_agreement: internship_agreement, signatory_role: :school_manager, user_id: internship_agreement.school_manager.id)
      sign_in(internship_agreement.school_manager)
      visit dashboard_internship_agreements_path
      within('td[data-head="Statut"]') do
        find('.actions.d-flex', text: "Vous avez déjà signé. En attente de la signature de l’employeur.")
      end
      find('a.button-component-cta-button', text: 'Imprimer')
      find('a.fr-btn.button-component-cta-button', text: 'Déjà signé')
    end

    test 'school_manager reads internship agreement table with correct indications - status: signed_by_all' do
      internship_agreement = create(:internship_agreement, aasm_state: :signed_by_all)
      sign_in(internship_agreement.school_manager)
      visit dashboard_internship_agreements_path
      within('td[data-head="Statut"]') do
        find('.actions.d-flex', text: "Signée par toutes les parties.")
      end
      find('a.button-component-cta-button', text: 'Imprimer')
      find('a.fr-btn.button-component-cta-button', text: 'Signée de tous')
    end
  end
end