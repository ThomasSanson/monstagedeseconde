module SupportTickets
  class Employer < SupportTicket

    attr_accessor :speechers_quantity,
                  :business_lines_quantity,
                  :paqte

    validates :speechers_quantity,
              numericality: {
                only_integer: true,
                message: 'Il manque à cette demande le nombre d\'intervenants'
              }
    validates :business_lines_quantity,
              numericality: {
                only_integer: true,
                message: "'Il manque à cette demande le nombre de métiers abordés"
              }
  end
end