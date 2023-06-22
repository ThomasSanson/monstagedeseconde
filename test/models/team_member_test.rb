require "test_helper"

class TeamMemberTest < ActiveSupport::TestCase
  test "aasm_state default" do
    team_member = TeamMember.new
    assert_equal team_member.aasm_state, "pending_invitation"
  end

  test "aasm_state accepted_invitation" do
    employer = create(:employer)
    invitee_employer = create(:employer)
    team_member = create(:team_member,
                         inviter_id: employer.id,
                         member_id: invitee_employer.id,
                         invitation_email: invitee_employer.email
    )
    assert 1, employer.team.team_size
    team_member.accept_invitation!
    assert_equal team_member.aasm_state, "accepted_invitation"
    assert 2, employer.team.team_size
    assert 2, invitee_employer.team.team_size
    assert_equal 2, TeamMember.all.count
  end

  test "no fusion between teams" do
    employer = create(:employer)
    invitee_employer = create(:employer)
    team_member = create(:team_member,
                         inviter_id: employer.id,
                         member_id: invitee_employer.id,
                         invitation_email: invitee_employer.email
    )
    team_member.accept_invitation!
    employer_2 = create(:employer)
    invitee_employer_2 = create(:employer)
    team_member = create(:team_member,
                         inviter_id: employer_2.id,
                         member_id: invitee_employer_2.id,
                         invitation_email: invitee_employer_2.email
    )
    team_member.accept_invitation!
    assert 2, employer_2.team.team_size
    assert 2, invitee_employer_2.team.team_size
    assert_equal 4, TeamMember.all.count
  end

  test 'team_members refuse invitation' do
    employer = create(:employer)
    invitee_employer = create(:employer)
    team_member = create(:team_member,
                         inviter_id: employer.id,
                         member_id: invitee_employer.id,
                         invitation_email: invitee_employer.email
    )
    team_member.refuse_invitation!
    assert 0, employer.team.team_size
    assert 1, TeamMember.refused_invitation.count
  end
end
