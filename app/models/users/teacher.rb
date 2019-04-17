module Users
  class Teacher < User
    belongs_to :class_room, optional: true
    include ManagedUser
    include TargetableInternshipOffersForSchool

    def custom_dashboard_path
      url_helpers.dashboard_school_class_room_path(school, class_room)
    rescue
      url_helpers.account_path
    end
  end
end
