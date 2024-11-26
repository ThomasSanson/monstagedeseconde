# frozen_string_literal: true

require 'test_helper'

class StudentRegistrationsTest < ActionDispatch::IntegrationTest
  test 'GET new as Student renders expected inputs' do
    school = create(:school)
    class_room = create(:class_room, school:)

    get new_identity_path
    assert_response :success
    assert_select 'input', value: 'Student', hidden: 'hidden'
    assert_select 'title', 'Inscription élève - etape 1 sur 2 | 1élève1stage'
    # jsx componentes do not show labels with the usual way
    assert_select 'label', /Nom/
    assert_select 'label', /Prénom/
    assert_select 'label', /Date de naissance/
    assert_select 'label', /Sexe/
  end

  test 'POST Create Student without class fails' do
    assert_difference('Users::Student.count', 0) do
      post user_registration_path(params: {
                                    user: { email: 'fatou@snapchat.com',
                                            password: 'okokok',
                                            first_name: 'Fatou',
                                            last_name: 'D',
                                            type: 'Users::Student',
                                            accept_terms: '1' }
                                  })
      assert_response 200
    end
  end

  test 'POST create Student with class responds with success' do
    skip 'this test is relevant and shall be reactivated by november 2024'
    school = create(:school, school_type: :college)
    class_room = create(:class_room, school:)
    birth_date = 14.years.ago
    email = 'fourcade.m@gmail.com'
    assert_enqueued_jobs 3 do
      assert_enqueued_emails 2 do
        assert_difference('Users::Student.count') do
          post user_registration_path(
            params: {
              user: {
                type: 'Users::Student',
                school_id: school.id,
                class_room_id: class_room.id,
                first_name: 'Martin',
                last_name: 'Fourcade',
                birth_date:,
                gender: 'np',
                email: 'fourcade.m@gmail.com',
                grade: 'troisieme',
                password: 'okokok1Max!!',
                accept_terms: '1',
                grade: Grade.troisieme
              }
            }
          )
        end
        assert_redirected_to users_registrations_standby_path(id: Users::Student.last.id)
      end
    end
    created_student = Users::Student.first
    assert_equal school, created_student.school
    assert_equal class_room, created_student.class_room
    assert_equal 'Martin', created_student.first_name
    assert_equal 'Fourcade', created_student.last_name
    assert_equal birth_date.year, created_student.birth_date.year
    assert_equal birth_date.month, created_student.birth_date.month
    assert_equal birth_date.day, created_student.birth_date.day
    assert_equal 'np', created_student.gender
    assert_equal 'fourcade.m@gmail.com', created_student.email
  end

  test 'sentry#1885447470, registration with no js/html5 fails gracefully' do
    birth_date = 14.years.ago
    assert_difference('Users::Student.count', 0) do
      post user_registration_path(
        params: {
          user: {
            accept_terms: 1,
            birth_date:,
            channel: 'phone',
            email: '', # no email
            first_name: 'Jephthina',
            gender: 'f',
            last_name: 'Théodore ',
            password: '[Filtered]',
            type: Users::Student.name
          }
        }
      )
      assert_response 200
    end
  end

  test 'reusing the same phone number while registrating leads to new sessions page' do
    phone = '+330611223344'
    create(:student, email: nil, phone:)

    birth_date = 14.years.ago
    assert_difference('Users::Student.count', 0) do
      post user_registration_path(
        params: {
          user: {
            accept_terms: 1,
            birth_date:,
            phone:,
            channel: 'phone',
            email: '',
            first_name: 'Jephthina',
            gender: 'f',
            last_name: 'Théodore ',
            password: '[Filtered]',
            type: Users::Student.name
          }
        }
      )
      assert_redirected_to new_user_session_path(phone:)
    end
  end

  test 'POST create Student with entity responds with success' do
    skip 'this test is relevant and shall be reactivated by november 2024'
    identity = create(:identity_student_with_class_room_3e)
    email = 'ines@gmail.com'
    assert_difference('Users::Student.count') do
      post user_registration_path(
        params: {
          user: {
            type: 'Users::Student',
            identity_token: identity.token,
            email:,
            password: 'okokok1Max!!',
            accept_terms: '1'
          }
        }
      )
      assert_redirected_to users_registrations_standby_path(id: Users::Student.last.id)
    end
    created_student = Users::Student.first
    assert_equal identity.school_id, created_student.school.id
    assert_equal identity.class_room_id, created_student.class_room.id
    assert_equal identity.first_name, created_student.first_name
    assert_equal identity.last_name, created_student.last_name
    assert_equal identity.birth_date.year, created_student.birth_date.year
    assert_equal identity.birth_date.month, created_student.birth_date.month
    assert_equal identity.birth_date.day, created_student.birth_date.day
    assert_equal identity.gender, created_student.gender
    assert_equal email, created_student.email
  end

  test 'POST create Student w/o entity fails' do
    email = 'ines@gmail.com'
    assert_difference('Users::Student.count', 0) do
      post user_registration_path(
        params: {
          user: {
            type: 'Users::Student',
            email:,
            password: 'okokok1Max!!',
            accept_terms: '1'
          }
        }
      )
    end
  end
end
