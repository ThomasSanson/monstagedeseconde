require 'test_helper'

module Tasks
  class SchoolIsOverArchiveTest < ActiveSupport::TestCase
    test 'Student and class_rooms are anonymized' do
      school_manager = create(:school_manager, school: create(:school))
      class_room = create(:class_room, school: school_manager.school)
      student = create(:student, school: school_manager.school)
      main_teacher = create(:main_teacher, school: school_manager.school, class_room: class_room)
      weeks = [weeks(:week_2019_1)]
      internship_offer = create(:weekly_internship_offer, weeks: weeks)
      create(:weekly_internship_application, :approved, student: student, internship_offer: internship_offer)

      refute ClassRoom.where(anonymized: false).empty?
      refute Users::SchoolManagement.where.not(class_room_id: nil).empty?

      Monstage::Application.load_tasks
      Rake::Task['school_year_is_over:archive'].invoke

      anonymized_student = Users::Student.first

      assert_nil anonymized_student.birth_date
      assert_nil anonymized_student.handicap
      assert_nil anonymized_student.resume_educational_background
      assert_nil anonymized_student.resume_other
      assert_nil anonymized_student.resume_languages
      assert_nil anonymized_student.internship_applications
                                   .first
                                   .motivation
                                   .body


      assert_equal 1, ClassRoom.where(anonymized: false).count
      assert_equal 1, ClassRoom.where(anonymized: true).count
      new_class_room = ClassRoom.find_by(anonymized: false)
      assert_equal new_class_room.attributes.except!('id', 'created_at', 'updated_at'), class_room.attributes.except!('id', 'created_at', 'updated_at')
      refute_equal new_class_room.attributes.except!('id', 'created_at', 'updated_at'), class_room.reload.attributes.except!('id', 'created_at', 'updated_at')
      assert Users::SchoolManagement.where.not(class_room_id: nil).empty?
    end
  end
end