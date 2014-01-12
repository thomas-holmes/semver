module SemVer
  class SemanticVersion
    attr_reader :major, :minor, :patch, :pre, :build
    def initialize(params)
      hash = normalize_hash(params)
      initialize_from_hash(hash)
    end

    VERSION_PATTERN  = /\A(\d+)\.(\d+)\.(\d+)(?:-(.+))?(?:\+(.+))?\Z/
    def self.parse(version_string)
      unless match = VERSION_PATTERN.match(version_string)
        raise InvalidSemanticVersion.new("Could not parse #{version_string}")
      end

      version_hash = { :major => match.captures[0].to_i,
                       :minor => match.captures[1].to_i,
                       :patch => match.captures[2].to_i,
      }

      if match.captures[3]
        version_hash[:pre] = match.captures[3].split('.')
      end

      if match.captures[4]
        version_hash[:build] = match.captures[4].split('.')
      end

      self.new(version_hash)
    end

    # Equality
    def ==(other)
      self.major == other.major &&
        self.minor == other.minor &&
        self.patch == other.patch
    end

    def >(other)
      self.major > other.major ||
        self.minor > other.minor ||
        self.patch > other.patch ||
        self.pre.empty? && other.pre.any?
    end

    def <(other)
      self.major < other.major ||
        self.minor < other.minor ||
        self.patch < other.patch ||
        self.pre.any? && other.pre.empty?
    end

    def <=(other)
      self < other || self == other
    end

    def >=(other)
      self > other || self == other
    end

  private
    def normalize_hash(hash)
      new_hash = {}
      new_hash[:major] =   hash[:major] || 0
      new_hash[:minor] =   hash[:minor] || 0
      new_hash[:patch] =   hash[:patch] || 0
      new_hash[:pre]   = [(hash[:pre]   || [])].flat_map { |i| i }.map(&:to_s).reject(&:empty?)
      new_hash[:build] = [(hash[:build] || [])].flat_map { |i| i }.map(&:to_s).reject(&:empty?)
      new_hash
    end

    def initialize_from_hash(hash)
      self.major  = hash[:major]
      self.minor  = hash[:minor]
      self.patch  = hash[:patch]
      self.pre    = hash[:pre]
      self.build  = hash[:build]
    end

    def major=(value)
      @major = value if validate_version!('Major version', value)
    end

    def minor=(value)
      @minor = value if validate_version!('Minor version', value)
    end

    def patch=(value)
      @patch = value if validate_version!('Patch version', value)
    end

    def pre=(value)
      @pre = value if validate_pre!('Pre-release version', value)
    end

    def build=(value)
      @build = value if validate_build!('Build tags', value)
    end

    def validate_version!(field, value)
      raise InvalidSemanticVersion.new("#{field} must be a Fixnum") unless value.is_a?(Fixnum)
      raise InvalidSemanticVersion.new("#{field} version must be >= 0") unless value >= 0
      true
    end

    PRE_PATTERN = /\A[a-zA-Z1-9-][a-zA-Z0-9-]*\Z/
    # Assumes it has already been normalized to an array.
    def validate_pre!(field, value)
      raise InvalidSemanticVersion.new("#{field} is invalid") unless value.all? { |p| p =~ PRE_PATTERN }
      true
    end

    BUILD_PATTERN = /\A[a-zA-Z0-9-]*\Z/
    # Assumes it has already been normalized to an array.
    def validate_build!(field, value)
      raise InvalidSemanticVersion.new("#{field} is invalid") unless value.all? { |b| b =~ BUILD_PATTERN }
      true
    end
  end

  class InvalidSemanticVersion < StandardError
  end
end
