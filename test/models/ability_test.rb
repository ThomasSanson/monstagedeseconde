# frozen_string_literal: true

require 'test_helper'

class AbilityTest < ActiveSupport::TestCase
  test 'Visitor' do
    ability = Ability.new
    assert(ability.can?(:read, InternshipOffer.new),
           'visitors should be able to consult internships')
    assert(ability.cannot?(:manage, InternshipOffer.new),
           'visitors should not be able to con manage internships')
  end

  test 'Student' do
    internship_offer = create(:weekly_internship_offer)
    school = create(:school, weeks: [internship_offer.weeks.first])
    student = create(:student, class_room: create(:class_room, :troisieme_generale, school: school))
    ability = Ability.new(student)
    internship_application = create(:weekly_internship_application,
                                    student: student,
                                    internship_offer: internship_offer,
                                    internship_offer_week: internship_offer.internship_offer_weeks.first)
    assert(ability.can?(:read, InternshipOffer.new),
           'students should be able to consult internship offers')
    assert(ability.can?(:apply, internship_offer),
           'students should be able to apply for internship offers')
    assert(ability.cannot?(:manage, InternshipOffer.new),
                           'students should not be able to con manage internships')
    assert(ability.can?(:show, :account),
           'students should be able to access their account')
    assert(ability.can?(:choose_school, student),
           'student should be able to choose_school')
    assert(ability.can?(:choose_class_room, student),
           'student should be able to choose_class_room')
    assert(ability.can?(:choose_gender_and_birthday, student),
           'student should be able to choose_gender_and_birthday')
    assert(ability.can?(:choose_handicap, student),
           'student should be able to choose handicap')
    assert(ability.can?(:dashboard_index, student))
    assert(ability.can?(:dashboard_show, internship_application))
    assert(ability.cannot?(:dashboard_show, create(:weekly_internship_application)))
    assert(ability.cannot?(:index, Acl::InternshipOfferDashboard.new(user: student)),
           'employers should be able to index InternshipOfferDashboard')
  end

  test 'Employer' do
    employer = create(:employer)
    ability = Ability.new(employer)
    assert(ability.can?(:create, InternshipOffer.new),
           'employers should be able to create internships')
    assert(ability.cannot?(:update, InternshipOffer.new),
           'employers should not be able to update internship offer not belonging to him')
    assert(ability.can?(:update, InternshipOffer.new(employer: employer)),
           'employers should be able to update internships offer that belongs to him')
    assert(ability.cannot?(:discard, InternshipOffer.new),
           'employers should be able to discard internships offer not belonging to him')
    assert(ability.can?(:discard, InternshipOffer.new(employer: employer)),
           'employers should be able to discard internships offer that belongs to him')
    assert(ability.can?(:index, Acl::InternshipOfferDashboard.new(user: employer)),
           'employers should be able to index InternshipOfferDashboard')
  end

  test 'God' do
    god = build(:god)
    ability = Ability.new(god)
    assert(ability.can?(:show, :account),
           'god should be able to see his account')
    assert(ability.can?(:update, School),
           'god should be able to manage school')
    assert(ability.can?(:edit, User),
           'god should be able to edit user')
    assert(ability.can?(:see_tutor, InternshipOffer),
           'god should be able see see_tutor')
    assert ability.can?(:read, User)
    assert ability.can?(:destroy, User)
    assert ability.can?(:index_and_filter, Reporting::InternshipOffer)
    assert ability.can?(:index, Acl::Reporting.new(user: god, params: {}))
  end

  test 'SchoolManager' do
    student = create(:student)
    another_school = create(:school)
    school_manager = create(:school_manager, school: student.school)
    internship_application = create(:weekly_internship_application, student: student)
    ability = Ability.new(school_manager)
    assert(ability.cannot?(:show, School),
           'school_manager should be able show school')
    assert(ability.can?(:manage, ClassRoom))
    assert(ability.can?(:destroy, internship_application))
    assert(ability.can?(:dashboard_index, student))
    assert(ability.can?(:dashboard_show, internship_application))
    assert(ability.cannot?(:dashboard_show, create(:weekly_internship_application)))
    assert(ability.can?(:see_tutor, InternshipOffer))
    assert(ability.can?(:manage_school_users, school_manager.school))
    assert(ability.cannot?(:manage_school_users, another_school))
    assert(ability.can?(:manage_school_students, school_manager.school))
    assert(ability.cannot?(:manage_school_students, another_school))
    assert(ability.cannot?(:change, :class_room))
  end

  test 'MainTeacher' do
    student = create(:student)
    school_manager = create(:school_manager, school: student.school)
    main_teacher = create(:main_teacher, school: student.school)
    internship_application = create(:weekly_internship_application, student: student)
    ability = Ability.new(main_teacher)
    assert(ability.can?(:show, :account),
           'students should be able to access their account')
    assert(ability.can?(:choose_school, main_teacher),
           'student should be able to choose_school')
    assert(ability.can?(:choose_class_room, main_teacher),
           'student should be able to choose_class_room')
    assert(ability.can?(:manage, ClassRoom))
    assert(ability.can?(:see_tutor, InternshipOffer))
    assert(ability.can?(:manage_school_students, main_teacher.school))
    assert(ability.cannot?(:manage_school_students, build(:school)))
    assert(ability.can?(:update, internship_application))
    assert(ability.can?(:change, :class_room))
  end

  test 'Teacher' do
    school = create(:school, :with_school_manager)
    teacher = create(:teacher, school: school)
    ability = Ability.new(teacher)
    assert(ability.can?(:manage, ClassRoom))
    assert(ability.can?(:see_tutor, InternshipOffer))
    assert(ability.can?(:manage_school_students, teacher.school))
    assert(ability.cannot?(:manage_school_students, build(:school)))
    assert(ability.can?(:change, :class_room))
  end

  test 'Other' do
    school = create(:school, :with_school_manager)
    another_school = create(:school)
    other = create(:other, school: school)
    ability = Ability.new(other)
    assert(ability.can?(:manage_school_students, other.school))
    assert(ability.cannot?(:manage_school_students, another_school))
    assert(ability.can?(:manage, ClassRoom))
    assert(ability.can?(:change, :class_room))
  end

  test 'Operator' do
    operator = create(:user_operator)
    ability = Ability.new(operator)
    assert(ability.can?(:create, InternshipOffers::Api.new),
           'Operator should be able to create internship_offers')
    assert(ability.cannot?(:update, InternshipOffers::Api.new),
           'Operator should not be able to update internship offer not belonging to him')
    assert(ability.can?(:update, InternshipOffers::Api.new(employer: operator)),
           'Operator should be able to update internships offer that belongs to him')
    assert(ability.can?(:index_and_filter, Reporting::InternshipOffer))
    assert(ability.can?(:index, Acl::Reporting.new(user: operator, params: {})))
    assert(ability.can?(:index, Acl::InternshipOfferDashboard.new(user: operator)),
           'Operator should be able to index InternshipOfferDashboard')
  end
end
