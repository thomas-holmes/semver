module SemVer
  class SemanticVersion
    attr_reader :major, :minor, :patch, :pre, :build
    def initialize(params)
      hash = normalize_hash(params)
      initialize_from_hash(hash)
    end

    VERSION_PATTERN = /\A(\d+)[.](\d+)[.](\d+)(?:-((?:[^0][a-zA-Z0-9-]+.?)+))?\Z/

    def self.parse(version_string)
      match = VERSION_PATTERN.match(version_string)
      version_hash = { :major => match.captures[0].to_i,
                       :minor => match.captures[1].to_i,
                       :patch => match.captures[2].to_i,
      }
      if match.captures[3]
        version_hash[:pre] = match.captures[3].split('.')
      end

      self.new(version_hash)
    rescue
      raise InvalidSemanticVersion.new("Could not parse #{version_string}")
    end

  private
    def normalize_hash(hash)
      new_hash = {}
      new_hash[:major] =   hash[:major]   || 0
      new_hash[:minor] =   hash[:minor]   || 0
      new_hash[:patch] =   hash[:patch]   || 0
      new_hash[:pre]   = [(hash[:pre]     || [])].flat_map { |i| i }.map(&:to_s)
      new_hash[:build] = [(hash[:build]   || [])].flat_map { |i| i }.map(&:to_s)
      new_hash
    end

    def initialize_from_hash(hash)
      @major = hash[:major]
      @minor = hash[:minor]
      @patch = hash[:patch]
      @pre   = hash[:pre]
      @build = hash[:build]
    end
  end

  class InvalidSemanticVersion < StandardError
  end
end
