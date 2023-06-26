require 'application_system_test_case'
module Dashboard::TeamMembers
  class InvitationAndMembershipTest < ApplicationSystemTestCase
    include Devise::Test::IntegrationHelpers

    test 'team member can invite a new team member' do
      employer_1 = create(:employer)
      sign_in(employer_1)
      employer_2 = create(:employer)
      visit dashboard_internship_agreements_path
      click_link 'équipe'.capitalize
      find('a', text: "Inviter un membre de l'équipe").click
      fill_in 'team_member[invitation_email]', with: employer_2.email
      click_on 'Inviter'
      assert_text "Membre d'équipe invité avec succès"
      assert_equal 0, employer_1.team.team_size
      assert_equal 0, employer_2.team.team_size
      assert_equal 1, employer_1.team_members.count
    end

    test 'when two employers are in the same team, ' \
         'they cannot place an invitation to the same third employer' do
      employer_1 = create(:employer)
      employer_2 = create(:employer)
      employer_3 = create(:employer)
      create :team_member,
             :accepted_invitation,
             inviter_id: employer_1.id,
             member_id: employer_2.id
      create :team_member,
             :accepted_invitation,
             inviter_id: employer_1.id,
             member_id: employer_1.id

      sign_in(employer_1)
      visit dashboard_team_members_path
      click_link 'équipe'.capitalize
      find('a', text: "Inviter un membre de l'équipe").click
      fill_in 'team_member[invitation_email]', with: employer_3.email
      click_on 'Inviter'
      logout(employer_1)

      assert_equal 3, TeamMember.count
      assert_equal 1, TeamMember.with_pending_invitations.count
      pending_invitation = TeamMember.with_pending_invitations.first
      assert_equal employer_1.id, pending_invitation.inviter_id
      assert_equal employer_3.email, pending_invitation.invitation_email

      sign_in(employer_2)
      visit dashboard_team_members_path
      # TODO : trouver les badges inscrits des deux lascars
      click_link 'équipe'.capitalize
      find('a', text: "Inviter un membre de l'équipe").click
      fill_in 'team_member[invitation_email]', with: employer_3.email
      click_on 'Inviter'
      assert_text "Ce collaborateur est déjà invité"
    end

  end
end
