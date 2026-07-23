# To change this template, choose Tools | Templates
# and open the template in the editor.
require "yaml"

# Loads emoticon definitions from the plugin's YAML configuration.
module WikiExtensionsEmoticons
  # Path to the emoticons YAML configuration file.
  YAML_FILE = File.join(File.dirname(__FILE__), "../config/emoticons.yml")

  # Provides lazy-loaded access to the emoticon list.
  class Emoticons
    # Returns the list of emoticon definitions loaded from {YAML_FILE}.
    # @return [Array<Hash>]
    def emoticons
      @@emoticons ||= YAML.load_file(YAML_FILE)
    end
  end
end
