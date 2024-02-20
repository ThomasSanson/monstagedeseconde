# frozen_string_literal: true

# ad blockers can block API, so we proxy our calls to it.
# not the neciest solution, but safest
class ApiEntrepriseProxyController < ApplicationController
  def search
    return render json: {error: 'missing name param'}, status: 400 unless params[:name]
    response = Api::AutocompleteSirene.search_by_name(name: params[:name])
    render json: clean_response(response.body), status: response.code
  end

  def clean_response(body)
    etablissements = []
    if JSON.parse(body)['results']
      JSON.parse(body)['results'].each do |etablissement|
        siege = etablissement['siege']
        etablissements << {
          siret: siege['siret'],
          is_public: etablissement['complements']['est_service_public'] == true,
          activite: siege['activite_principale'] ? activity(siege['activite_principale']) : 'N/A',
          uniteLegale: {
            denominationUniteLegale: etablissement['nom_complet']
          },
          adresseEtablissement: {
            numeroVoieEtablissement: '',
            typeVoieEtablissement: '',
            libelleVoieEtablissement: "#{siege['numero_voie']} #{siege['type_voie']} #{siege['libelle_voie']}",
            codePostalEtablissement: siege['commune'],
            libelleCommuneEtablissement: siege['libelle_commune'],
            adresseCompleteEtablissement: "#{siege['adresse']}"
          }
        }
      end
    end
    {etablissements: etablissements}
  end

  def activity(code)
    CODE_APE[code.split('.')[0].to_sym]
  end

  CODE_APE = {
    "1": "Culture et production animale, chasse et services annexes",
    "2": "Sylviculture et exploitation forestière",
    "3": "Pêche et aquaculture",
    "5": "Extraction de houille et de lignite",
    "6": "Extraction d'hydrocarbures",
    "7": "Extraction de minerais métalliques",
    "8": "Autres industries extractives",
    "9": "Services de soutien aux industries extractives",
    "10": "Industries alimentaires",
    "11": "Fabrication de boissons",
    "12": "Fabrication de produits à base de tabac",
    "13": "Fabrication de textiles",
    "14": "Industrie de l'habillement",
    "15": "Industrie du cuir et de la chaussure",
    "16": "Travail du bois et fabrication d'articles en bois et en liège, à l’exception des meubles ; fabrication d’articles en vannerie et sparterie",
    "17": "Industrie du papier et du carton",
    "18": "Imprimerie et reproduction d'enregistrements",
    "19": "Cokéfaction et raffinage",
    "20": "Industrie chimique",
    "21": "Industrie pharmaceutique",
    "22": "Fabrication de produits en caoutchouc et en plastique",
    "23": "Fabrication d'autres produits minéraux non métalliques",
    "24": "Métallurgie",
    "25": "Fabrication de produits métalliques, à l’exception des machines et des équipements",
    "26": "Fabrication de produits informatiques, électroniques et optiques",
    "27": "Fabrication d'équipements électriques",
    "28": "Fabrication de machines et équipements n.c.a.",
    "29": "Industrie automobile",
    "30": "Fabrication d'autres matériels de transport",
    "31": "Fabrication de meubles",
    "32": "Autres industries manufacturières",
    "33": "Réparation et installation de machines et d'équipements",
    "35": "Production et distribution d'électricité, de gaz, de vapeur et d'air conditionné",
    "36": "Captage, traitement et distribution d'eau",
    "37": "Collecte et traitement des eaux usées",
    "38": "Collecte, traitement et élimination des déchets ; récupération",
    "39": "Dépollution et autres services de gestion des déchets",
    "41": "Construction de bâtiments",
    "42": "Génie civil",
    "43": "Travaux de construction spécialisés",
    "45": "Commerce et réparation d'automobiles et de motocycles",
    "46": "Commerce de gros, à l’exception des automobiles et des motocycles",
    "47": "Commerce de détail, à l’exception des automobiles et des motocycles",
    "49": "Transports terrestres et transport par conduites",
    "50": "Transports par eau",
    "51": "Transports aériens",
    "52": "Entreposage et services auxiliaires des transports",
    "53": "Activités de poste et de courrier",
    "55": "Hébergement",
    "56": "Restauration",
    "58": "Édition",
    "59": "Production de films cinématographiques, de vidéo et de programmes de télévision ; enregistrement sonore et édition musicale",
    "60": "Programmation et diffusion",
    "61": "Télécommunications",
    "62": "Programmation, conseil et autres activités informatiques",
    "63": "Services d'information",
    "64": "Activités des services financiers, hors assurance et caisses de retraite",
    "65": "Assurance",
    "66": "Activités auxiliaires de services financiers et d'assurance",
    "68": "Activités immobilières",
    "69": "Activités juridiques et comptables",
    "70": "Activités des sièges sociaux ; conseil de gestion",
    "71": "Activités d'architecture et d'ingénierie ; activités de contrôle et analyses techniques",
    "72": "Recherche-développement scientifique",
    "73": "Publicité et études de marché",
    "74": "Autres activités spécialisées, scientifiques et techniques",
    "75": "Activités vétérinaires",
    "77": "Activités de location et location-bail",
    "78": "Activités liées à l'emploi",
    "79": "Activités des agences de voyage, voyagistes, services de réservation et activités connexes",
    "80": "Enquêtes et sécurité",
    "81": "Services relatifs aux bâtiments et aménagement paysager",
    "82": "Activités administratives et autres activités de soutien aux entreprises",
    "84": "Administration publique et défense ; sécurité sociale obligatoire",
    "85": "Enseignement",
    "86": "Activités pour la santé humaine",
    "87": "Hébergement médico-social et social",
    "88": "Action sociale sans hébergement",
    "90": "Activités créatives, artistiques et de spectacle",
    "91": "Bibliothèques, archives, musées et autres activités culturelles",
    "92": "Organisation de jeux de hasard et d'argent",
    "93": "Activités sportives, récréatives et de loisirs",
    "94": "Activités des organisations associatives",
    "95": "Réparation d'ordinateurs et de biens personnels et domestiques",
    "96": "Autres services personnels",
    "97": "Activités des ménages en tant qu'employeurs de personnel domestique",
    "98": "Activités indifférenciées des ménages en tant que producteurs de biens et services pour usage propre",
    "99": "Activités des organisations et organismes extraterritoriaux",
  }
end

