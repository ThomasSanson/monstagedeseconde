# frozen_string_literal: true

FactoryBot.define do
  factory :internship_application do
    type { 'InternshipApplications::WeeklyFramed' }
    student { create(:student) }
    internship_offer_week { create(:internship_offer_week) }
    motivation { 'Suis hyper motivé' }
  end

  trait :drafted do
    aasm_state { :drafted }
  end

  trait :submitted do
    aasm_state { :submitted }
    submitted_at { 3.days.ago }
  end

  trait :expired do
    aasm_state { :expired }
    submitted_at { 15.days.ago }
    expired_at { 3.days.ago }
  end

  trait :approved do
    aasm_state { :approved }
    submitted_at { 3.days.ago }
    approved_at { 2.days.ago }
  end
  trait :rejected do
    aasm_state { :rejected }
    submitted_at { 3.days.ago }
    rejected_at { 2.days.ago }
  end

  trait :canceled_by_employer do
    aasm_state { :canceled_by_employer }
    submitted_at { 3.days.ago }
    rejected_at { 2.days.ago }
    canceled_at { 2.days.ago }
  end
  trait :canceled_by_student do
    aasm_state { :canceled_by_student }
    submitted_at { 3.days.ago }
    canceled_at { 2.days.ago }
  end

  trait :convention_signed do
    aasm_state { :convention_signed }
    submitted_at { 3.days.ago }
    approved_at { 2.days.ago }
    convention_signed_at { 1.days.ago }
  end
end
