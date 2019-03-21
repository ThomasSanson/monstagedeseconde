module Users
  class MainTeacher < User
    belongs_to :class_room, optional: true

    include NearbyIntershipOffersQueryable
    include ManagedUser
  end
end
