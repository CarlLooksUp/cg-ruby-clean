module BusinessesHelper

  def find_sic_label(code)
    lookup = {}
    sic_tree = populate_sic_codes
    sic_tree.each do |category, subtree|
      lookup.merge!(subtree)
    end
    logger.debug "#{lookup.inspect}"
    lookup[code]
  end

  def find_entity_type_label(code)
    lookup = {}
    entity_type_tree = populate_entity_types
    entity_type_tree.each do |category, subtree|
      lookup.merge!(subtree)
    end
    lookup[code]
  end

  private
    def populate_sic_codes
      Rails.cache.fetch('sic_code_list') {
        f = File.open("data/sic_codes.json")
        sic_code_list = JSON.parse f.read()
        f.close()
        sic_code_list
      }
    end

    def populate_entity_types
      Rails.cache.fetch('entity_types_list') {
        f = File.open("data/entity_types.json")
        entity_type_list = JSON.parse f.read()
        f.close()
        entity_type_list
      }
    end

    def populate_state_abbreviations
      Rails.cache.fetch('state_abbreviations_list') {
        f = File.open("data/state_abbreviations.json")
        state_abbreviations_list = JSON.parse f.read()
        f.close()
        state_abbreviations_list
      }
    end
end
