require 'pretty_console'
namespace :data_migrations do
  desc 'create sectors'
  task add_sectors: :environment do
    {
      "Agroéquipement" => "s1",
      "Architecture, urbanisme et paysage" => "s2",
      "Armée - Défense" => "s3",
      "Art et design" => "s4",
      "Artisanat d'art" => "s5",
      "Arts du spectacle" => "s6",
      "Audiovisuel" => "s7",
      "Automobile" => "s8",
      "Banque et assurance" => "s9",
      "Bâtiment et travaux publics (BTP)" => "s10",
      "Bien-être" => "s11",
      "Commerce et distribution" => "s12",
      "Communication" => "s13",
      "Comptabilité, gestion, ressources humaines" => "s14",
      "Conseil et audit" => "s15",
      "Construction aéronautique, ferroviaire et navale" => "s16",
      "Culture et patrimoine" => "s17",
      "Droit et justice" => "s18",
      "Édition, librairie, bibliothèque" => "s19",
      "Électronique" => "s20",
      "Énergie" => "s21",
      "Enseignement" => "s22",
      "Environnement" => "s23",
      "Filiere bois" => "s24",
      "Fonction publique" => "s25",
      "Hôtellerie, restauration" => "s26",
      "Immobilier, transactions immobilières" => "s27",
      "Industrie alimentaire" => "s28",
      "Industrie chimique" => "s29",
      "Industrie, ingénierie industrielle" => "s30",
      "Informatique et réseaux" => "s31",
      "Jeu vidéo" => "s32",
      "Journalisme" => "s33",
      "Logistique et transport" => "s34",
      "Maintenance" => "s35",
      "Marketing, publicité" => "s36",
      "Mécanique" => "s37",
      "Métiers d'art" => "s38",
      "Mode" => "s39",
      "Papiers Cartons" => "s40",
      "Paramédical" => "s41",
      "Recherche" => "s42",
      "Santé" => "s43",
      "Sécurité" => "s44",
      "Services postaux" => "s45",
      "Social" => "s46",
      "Sport" => "s47",
      "Tourisme" => "s48",
      "Traduction, interprétation" => "s49",
      "Verre, béton, céramique" => "s50",
    }.map do |sector_name, sector_uuid|
      next if Sector.find_by(name: sector_name)

      Sector.create!(name: sector_name, uuid: sector_uuid)
      print "."
    end
  end

  desc 'create "lycees" from csv file'
  task create_lycees: :environment do
    import 'csv'
    # Maine-et-Loire,49000,Angers,Claude Debussy,0491764B,"{""type"":""Point"",""coordinates"":[-0.515542,47.4892457]}" is the objective
    # Source sample:
    # 0820559M;Lycée;Lycée général, technologique et professionnel agricole de Montauban;1915 route de Bordeaux;82000.0;Montauban;44.03232875150177, 1.3154221508373432;1.0;1.0;1.0;;;True;;;;left_only;646.0;207.0
    # fields are the following:
    # uai,type_etab,nom_etablissement,adresse,code_postal,commune,position,voie_generale,voie_techno,voie_pro,etab_mere,nbeleves,voie_gt,rentree_scolaire,nombre_d_eleves,2ndes_gt,_merge,nbeleves_est,2des_est
    # their index are
    col_hash= { uai: 0, nom_etablissement: 2, adresse: 3, code_postal: 4, commune: 5, position: 6 }
    error_lines = []
    file_location_production = Rails.root.join('db/data_imports/annuaire_lycees.csv')
    file_location_review = Rails.root.join('db/data_imports/annuaire_lycees_light.csv')
    file_location = Rails.env.in?(%w[review ]) ? file_location_review : file_location_production
    CSV.foreach(file_location, headers: { col_sep: ';' }).each.with_index(2) do |row, line_nr|
      next if line_nr.zero?

      cells = row.to_s.split(';')

      uai = cells[col_hash[:uai]]
      next if uai.nil?
      next if School.find_by(code_uai: uai)

      nom_etablissement = cells[col_hash[:nom_etablissement]]
      adresse = cells[col_hash[:adresse]]
      code_postal = cells[col_hash[:code_postal]].to_i.to_s
      code_postal = "0#{code_postal}" if code_postal.size == 4
      commune = cells[col_hash[:commune]]
      position_array = cells[col_hash[:position]].split(',').map(&:to_f)
      longitude = position_array[0]
      latitude = position_array[1]
      if (longitude == 0.0 && latitude == 0.0) || (longitude.nil? || latitude.nil?)
        coordinates = Geofinder.coordinates("#{adresse}, #{code_postal} #{commune}")
        longitude = coordinates[0]
        latitude = coordinates[1]
      end

      school_params = {
        code_uai: uai,
        name: nom_etablissement,
        street: adresse,
        zipcode: code_postal,
        city: commune,
        coordinates: {longitude: longitude, latitude: latitude}
      }
      school = School.new(school_params)
      if school.valid?
        school.save
        print "."
      else
        error_lines << ["Ligne #{line_nr}" , school.name, school.errors.full_messages.join(", ")]
        print "o"
      end
    end
    error_lines.each do |line|
      puts "Error #{line}"
    end
    puts "#{error_lines.size} errors"
    PrettyConsole.say_in_yellow  "Done with creating schools(lycées)"
  end

  desc 'create class_rooms from csv file'
  task provide_with_class_rooms: :environment do
    import 'csv'
    # ACADEMIE	CODE_RNE (UAI)	ID_ETAB_SCONET (ETAB_UAJ_Id)	DIVISION (CLASSE)	EFFECTIF DECLARE
    # Aix-Marseille	0134252B	1188	2ND09	35
    # their index are
    col_hash= { academie: 0, code_uai: 1, :'id_etab_sco-net' => 2, class_room_name: 3, class_size: 4 }
    error_lines = []
    file_location = Rails.root.join('db/data_imports/noms_de_classes.csv')
    CSV.foreach(file_location, headers: { col_sep: ';' }).each.with_index(2) do |row, line_nr|
      # with_index(2) : 2 is the offset to keep track of line number, taking into account the header
      next if line_nr.zero?

      cells = row.to_s.split(';')

      code_uai = cells[col_hash[:code_uai]]
      school = School.find_by(code_uai: code_uai)
      unless school.nil?
        print "#{school.name} - #{school.code_uai} missing data" if cells[col_hash[:class_room_name]].blank?
        class_room_name_new = false
        class_room = ClassRoom.find_or_create_by(name: cells[col_hash[:class_room_name]], school: school) do |class_room|
          class_room.class_size = cells[col_hash[:class_size]]
          class_room.name = cells[col_hash[:class_room_name]]
          class_room.school_id = school.id
          class_room_name_new = true
        end
        class_room_name_new ? PrettyConsole.print_in_green('.') : PrettyConsole.print_in_red('.')
      end
    end
    school_without_class_rooms = School.where
                                       .not(id: ClassRoom.pluck(:school_id))
    puts ''
    PrettyConsole.say_in_yellow "There are #{school_without_class_rooms.count} schools without class rooms"
    school_without_class_rooms.each do |school|
      puts "#{school.code_uai} - #{school.name}"
    end
    PrettyConsole.say_in_yellow "Done with creating class_rooms"
  end

  desc 'create corsica zipcodes department association reference table from csv file'
  task populate_corsica_zipcodes: :environment do
    import 'csv'
    # their index are
    # insee_com - 5 : 2B107
    # code_dept - 17 : 2B-2A
    # code postal - 22
    # nom_dept - 18 : Corse-du-Sud
    # nom_commune - 21 : Ajaccio
    col_hash= { zipcode: 22, city: 21, department: 18, insee_code: 5, department_code: 17 }
    error_lines = []
    file_location = Rails.root.join('db/data_imports/code-postal-code-insee-2015-corsica.csv')
    line_counter = 0
    counter = 0
    CSV.foreach(file_location, headers: { col_sep: ',' }).each.with_index(0) do |row, line_nr|
      next if line_nr == 0
      line_counter += 1

      cells = row.to_s.split(',')

      zipcode = cells[col_hash[:zipcode]]
      city = cells[col_hash[:city]]
      department = cells[col_hash[:department]]
      insee_code = cells[col_hash[:insee_code]]
      department_code = cells[col_hash[:department_code]]

      if CorsicaZipcode.find_by(zipcode: zipcode)
        PrettyConsole.print_in_red '.'
      else
        CorsicaZipcode.create!(
          zipcode: zipcode,
          city: city,
          department: department,
          insee_code: insee_code,
          department_code: department_code
        )
        counter +=1
        PrettyConsole.puts_in_green "."
      end
    end
    puts ""
    PrettyConsole.puts_in_green "There are #{line_counter} lines "
    PrettyConsole.puts_in_green "There are #{counter} records created"
    PrettyConsole.say_in_yellow "Done with creating Corsica zipcode reference table"
  end
end