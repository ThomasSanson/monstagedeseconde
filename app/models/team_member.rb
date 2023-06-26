class TeamMember < ApplicationRecord

  include AASM
   # Relations
  belongs_to :inviter,
             class_name: 'User'
  belongs_to :member,
             class_name: 'User',
             optional: true

  # Validations
  validates :member_id,
            uniqueness: { scope: %i[inviter_id invitation_email],
                          message: "Vous avez déjà invité ce membre dans votre équipe" },
            on: :create

  validates :invitation_email,
            presence: true,
            format: { with: Devise.email_regexp }

  # Scopes
  scope :with_pending_invitations, -> { where(invitation_refused_at: nil, member_id: nil) }
  scope :refused_invitations, -> { where.not(invitation_refused_at: nil) }

  # AASM
  aasm do
    state :pending_invitation, initial: true
    state :accepted_invitation,
          :refused_invitation

    event :accept_invitation, after: :after_accepted_invitation do
      transitions from: %i[pending_invitation],
                  to: :accepted_invitation,
                  after: proc { |*_args| send_invitation }

    end
    event :refuse_invitation do
      transitions from: :pending_invitation,
                  to: :refused_invitation,
                  after: proc { |*_args|
        update(invitation_refused_at: Time.now)
      }
    end
  end

  # instance methods

  def not_in_a_team?
    pending_invitation? || refused_invitation?
  end

  def send_invitation
    EmployerMailer.team_member_invitation_email(team_member: self, user: fetch_invitee_in_db)
                  .deliver_later(wait: 1.second)
  end

  def presenter(current_user)
    @presenter ||= ::Presenters::TeamMember.new(team_member: self, current_user: current_user)
  end

  def fetch_invitee_in_db
    Users::Employer.kept.find_by(email: invitation_email)
  end

  def member_is_inviter?
    self.member_id == self.inviter_id
  end
  alias member_is_owner? member_is_inviter?

  def reject_pending_invitations
    team = Team.new(self)
    team_member_ids = team.team_members.map(&:member_id)
    # reject my invitations to my team
    TeamMember.pending_invitation
              .where(inviter_id: member_id)
              .where(member_id: team_member_ids)
              .each do |pending_member|
                pending_member.destroy
              end  

    # refuse invitations to me

    TeamMember.pending_invitation
              .where.not(inviter_id: team_member_ids)
              .where(invitation_email: invitation_email)
              .each do |pending_member|
                pending_member.refuse_invitation!
              end
  end

  private

  def after_accepted_invitation
    Team.new(self).activate_member
  end


  def refused?
    invitation_refused_at.present?
  end

end
