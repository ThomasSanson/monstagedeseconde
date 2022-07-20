FactoryBot.define do
  factory :internship_agreement do
    internship_application { create(:weekly_internship_application) }

    student_school { internship_application.student.school.name }
    school_representative_full_name { internship_application.student.school.name }
    student_full_name { 'Jean-Claude Dus' }
    student_class_room { '3e A'}
    main_teacher_full_name { 'Paul Lefevbre' }
    organisation_representative_full_name { 'DGSE' }
    tutor_full_name { 'Julie Mentor' }
    date_range { "du 10/10/2020 au 15/10/2020" }
    activity_scope_rich_text { '<div>Accueil clients</div>'}
    complementary_terms_rich_text { '<div>Ticket resto</div>'}
    activity_preparation_rich_text { '<div>Appel téléphonique</div>'}
    aasm_state { 'draft' }
    weekly_hours { ['9:00', '17:00'] }
    weekly_lunch_break { '1h dans la cantine. Repas fourni.' }
    school_track { 'troisieme_generale' }
    activity_rating_rich_text { '<div>Rapport de stage</div>'}
    activity_learnings_rich_text { '<div>Communication orale</div>'}

    trait :created_by_system do
      skip_validations_for_system { true }
    end
  end
end
