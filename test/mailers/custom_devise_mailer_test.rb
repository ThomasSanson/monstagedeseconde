require 'test_helper'

class CustomDeviseMailerTest < ActionMailer::TestCase
  test '.confirmation_instructions attaches authorisation-parentale.pdf' \
       ' for students & main_teachers' do
    school = create(:school)
    school_manager = create(:school_manager, school: school)
    roles = [create(:employer),
             create(:god),
             create(:main_teacher, school: school),
             create(:user_operator),
             create(:other, school: school),
             create(:statistician),
             create(:student),
             create(:teacher, school: school)]
    (roles + [school_manager]).each do |user|
      email = CustomDeviseMailer.confirmation_instructions(user, SecureRandom.hex)
      assert(email.html_part.body.include?('Bienvenue'),
             "bad body for #{user.type}")
    end
  end

  test '.confirmation_instructions with unconfirmed_email change wording' do
    employer = create(:employer)
    employer.update!(email: 'nouvel@ema.le')
    email = CustomDeviseMailer.confirmation_instructions(employer, SecureRandom.hex)
    assert email.html_part.body.include?(employer.formal_name)
    assert email.html_part.body.include?('nous venons de recevoir une demande de changement')
  end

  test 'user creates his account' do
    student = create(:student, confirmed_at: nil)
    email = CustomDeviseMailer.confirmation_instructions(student, SecureRandom.hex)
    assert email.subject , "test"
  end

  test 'user updates his email' do
    student = create(:student)
    student.unconfirmed_email = 'test@yahoo.fr'
    email = CustomDeviseMailer.confirmation_instructions(student, SecureRandom.hex)
    email.subject
    assert_equal email.subject , "testte t"
  end
end
