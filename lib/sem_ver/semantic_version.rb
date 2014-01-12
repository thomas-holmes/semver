module SemVer
  class SemanticVersion
    attr_reader :major, :minor, :patch, :pre, :build
    def initialize(params)
      @major = params[:major] || 0
      @minor = params[:minor] || 0
      @patch = params[:patch] || 0
      @pre   = params[:pre]   || []
      @build = params[:build] || []
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
    end
  end

  class InvalidSemanticVersion < StandardError
  end
end
