# To change this template, choose Tools | Templates
# and open the template in the editor.
require "yaml"

module WikiExtensions
  YAML_FILE = File.join(File.dirname(__FILE__), '../config/emoticons.yml')
  class Emoticons
    def emoticons
      @@emoticons ||= YAML.load_file(YAML_FILE)
    end
  end
end
