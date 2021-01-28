# frozen_string_literal: true

require 'test_helper'

class SchoolTest < ActiveSupport::TestCase
  test 'coordinates' do
    school = School.new
    assert school.invalid?
    assert_not_empty school.errors[:coordinates]
    assert_not_empty school.errors[:zipcode]
  end

  test 'Users associations' do
    school = create(:school)

    student = create(:student, school: school)
    school_manager = create(:school_manager, school: school)
    main_teacher = create(:main_teacher, school: school)
    teacher = create(:teacher, school: school)

    assert_equal [student], school.students.all
    assert_equal [main_teacher], school.main_teachers.all
    assert_equal [teacher], school.teachers.all
    assert_equal school_manager, school.school_manager
    assert_includes school.users, student
    assert_includes school.users, main_teacher
    assert_includes school.users, teacher
    assert_includes school.users, school_manager
  end

  test 'destroy nullilfy internship_offers.shcool_id' do
    school = create(:school)
    internship_offer = create(:weekly_internship_offer, school: school)

    assert_changes -> { internship_offer.reload.school.blank? },
                   from: false,
                   to: true do
      school.destroy
    end
  end

  test 'has_staff with only manager' do
    school = create(:school, :with_school_manager)
    refute school.has_staff?
  end

  test 'has_staff with only teacher' do
    school = create(:school, :with_school_manager)
    teacher = create(:teacher, school: school)
    assert school.has_staff?
  end

  test 'has_staff with only main_teacher' do
    school = create(:school, :with_school_manager)
    main_teacher = create(:main_teacher, school: school)
    assert school.has_staff?
  end

  test 'has_staff with only other' do
    school = create(:school, :with_school_manager)
    other = create(:other, school: school)
    assert school.has_staff?
  end

  test 'has_staff with all kind of staff' do
    school = create(:school, :with_school_manager)
    main_teacher = create(:main_teacher, school: school)
    other = create(:other, school: school)
    teacher = create(:teacher, school: school)
    assert school.has_staff?
  end

  test 'counts school weeks of this current_year only' do
    travel_to(Date.new(2021, 3, 1)) do
      weeks_1   = Week.from_date_to_date(from: Date.today, to: Date.today + 7.days)

      create(:school, :with_school_manager, weeks: weeks_1.to_a)
      assert_equal 0, School.without_weeks_on_current_year.count
      create(:school, :with_school_manager, weeks: [])
      assert_equal 1, School.without_weeks_on_current_year.count

      last_year = Date.today - 1.year
      weeks_2 = Week.from_date_to_date(from: last_year, to: last_year + 7.days)
      create(:school, :with_school_manager, weeks: weeks_2.to_a)
      assert_equal 2, School.without_weeks_on_current_year.count
    end
  end
end
