module InternshipAgreements
  class BaseComponent < ApplicationComponent
    delegate :main_teacher_accept_terms?,
             :school_manager_accept_terms?,
             :employer_accept_terms?,
             :troisieme_generale?,
             to: :internship_agreement,
             allow_nil: true

    def ready_to_print?
      signed_count == signatures_count_required
    end

    def signed_count
      required_signatures.map { |attr_name| self.send("#{attr_name}") }
                         .select { |value| value == true}
                         .size
    end

    def signatures_count_required
      required_signatures.size
    end

    def required_signatures
      signatures = [
        :employer_accept_terms?,
        :school_manager_accept_terms?
      ]
      signatures = signatures.concat(:main_teacher_accept_terms?) unless troisieme_generale?
      signatures
    end


  end
end
