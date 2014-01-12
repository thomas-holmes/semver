require 'sem_ver'
require 'rspec/collection_matchers'

RSpec::Matchers.define :be_a_version_equivalent_to do |hash|
  match do |version|
    version.major == (hash[:major] || 0)  &&
    version.minor == (hash[:minor] || 0)  &&
    version.patch == (hash[:patch] || 0)  &&
    version.pre   == (hash[:pre]   || []) &&
    version.build == (hash[:build] || [])
  end
end

module SemVer
  shared_examples 'SemanticVersion creation' do
    before(:each) { @version_hash = { :major => 1, :minor => 2, :patch => 3 } }
    it 'create a SemanticVersion' do
      expect(version).to be_a_version_equivalent_to(@version_hash)
    end

    context 'pre-release versions' do
      specify 'when no pre-release values are supplied #pre is an empty array' do
        expect(version.pre). to eq []
      end

      it 'can be made with an array of tags' do
        @version_hash[:pre] = ['beta']
        expect(version).to have(1).pre
        expect(version.pre).to eq ['beta']
      end

      it 'can be made with multiple tags' do
        @version_hash[:pre] = ['beta1', 'beta2']
        expect(version).to have(2).pre
        expect(version.pre).to eq ['beta1', 'beta2']
      end

      xit 'pre tags end up as string values' do
        @version_hash[:pre] = ['beta1', 2]
        expect(version).to have(2).pre
        expect(version.pre).to eq ['beta1', '2']
      end
    end
  end

  describe "SemanticVersion" do
    context 'initialization' do
      let(:version) { SemanticVersion.new(@version_hash) }
      include_examples 'SemanticVersion creation'
    end
    context 'parsing' do
      let(:version) { SemanticVersion.parse(version_string) }
      let(:version_string) { hash_to_string(@version_hash) }
      include_examples 'SemanticVersion creation'
    end
  end
end

def hash_to_string(hash)
  version = "#{hash[:major]}.#{hash[:minor]}.#{hash[:patch]}"
  unless hash[:pre].nil? || hash[:pre].empty?
    version = version + "-#{hash[:pre].join('.')}"
  end

  unless hash[:build].nil? || hash[:build].empty?
    version = version + "+#{hash[:build].join('.')}"
  end

  version
end
