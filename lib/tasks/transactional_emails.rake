# call by clever cloud cron daily at 9am
# which does not support custom day cron. so inlined in code
desc 'To be scheduled in cron a 9pm to remind employer to manage their internship applications'
task internship_application_reminders: :environment do
  Rails.logger.info("Cron runned at #{Time.now.utc}(UTC), internship_application_reminders")
  if [Date.today.monday?, Date.today.thursday?].any?
    Triggers::InternshipApplicationReminder.new.enqueue_all
  end
end

# call by clever cloud cron daily at 9am
# which does not support custom day cron. so inlined in code
desc 'To be scheduled in cron a 9pm to remind employer to manage their internship applications'
task school_missing_weeks_reminders: :environment do
  Rails.logger.info("Cron runned at #{Time.now.utc}(UTC), school_missing_weeks_reminders")
  if Date.today.monday?
    Triggers::SchoolMissingWeeksReminder.new.enqueue_all
  end
end

desc 'Evaluate employers count with approved application under conditions'
task employers_with_potential_agreeements: :environment do
  class_rooms = ClassRoom.arel_table
  offers      = InternshipOffer.arel_table
  departments = ENV['OPEN_DEPARTEMENTS_CONVENTION'].split(',').map(&:to_str)
  offer_ids = InternshipApplications::WeeklyFramed.joins( :week , student: {class_room: :school})
                                                  .approved
                                                  .where('weeks.number > ?', Date.current.cweek)
                                                  .where('weeks.year >= ?', Date.current.year)
                                                  .where(combined_arel('schools.zipcode').in(departments))
                                                  .where(class_rooms[:school_track].eq('troisieme_generale'))
                                                  .includes(:internship_offer)
                                                  .to_a
                                                  .map(&:internship_offer)
                                                  .map(&:id)
                                                  .uniq
  # Without Arel::Nodes::NamedFunctions
  # offer_ids = InternshipApplications::WeeklyFramed.joins( :week, student: {class_room: :school} )
  #                                           .approved
  #                                           .where('weeks.number > ?', Date.current.cweek)
  #                                           .where('weeks.year >= ?', Date.current.year)
  #                                           .where(class_rooms[:school_track].eq('troisieme_generale'))
  #                                           .where("LEFT(CAST(schools.zipcode as varchar(255)),2) IN ('75','02','78')")
  #                                           .includes(:internship_offer)
  #                                           .to_a
  #                                           .map(&:internship_offer)
  #                                           .map(&:id)
  #                                           .uniq

  if offer_ids.empty?
    puts "no count"
  else
    emails = InternshipOffers::WeeklyFramed.where(offers[:id].in(offer_ids))
                                           .includes(:employer)
                                           .map { |offer| offer.employer.email }
                                           .uniq

    puts "Results: #{emails}"
  end
end

def first_chars(nr:, attribute:)
  Arel::Nodes::NamedFunction.new( 'LEFT', [attribute, nr] )
end

def sql_to_string(int_var)
  Arel::Nodes::NamedFunction.new(
    'CAST', [Arel.sql("#{int_var} as varchar(255)")]
  )
end

def combined_arel(attr)
  first_chars(nr: 2, attribute: sql_to_string(attr))
end