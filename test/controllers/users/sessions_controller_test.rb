# frozen_string_literal: true

require 'test_helper'

class SessionsControllerTest < ActionDispatch::IntegrationTest

  test 'GET works' do
    get new_user_session_path
    assert_response :success
    assert_select "#user_email"
    assert_select "#channel-phone"
    assert_select "#user_password[autofocus=autofocus]", count: 0
  end

  test 'GET with prefilled email works' do
    email = 'fourcade.m@gmail.com'
    get new_user_session_path(email: email)
    assert_response :success
    assert_select "#user_email[autofocus=autofocus]", count: 0
    assert_select "#user_email[value=\"#{email}\"]"
    assert_select "#user_password[autofocus=autofocus]"
  end

  test 'POST session not confirmed render warning with icon' do
    pwd = 'okokok'
    student = create(:student, password: pwd, confirmed_at: nil)
    post user_session_path(params: { user: { email: student.email, password: pwd } })
    assert_response :found
    follow_redirect!
    assert_select "#alert-warning #alert-text", text: 'Un message d’activation vous a été envoyé par courrier électronique. Veuillez suivre les instructions qu’il contient.'
  end
end
