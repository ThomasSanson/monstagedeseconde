# frozen_string_literal: true

require 'test_helper'

class InternshipApplicationTest < ActiveSupport::TestCase
  include ThirdPartyTestHelpers
  test 'transition from draft to submit updates submitted_at and send semail to employer' do
    internship_application = create(:weekly_internship_application, :drafted)
    freeze_time do
      assert_changes -> { internship_application.reload.submitted_at },
                     from: nil,
                     to: Time.now.utc do
        mock_mail = MiniTest::Mock.new
        mock_mail.expect(:deliver_later, true)
        EmployerMailer.stub :internship_application_submitted_email, mock_mail do
          internship_application.submit!
        end
        mock_mail.verify
      end
    end
  end

  test 'transition from submited to approved send approved email to student' do
    internship_application = create(:weekly_internship_application, :submitted)

    freeze_time do
      assert_changes -> { internship_application.reload.approved_at },
                     from: nil,
                     to: Time.now.utc do
        mock_mail_to_student = MiniTest::Mock.new
        mock_mail_to_student.expect(:deliver_later, true, [{wait: 1.second}])
        StudentMailer.stub :internship_application_approved_email, mock_mail_to_student do
          internship_application.save
          internship_application.approve!
        end
        assert_nothing_raised { mock_mail_to_student.verify }
      end
    end
  end

  test 'transition from submited to approved does not send approved email to student w/o email' do
    student = create(:student, phone: '+330611223944', email: nil )
    internship_application = create(:weekly_internship_application, :submitted, student: student)

    freeze_time do
      bitly_stub do
        assert_changes -> { internship_application.reload.approved_at },
                      from: nil,
                      to: Time.now.utc do
          mock_mail_to_student = MiniTest::Mock.new
          mock_mail_to_student.expect(:deliver_later, true, [{ wait: 1.second }])
          StudentMailer.stub :internship_application_approved_email, mock_mail_to_student do
            internship_application.save
            internship_application.approve!
          end
          assert_raises(MockExpectationError) { mock_mail_to_student.verify }
        end
      end
    end
  end

  test 'transition from submited to approved send approved email to main_teacher' do
    school = create(:school)
    class_room = create(:class_room, school: school)
    student = build(:student, class_room: class_room)
    create(:school_manager, school: school)
    create(:main_teacher, class_room: class_room, school: school)
    internship_application = create(:weekly_internship_application, :submitted, student: student)

    mock_mail_to_main_teacher = MiniTest::Mock.new
    mock_mail_to_main_teacher.expect(:deliver_later, true)

    School.stub_any_instance(:internship_agreement_open?, true) do
      InternshipApplication.stub_any_instance(:accepted_student_notify, nil) do
        InternshipApplication.stub_any_instance(:create_agreement, nil) do
          MainTeacherMailer.stub(:internship_application_approved_email,
                                mock_mail_to_main_teacher) do
            internship_application.save
            internship_application.approve!
          end
          mock_mail_to_main_teacher.verify
        end
      end
    end
  end

  test 'transition from submited to approved sends no email when main_teacher misses' do
    school = create(:school)
    class_room = create(:class_room, school: school)
    student = build(:student, class_room: class_room)
    create(:school_manager, school: school)

    internship_application = create(:weekly_internship_application, :submitted, student: student)

    mock_mail_to_main_teacher = MiniTest::Mock.new
    mock_mail_to_main_teacher.expect(:deliver_later, true)

    School.stub_any_instance(:internship_agreement_open?, true) do
      InternshipApplication.stub_any_instance(:accepted_student_notify, nil) do
        InternshipApplication.stub_any_instance(:create_agreement, nil) do
          MainTeacherMailer.stub(:internship_application_approved_email,
                                mock_mail_to_main_teacher) do
            internship_application.save
            internship_application.approve!
          end
          assert_raises(MockExpectationError) { mock_mail_to_main_teacher.verify }
        end
      end
    end
  end

  test 'transition from submited to approved sends an email to school_manager when agreement is possible' do
    school = create(:school)
    class_room = create(:class_room, school: school)
    student = build(:student, class_room: class_room)
    create(:school_manager, school: school)

    internship_application = create(:weekly_internship_application, :submitted, student: student)

    mock_mail_to_school_manager = MiniTest::Mock.new
    mock_mail_to_school_manager.expect(:deliver_later, true)

    InternshipApplication.stub_any_instance(:accepted_student_notify, nil) do
      School.stub_any_instance(:internship_agreement_open?, true) do
        SchoolManagerMailer.stub(:agreement_creation_notice_email,
                                 mock_mail_to_school_manager) do
          internship_application.save
          internship_application.approve!
        end
        mock_mail_to_school_manager.verify
      end
    end
  end

  test 'transition from submited to approved sends an email to employer when agreement is possible' do
    school = create(:school)
    class_room = create(:class_room, school: school)
    student = build(:student, class_room: class_room)
    create(:school_manager, school: school)

    internship_application = create(:weekly_internship_application, :submitted, student: student)

    mock_mail_to_employer = MiniTest::Mock.new
    mock_mail_to_employer.expect(:deliver_now, true)

    InternshipApplication.stub_any_instance(:accepted_student_notify, nil) do
      School.stub_any_instance(:internship_agreement_open?, true) do
        EmployerMailer.stub(:agreement_creation_notice_email,
                                 mock_mail_to_employer) do
          internship_application.save
          internship_application.approve!
        end
        mock_mail_to_employer.verify
      end
    end
  end

  test 'transition from submited to approved sends an email to school_manager when no agreement is possible' do
    school = create(:school)
    class_room = create(:class_room, school: school)
    student = build(:student, class_room: class_room)
    create(:school_manager, school: school)

    internship_application = create(:weekly_internship_application, :submitted, student: student)

    mock_mail_to_school_manager = MiniTest::Mock.new
    mock_mail_to_school_manager.expect(:deliver_later, true)

    InternshipApplication.stub_any_instance(:accepted_student_notify, nil) do
      School.stub_any_instance(:internship_agreement_open?, false) do
        SchoolManagerMailer.stub(:internship_application_approved_email,
                                 mock_mail_to_school_manager) do
          internship_application.save
          internship_application.approve!
        end
        mock_mail_to_school_manager.verify
      end
    end
  end

  test 'transition from submited to approved sends an email to main_teacher when no agreement is possible' do
    school = create(:school)
    class_room = create(:class_room, school: school)
    student = build(:student, class_room: class_room)
    create(:school_manager, school: school)
    create(:main_teacher, class_room: class_room, school: school)

    internship_application = create(:weekly_internship_application, :submitted, student: student)

    mock_mail_to_main_teacher = MiniTest::Mock.new
    mock_mail_to_main_teacher.expect(:deliver_later, true)

    InternshipApplication.stub_any_instance(:accepted_student_notify, nil) do
      School.stub_any_instance(:internship_agreement_open?, false) do
        MainTeacherMailer.stub(:internship_application_with_no_agreement_email,
                                 mock_mail_to_main_teacher) do
          internship_application.save
          internship_application.approve!
        end
        mock_mail_to_main_teacher.verify
      end
    end
  end

  test 'transition from submited to approved create internship_agreement for student in troisieme_generale.class_room' do
    internship_offer = create(:weekly_internship_offer)
    school = create(:school, :with_school_manager, weeks: internship_offer.weeks)
    class_room = create(:class_room, :troisieme_generale, school: school)
    student = create(:student, class_room: class_room)
    internship_application = create(:weekly_internship_application, :submitted, student: student)

    assert_changes -> { InternshipAgreement.count },
                   'Expected to have created agreement',
                   from: 0,
                   to: 1 do
      internship_application.save
      internship_application.approve!
    end
  end

  test 'transition from submited to approved does not create internship_agreemennt for student in troisieme_prepa_metiers.class_room' do
    internship_offer = create(:free_date_internship_offer)
    school = create(:school, :with_school_manager)
    class_room = create(:class_room, :troisieme_prepa_metiers, school: school)
    student = create(:student, class_room: class_room)
    internship_application = create(:free_date_internship_application, :submitted, student: student)

    assert_no_changes -> { InternshipAgreement.count } do
      internship_application.save
      internship_application.approve!
    end
  end

  test 'transition from submited to approved does not create internship_agreemennt for student in troisieme_segpa.class_room' do
    internship_offer = create(:free_date_internship_offer)
    school = create(:school, :with_school_manager)
    class_room = create(:class_room, :troisieme_segpa, school: school)
    student = create(:student, class_room: class_room)
    internship_application = create(:free_date_internship_application, :submitted, student: student)

    assert_no_changes -> { InternshipAgreement.count } do
      internship_application.save
      internship_application.approve!
    end
  end


  test 'transition from submited to rejected send rejected email to student' do
    internship_application = create(:weekly_internship_application, :submitted)
    freeze_time do
      assert_changes -> { internship_application.reload.rejected_at },
                     from: nil,
                     to: Time.now.utc do
        mock_mail = MiniTest::Mock.new
        mock_mail.expect(:deliver_later, true, [{wait: 1.second}])
        StudentMailer.stub :internship_application_rejected_email, mock_mail do
          internship_application.reject!
        end
        mock_mail.verify
      end
    end
  end

  test 'transition from submited to rejected does not send email to student w/o email' do
    student = create(:student, phone: '+330611223944', email: nil )
    internship_application = create(:weekly_internship_application, :submitted, student: student)
    freeze_time do
      assert_changes -> { internship_application.reload.rejected_at },
                     from: nil,
                     to: Time.now.utc do
        mock_mail = MiniTest::Mock.new
        mock_mail.expect(:deliver_later, true, [{wait: 1.second}])
        StudentMailer.stub :internship_application_rejected_email, mock_mail do
          internship_application.reject!
        end
        assert_raises(MockExpectationError) { mock_mail.verify }
      end
    end
  end

  test 'transition from rejected to approved send approved email' do
    internship_application = create(:weekly_internship_application, :rejected)
    freeze_time do
      assert_changes -> { internship_application.reload.approved_at },
                     from: nil,
                     to: Time.now.utc do
        mock_mail = MiniTest::Mock.new
        mock_mail.expect(:deliver_later, true, [{wait: 1.second}])
        StudentMailer.stub :internship_application_approved_email, mock_mail do
          internship_application.approve!
        end
        mock_mail.verify
      end
    end
  end

  test 'transition from rejected to approved does not send email to student w/o email' do
    InternshipApplication.stub_any_instance(:short_target_url, "http://bitly/short") do
      student = create(:student, phone: '+330611223944', email: nil )
      internship_application = create(:weekly_internship_application, :rejected, student: student)
      freeze_time do
        assert_changes -> { internship_application.reload.approved_at },
                      from: nil,
                      to: Time.now.utc do
          mock_mail = MiniTest::Mock.new
          mock_mail.expect(:deliver_later, true, [{wait: 1.second}])
          StudentMailer.stub :internship_application_approved_email, mock_mail do
            internship_application.approve!
          end
          assert_raises(MockExpectationError) { mock_mail.verify }
        end
      end
    end
  end

  test 'transition via cancel_by_employer! changes ' \
       'aasm_state from approved to rejected' do
    internship_application = create(:weekly_internship_application, :approved)
    assert_changes -> { internship_application.reload.aasm_state },
                   from: 'approved',
                   to: 'canceled_by_employer' do
      freeze_time do
        assert_changes -> { internship_application.reload.canceled_at },
                       from: nil,
                       to: Time.now.utc do
          mock_mail = MiniTest::Mock.new
          mock_mail.expect(:deliver_later, true, [{wait: 1.second}])
          StudentMailer.stub :internship_application_canceled_by_employer_email,
                             mock_mail do
            internship_application.cancel_by_employer!
          end
          mock_mail.verify
        end
      end
    end
  end

  test 'transition via expire! changes aasm_state from submitted to expired' do
    internship_application = create(:weekly_internship_application, :submitted)
    assert_changes -> { internship_application.reload.aasm_state },
                   from: 'submitted',
                   to: 'expired' do
      freeze_time do
        assert_changes -> { internship_application.reload.expired_at },
                       from: nil,
                       to: Time.now.utc do
          internship_application.expire!
        end
      end
    end
  end

  test 'transition via signed! changes aasm_state from approved to rejected' do
    internship_application = create(:weekly_internship_application, :approved)
    assert_changes -> { internship_application.reload.aasm_state },
                   from: 'approved',
                   to: 'convention_signed' do
      freeze_time do
        assert_changes -> { internship_application.reload.convention_signed_at },
                       from: nil,
                       to: Time.now.utc do
          internship_application.signed!
        end
      end
    end
  end

  test 'transition via signed! cancel internship_application.student other applications on same week' do
    weeks = [weeks(:week_2019_1), weeks(:week_2019_2)]
    student = create(:student)
    internship_offer = create(:weekly_internship_offer, weeks: weeks)
    internship_offer_2 = create(:weekly_internship_offer, weeks: weeks)
    internship_application_to_be_canceled_by_employer = create(
      :weekly_internship_application, :approved,
      internship_offer: internship_offer,
      week: internship_offer.internship_offer_weeks.first.week,
      student: student
    )
    internship_application_to_be_signed = create(
      :weekly_internship_application, :approved,
      internship_offer: internship_offer_2,
      week: internship_offer_2.internship_offer_weeks.first.week,
      student: student
    )
    assert_changes -> { internship_application_to_be_canceled_by_employer.reload.aasm_state },
                   from: 'approved',
                   to: 'expired' do
      internship_application_to_be_signed.signed!
    end
  end

  test 'RGPD' do
    internship_application = create(:weekly_internship_application, motivation: 'amazing')

    internship_application.anonymize

    assert_not_equal 'amazing', internship_application.motivation
  end

  test "#accepted_student_notify when student registered by phone" do
    student = create(:student,:registered_with_phone)
    internship_application = create(:weekly_internship_application, student: student)
    InternshipApplication.stub_any_instance(:short_target_url, "http://bitly/short") do
      assert internship_application.accepted_student_notify.is_a?(SendSmsJob)
    end
  end

  test "#accepted_student_notify when student registered by email" do
    student = create(:student)
    internship_application = create(:weekly_internship_application, student: student)
    InternshipApplication.stub_any_instance(:deliver_later_with_additional_delay, 'email_sent') do
      assert_equal "email_sent", internship_application.accepted_student_notify
    end
  end
end
