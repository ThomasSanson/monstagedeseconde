module Users
  class Teacher < User
    belongs_to :class_room, optional: true
    include ManagedUser
    include TargetableInternshipOffersForSchool

    def after_sign_in_path
      return url_helpers.account_path if [school, class_room].any?(&:blank?)
      custom_dashboard_path
    end

    def custom_dashboard_path
      url_helpers.dashboard_school_class_room_path(school, class_room)
    end
  end
end
