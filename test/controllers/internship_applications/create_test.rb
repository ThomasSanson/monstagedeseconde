# frozen_string_literal: true

require 'test_helper'

module InternshipApplications
  class CreateTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers
    include ActionMailer::TestHelper

    test 'POST #create internship application as student' do
      internship_offer = create(:weekly_internship_offer)
      school = create(:school, weeks: [internship_offer.weeks.first])
      student = create(:student, school: school, class_room: create(:class_room, school: school))
      sign_in(student)
      valid_params = {
        internship_application: {
          week_id: internship_offer.internship_offer_weeks.first.week.id,
          motivation: 'Je suis trop motivé wesh',
          user_id: student.id,
          internship_offer_id: internship_offer.id,
          internship_offer_type: InternshipOffer.name,
          type: InternshipApplications::WeeklyFramed.name,
          student_attributes: {
            phone: '+330656565400',
            resume_educational_background: 'resume_educational_background',
            resume_other: 'resume_other',
            resume_languages: 'resume_languages'
          }
        }
      }

      assert_difference('InternshipApplications::WeeklyFramed.count', 1) do
        post(internship_offer_internship_applications_path(internship_offer), params: valid_params)
        assert_redirected_to internship_offer_internship_application_path(
          internship_offer,
          InternshipApplications::WeeklyFramed.last
        )
      end

      created_internship_application = InternshipApplications::WeeklyFramed.last
      assert_equal internship_offer.internship_offer_weeks.first.week.id, created_internship_application.week.id
      assert_equal 'Je suis trop motivé wesh', created_internship_application.motivation.to_plain_text
      assert_equal student.id, created_internship_application.student.id

      student = student.reload
      assert_equal '+330656565400', student.phone
      assert_equal 'resume_educational_background', student.resume_educational_background.to_plain_text
      assert_equal 'resume_other', student.resume_other.to_plain_text
      assert_equal 'resume_languages', student.resume_languages.to_plain_text
    end

    test 'POST #create internship application as student to offer posted by statistician' do
      internship_offer = create(:weekly_internship_offer)
      internship_offer.update(employer_id: create(:statistician).id)
      school = create(:school, weeks: [internship_offer.weeks.first])
      student = create(:student, school: school, class_room: create(:class_room, school: school))
      sign_in(student)
      valid_params = {
        internship_application: {
          week_id: internship_offer.internship_offer_weeks.first.week.id,
          motivation: 'Je suis trop motivé wesh',
          user_id: student.id,
          internship_offer_id: internship_offer.id,
          internship_offer_type: InternshipOffer.name,
          type: InternshipApplications::WeeklyFramed.name,
          student_attributes: {
            phone: '+330656565400',
            resume_educational_background: 'resume_educational_background',
            resume_other: 'resume_other',
            resume_languages: 'resume_languages'
          }
        }
      }

      assert_difference('InternshipApplications::WeeklyFramed.count', 1) do
        post(internship_offer_internship_applications_path(internship_offer), params: valid_params)
        assert_redirected_to internship_offer_internship_application_path(
          internship_offer,
          InternshipApplications::WeeklyFramed.last
        )
      end

      created_internship_application = InternshipApplications::WeeklyFramed.last
      assert_equal internship_offer.internship_offer_weeks.first.week.id, created_internship_application.week.id
      assert_equal 'Je suis trop motivé wesh', created_internship_application.motivation.to_plain_text
      assert_equal student.id, created_internship_application.student.id

      student = student.reload
      assert_equal '+330656565400', student.phone
      assert_equal 'resume_educational_background', student.resume_educational_background.to_plain_text
      assert_equal 'resume_other', student.resume_other.to_plain_text
      assert_equal 'resume_languages', student.resume_languages.to_plain_text
    end



    test 'POST #create internship application as student without class_room' do
      internship_offer = create(:weekly_internship_offer)
      school = create(:school, weeks: [internship_offer.weeks.first])
      student = create(:student, school: school)
      sign_in(student)
      valid_params = {
        internship_application: {
          week_id: internship_offer.internship_offer_weeks.first.week.id,
          motivation: 'Je suis trop motivé wesh',
          user_id: student.id,
          internship_offer_id: internship_offer.id,
          internship_offer_type: InternshipOffer.name,
          type: InternshipApplications::WeeklyFramed.name,
          student_attributes: {
            phone: '+330656565400',
            resume_educational_background: 'resume_educational_background',
            resume_other: 'resume_other',
            resume_languages: 'resume_languages'
          }
        }
      }

      assert_difference('InternshipApplications::WeeklyFramed.count', 1) do
        post(internship_offer_internship_applications_path(internship_offer), params: valid_params)
        assert_redirected_to internship_offer_internship_application_path(
          internship_offer,
          InternshipApplications::WeeklyFramed.last
        )
      end

      created_internship_application = InternshipApplications::WeeklyFramed.last
      assert_equal internship_offer.internship_offer_weeks.first.week.id, created_internship_application.week.id
      assert_equal 'Je suis trop motivé wesh', created_internship_application.motivation.to_plain_text
      assert_equal student.id, created_internship_application.student.id

      student = student.reload
      assert_equal '+330656565400', student.phone
      assert_equal 'resume_educational_background', student.resume_educational_background.to_plain_text
      assert_equal 'resume_other', student.resume_other.to_plain_text
      assert_equal 'resume_languages', student.resume_languages.to_plain_text
    end

    # create internship application as student with class_room and check that counter are updated
    test 'POST #create internship application as student with greater max_candidates than hosting_info' do
      internship_offer = create(:weekly_internship_offer, 
        max_candidates: 3, 
        max_students_per_group: 1, 
        weeks: Week.selectable_from_now_until_end_of_school_year.first(3))
      internship_offer.hosting_info.update(max_candidates: 3, max_students_per_group: 1, weeks: Week.selectable_from_now_until_end_of_school_year.first(3))

      school = create(:school, weeks: [internship_offer.weeks.first])
      class_room = create(:class_room, school: school)
      student_1 = create(:student, school: school, class_room: class_room)
      student_2 = create(:student, school: school, class_room: class_room)
      
      a1 = create(:weekly_internship_application, 
        :approved,
        internship_offer: internship_offer,
        student: student_1,
        week: internship_offer.internship_offer_weeks.first.week
      )
      
      InternshipOfferWeek.second.destroy
      # /!\ Now only 2 weeks are available for internship_offer, for 3 max_candidates
      # Application should failed if Offer enough_weeks validation is not skipped

      sign_in(student_2)
      
      valid_params = {
        internship_application: {
          week_id: internship_offer.internship_offer_weeks.last.week.id,
          motivation: 'Je suis trop motivé wesh',
          user_id: student_2.id,
          internship_offer_id: internship_offer.id,
          internship_offer_type: InternshipOffer.name,
          type: InternshipApplications::WeeklyFramed.name,
          student_attributes: {
            phone: '+330656565400',
            resume_educational_background: 'resume_educational_background',
            resume_other: 'resume_other',
            resume_languages: 'resume_languages'
          }
        }   
      }

      assert_difference('InternshipApplications::WeeklyFramed.count', 1) do
        post(internship_offer_internship_applications_path(internship_offer), params: valid_params)
        assert_redirected_to internship_offer_internship_application_path(
          internship_offer,
          InternshipApplications::WeeklyFramed.last
        )
      end
    end
  end
end
